%% Calculate the nearest centroids
function [S, all_labels, pars]=resp_with_Labels(temp, pars)
    baktemp     = temp;
	[hidnum,m]  = size(temp);
    all_labels  = [];
% 	S=zeros(size(temp))';
%     all_labels  = [];
% 	for i=1:iter
% 		[val,labels] = max(temp);
%         all_labels   = [all_labels; labels];
% 		S1 = sparse(1:m,labels,1,m,hidnum,m);
% 		temp = temp-S1'*1e10;
% 		S=S+S1;
% 	end
    if pars.soft_coding==0 && pars.LCA_coding==0
        iter    = pars.L1;

        [val, all_labels]  = maxk(temp, iter);
        
        tmp     = all_labels';
        S       = sparse(repmat(1:m, 1, iter), tmp(:)', 1, m, hidnum, iter*m);
    elseif pars.soft_coding==1 && pars.LCA_coding==0
        
        S=zeros(size(temp))';
        all_labels  = [];
        
        for i=1:pars.max_L
            [val, labels]   = max(temp);
            
            if max(val) < pars.threshold
                break;
            end
            
            all_labels   = [all_labels; labels];
            if pars.stable_stage==0
                labels(val < pars.threshold)    = hidnum+1;
                S1      = sparse(1:m, labels, val, m, hidnum+1, m);
                S1      = S1(:, 1:hidnum);  
                S_tmp   = S1 * pars.cent_corr;
                temp    = temp - max(S_tmp', 0);
                temp    = temp - S1'*1e10;
                S       = S + S1;                
            else
                need_labels     = all_labels(:, val > pars.threshold);
                big_place       = find(val > pars.threshold);
                cell_bg_plc     = num2cell(big_place);
                cell_labels     = num2cell(need_labels, 1);
                cell_dTX        = cellfun(@(x, y)(baktemp(x, y)), cell_labels, cell_bg_plc, 'UniformOutput', false);
                cell_dTd        = cellfun(@(x)(pars.cent_corr(x, x)), cell_labels, 'UniformOutput', false);
                
%                 for j=1:length(cell_dTd)
%                     a = cell_dTd{j};
%                     if rank(a) < size(a,1)
%                         disp(cell_labels{j})
%                         b = cell_labels{j};
%                         disp(val(big_place(j)));
% %                         pause
%                     end
%                 end
                
                cell_dTdinv     = cellfun(@(x)(inv(x)), cell_dTd, 'UniformOutput', false);
                cell_result     = cellfun(@(x,y)(x*y), cell_dTdinv, cell_dTX, 'UniformOutput', false);
                cell_result     = cellfun(@(x)(x'), cell_result, 'UniformOutput', false);
                mat_result      = cell2mat(cell_result)';
                
%                 new_threshold   = pars.threshold;
%                 if sum(mat_result<new_threshold)>0
% %                     disp(i);
%                     disp(mod(find(mat_result<new_threshold), i));
% %                     disp(mat_result(mat_result<new_threshold));
% %                     for j=1:length(cell_result)
% % %                         a = cell_result{j};
% %                         if sum(a<new_threshold)>0
% % %                             disp(j);
% % %                             disp(a);
% % %                             disp(cell_dTd{j})
% % %                             disp(cell_dTdinv{j})
% % %                             disp(cell_dTX{j})
% %                             disp(find(a<new_threshold));
% % %                             pause;
% %                         end
% %                     end
% %                     pause;
%                 end
                
                tmp             = need_labels;
                tmp_big         = repmat(big_place, i, 1);
                tmp_big_try     = tmp_big(:);             
                S1              = sparse(tmp_big_try, tmp(:), mat_result(:), m, hidnum, i*m);
                S_tmp   = S1 * pars.cent_corr;
%                 S_tmp   = S1 * pars.cent_corr_pos;
                temp(:, big_place)    = baktemp(:, big_place) - S_tmp(big_place, :)';
%                 temp(:, big_place)    = baktemp(:, big_place) - max(S_tmp(big_place, :)', 0);
%                 temp    = temp - max(S_tmp', 0);
                temp    = temp - max(S1', 0)*1e10;
                S(big_place, :)     = S1(big_place, :);
            end
        end
    elseif pars.soft_coding==0 && pars.LCA_coding==1
        G   = pars.cent_corr - eye(pars.hidnum);
        b   = baktemp;
        
        u   = zeros(pars.hidnum, m);
        l   = 0.5*max(abs(b));
        a   = g_non_line(u, l);
        
        for t=1:pars.LCA_iteration
            u   = pars.eta*(b-G*a) + (1-pars.eta)*u;
            a   = g_non_line(u, l, pars.thresh_type);
            l   = pars.decay_rate * l;
            
            l(l<pars.lambda)     = pars.lambda;
        end
        
        S   = a';
    else
        error('Wrong Set!');
    end
        