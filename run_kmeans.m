%% Run the kmeans
function pars = run_kmeans(pars)

for itr = 1:pars.iterations
    
    X = pars.X_total(randsample(size(pars.X_total,1), pars.resample_size),:);
    x2 = sum(X.^2,2);
    
%     c2 = 0.5*sum(pars.centroids.^2,2);
    
    summation = zeros(pars.hidnum, size(X,2));
    counts = zeros(pars.hidnum, 1);
    
    loss =0; 
    
    all_fire    = 0;
    
    for i=1:pars.BATCH_SIZE:size(X,1)
        lastIndex=min(i+pars.BATCH_SIZE-1, size(X,1));
        m = lastIndex - i + 1;
        
%         temp = bsxfun(@minus,pars.centroids*X(i:lastIndex,:)',c2);
        temp    = pars.centroids*X(i:lastIndex, :)';
        
%         %use threshold
%         maxval = max(temp); minval = min(temp);
%         th = maxval-0.001*(maxval-minval);
%         S = (temp>ones(hidnum,1)*th)';
        
        %fix sparsity 
%         S=resp(temp,L1);
        [S, labels, pars]     = resp_with_Labels(temp, pars);
        labels          = [i:lastIndex;labels];

%         if pars.cal_loss == 1
%             loss = loss+trace(S*(0.5*ones(pars.hidnum,1)*x2(i:lastIndex)'-temp));
%         end
        summation = summation + S'*X(i:lastIndex,:);
        counts = counts + sum(S,1)';
%         fprintf('%d\n', i);
        if isfield(pars, 'soft_coding')==1 && pars.soft_coding==1
            all_fire        = all_fire + sum(sum(S > pars.threshold));
            if pars.cal_loss == 1
                delta_X         = X(i:lastIndex, :) - S*pars.centroids;
                loss            = loss + sum(sum(delta_X.^2));
            end
        end
    end
    
    
    if isfield(pars, 'soft_coding')==1 && pars.soft_coding==1
        mean_fire       = all_fire / size(X,1);
        if  mod(itr,pars.itr_interval)==1
            delta_th        = sign(mean_fire - pars.L1)*min(pars.max_stride, exp(-1/(abs(mean_fire - pars.L1)*pars.max_divide)));
            fprintf('%g\n', exp(-1/(abs(mean_fire - pars.L1)*pars.max_divide)));
            pars.threshold  = pars.threshold + delta_th;
            fprintf('threshold is :%g\n', pars.threshold);
        end
    end
%     fprintf('%f\n', mean_fire);
%     
%     disp(pars.threshold);
%     pause;
%     size(labels)

    if pars.display_result==1
        new_L1      = min(pars.L1+1, size(labels, 1));
        show_label  = zeros(pars.show_num*(new_L1), size(pars.centroids, 2));
        for i=1:pars.show_num
            show_label((i-1)*(new_L1) + 1,:)  = X(labels(1, i),:);
            for j=2:new_L1
                show_label((i-1)*(new_L1) + j,:)  = pars.centroids(labels(j, i),:);
            end
        end

        pars.show_label 	= show_label;
    end
    
    pars.counts         = counts;
    pars.old_cent       = pars.centroids;
    
    pars.centroids      = bsxfun(@rdivide, summation, counts);
  
    % just zap empty centroids so they don't introduce NaNs everywhere.
%     badIndex = find(counts == 0);
    
    if isfield(pars, 'second_layer')==1 && pars.second_layer==1
        hid_tmp             = sum(counts==0);
        r_tmp           = rand(hid_tmp, size(pars.X_total, 2));
        g_tmp           = var(pars.X_total(1,:))/var(r_tmp(:));
        
        pars.centroids(counts == 0, :)      = (r_tmp-0.5)*sqrt(g_tmp) + mean(pars.X_total(1,:));
    else
        pars.centroids(counts == 0, :) = randn(sum(counts==0),pars.patchsize^2*pars.frame_num);
    end
    
    pars.centroids      = bsxfun(@rdivide, pars.centroids, sqrt(sum(pars.centroids.^2, 2))+0.00001);
    
    pars.diff_cent(end+1)   = sqrt(mean(sum((pars.centroids - pars.old_cent).^2, 2)));
    
    if isfield(pars, 'soft_coding')==0 || pars.soft_coding==0
        mean_fire   = sum(counts)/pars.resample_size;
    end
    
    fprintf('K-means iterations  %d,  mean fire %g, diff %g',...
        itr, mean_fire, pars.diff_cent(end));
    if pars.cal_loss==1
        fprintf(', overall loss %g\n', loss/pars.resample_size);
    else
        fprintf('\n');
    end
    
    if mod(itr,pars.display_inter)==0 && pars.display==1
		visualize(pars);
    end
end
