%% Calculate the nearest centroids
function [S, all_labels, pars]=resp_with_Labels(temp, pars)
	[hidnum,m]=size(temp);
% 	S=zeros(size(temp))';
%     all_labels  = [];
% 	for i=1:iter
% 		[val,labels] = max(temp);
%         all_labels   = [all_labels; labels];
% 		S1 = sparse(1:m,labels,1,m,hidnum,m);
% 		temp = temp-S1'*1e10;
% 		S=S+S1;
% 	end
    if isfield(pars, 'soft_coding')==0 || pars.soft_coding==0
        iter    = pars.L1;

        [val, all_labels]  = maxk(temp, iter);
        
        tmp     = all_labels';
        S       = sparse(repmat(1:m, 1, iter), tmp(:)', 1, m, hidnum, iter*m);
    else
        S=zeros(size(temp))';
        all_labels  = [];
        
        for i=1:pars.max_L
            [val, labels]   = max(temp);
            
            if max(val) < pars.threshold
                break;
            end
            
            all_labels   = [all_labels; labels];
            labels(val < pars.threshold)    = hidnum+1;
            S1      = sparse(1:m, labels, val, m, hidnum+1, m);
            S1      = S1(:, 1:hidnum);
            S_tmp   = S1 * pars.centroids * pars.centroids';
            temp    = temp - max(S_tmp', 0);
            temp    = temp-S1'*1e10;
%             S       = S + double(S1 > pars.threshold);
            S       = S + S1;
        end
    end