%% Run the kmeans
function pars = run_kmeans(pars)

for itr = 1:pars.iterations
    X = pars.X_total(randsample(size(pars.X_total,1), pars.resample_size),:);
    
    pars.cent_corr      = pars.centroids * pars.centroids';
    pars.cent_corr_pos  = max(pars.cent_corr, 0);
    
    if pars.LCA_second_layer==0
        summation = zeros(pars.hidnum, size(X,2));
        counts = zeros(pars.hidnum, 1);

        loss =0; 

        all_fire    = 0;

        for i=1:pars.BATCH_SIZE:size(X,1)
            lastIndex=min(i+pars.BATCH_SIZE-1, size(X,1));

            temp    = pars.centroids*X(i:lastIndex, :)';
            [S, labels, pars]     = resp_with_Labels(temp, pars);

            if pars.display_result==1
                labels            = [i:lastIndex;labels];
            end

            counts = counts + sum(S,1)';
            if pars.learn_type==2
                for j=1:pars.hidnum
                    summation(j, :)     = summation(j,:) + S(:, j)'*( X(i:lastIndex, :) - pars.learning_part * S(:, j)*pars.centroids(j,:));
                end
            elseif pars.learn_type==1
                summation = summation + S'*X(i:lastIndex,:);
            else
                error('Unknown learning type!');
            end
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
            if  mod(itr,pars.itr_interval)==0
                fprintf('%g\n', abs(mean_fire - pars.L1)*pars.max_divide);
                delta_th        = sign(mean_fire - pars.L1)*min(pars.max_stride, abs(mean_fire - pars.L1)*pars.max_divide);
                pars.threshold  = pars.threshold + delta_th;
                fprintf('threshold is :%g\n', pars.threshold);
            end
        end

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

        if isfield(pars, 'second_layer')==1 && pars.second_layer==1
            hid_tmp             = sum(counts==0);
            r_tmp           = rand(hid_tmp, size(pars.X_total, 2));
            g_tmp           = var(pars.X_total(1,:))/var(r_tmp(:));

            pars.centroids(counts == 0, :)      = (r_tmp-0.5)*sqrt(g_tmp) + mean(pars.X_total(1,:));
        else
            pars.centroids(counts == 0, :) = randn(sum(counts==0),pars.patchsize^2*pars.frame_num);
        end

        if isfield(pars, 'part_empty')==1 && pars.part_empty==1
            pars.centroids(pars.empty_conn)     = 0;
        end

        pars.centroids      = bsxfun(@rdivide, pars.centroids, sqrt(sum(pars.centroids.^2, 2)));

        pars.diff_cent(end+1)   = sqrt(mean(sum((pars.centroids - pars.old_cent).^2, 2)));

        if isfield(pars, 'soft_coding')==0 || pars.soft_coding==0
            mean_fire   = sum(counts)/pars.resample_size;
        end
        
    
        fprintf('K-means iterations  %d,  mean fire %g, diff %g',...
            itr, mean_fire, pars.diff_cent(end));        
    else
        pars.second_layer_centroids_expand      = pars.second_layer_centroids * pars.centroids;
        pars.second_layer_cent_corr             = pars.second_layer_centroids_expand * pars.second_layer_centroids_expand';
        
        summation1  = zeros(pars.hidnum, size(X,2));
        summation2  = zeros(pars.LCA_second_hidnum, pars.hidnum);
        counts1     = zeros(pars.hidnum, 1);        
        counts2     = zeros(pars.LCA_second_hidnum, 1);
        
        loss        = 0;
        
        for i=1:pars.BATCH_SIZE:size(X,1)
            lastIndex       = min(i+pars.BATCH_SIZE-1, size(X,1));
            temp            = pars.centroids*X(i:lastIndex, :)';
            [S1,S2,pars]    = resp_LCA_second_layer(temp, pars);
            
            counts1         = counts1 + sum(S1,1)';
            counts2         = counts2 + sum(S2,1)';
            
            if pars.learn_type==1
                summation1  = summation1 + S1'*X(i:lastIndex,:);
                summation2  = summation2 + S2'*S1;
            else
                error('Not finish!');
            end
            
        end
        
        pars.counts1    = counts1;
        pars.counts2    = counts2;
        pars.old_cent1  = pars.centroids;
        pars.old_cent2  = pars.second_layer_centroids;
        
        pars.centroids  = bsxfun(@rdivide, summation1, counts1);
        pars.second_layer_centroids     = bsxfun(@rdivide, summation2, counts2);
        
        pars.centroids(counts1 == 0, :) = randn(sum(counts1==0),size(pars.centroids, 2));
        pars.second_layer_centroids(counts2 == 0, :)    = (rand(sum(counts2 == 0), pars.hidnum) > pars.second_layer_init_part);
        
        pars.centroids      = bsxfun(@rdivide, pars.centroids, sqrt(sum(pars.centroids.^2, 2)));
        pars.second_layer_centroids      = bsxfun(@rdivide, pars.second_layer_centroids,...
                                                sqrt(sum(pars.second_layer_centroids.^2, 2)));
        
        pars.diff_cent(end+1)   = sqrt(mean(sum((pars.centroids - pars.old_cent1).^2, 2))) + ...
                                  sqrt(mean(sum((pars.second_layer_centroids - pars.old_cent2).^2, 2)));
        mean_fire1   = sum(counts1)/pars.resample_size;
        mean_fire2   = sum(counts2)/pars.resample_size;
        
    
        fprintf('K-means iterations  %d,  mean fire %g, %g, diff %g',...
            itr, mean_fire1,mean_fire2, pars.diff_cent(end));        
    end

    if pars.cal_loss==1
        fprintf(', overall loss %g\n', loss/pars.resample_size);
    else
        fprintf('\n');
    end
    
    if mod(itr,pars.display_inter)==0 && pars.display==1
		visualize(pars);
    end
end
