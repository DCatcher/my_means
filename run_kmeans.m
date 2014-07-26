%% Run the kmeans
function pars = run_kmeans(pars)

for itr = 1:pars.iterations
    
    X = pars.X_total(randsample(size(pars.X_total,1), pars.resample_size),:);
    x2 = sum(X.^2,2);
    
    c2 = 0.5*sum(pars.centroids.^2,2);
    
    summation = zeros(pars.hidnum, size(X,2));
    counts = zeros(pars.hidnum, 1);
    
    loss =0; 
    
    for i=1:pars.BATCH_SIZE:size(X,1)
        lastIndex=min(i+pars.BATCH_SIZE-1, size(X,1));
        m = lastIndex - i + 1;
        
        temp = bsxfun(@minus,pars.centroids*X(i:lastIndex,:)',c2);
        
%         %use threshold
%         maxval = max(temp); minval = min(temp);
%         th = maxval-0.001*(maxval-minval);
%         S = (temp>ones(hidnum,1)*th)';
        
        %fix sparsity 
%         S=resp(temp,L1);
        [S, labels]     = resp_with_Labels(temp,pars.L1);
        labels          = [i:lastIndex;labels];

        loss = loss+trace(S*(0.5*ones(pars.hidnum,1)*x2(i:lastIndex)'-temp));
        summation = summation + S'*X(i:lastIndex,:);
        counts = counts + sum(S,1)';
    end
    
%     size(labels)

    show_label  = zeros(pars.show_num*(pars.L1+1), size(pars.centroids, 2));
    for i=1:pars.show_num
        show_label((i-1)*(pars.L1+1) + 1,:)  = X(labels(1, i),:);
        for j=1:pars.L1
            show_label((i-1)*(pars.L1+1) + 1 + j,:)  = pars.centroids(labels(j+1, i),:);
        end
    end

	pars.show_label 	= show_label;
    
    pars.centroids = bsxfun(@rdivide, summation, counts);
  
    % just zap empty centroids so they don't introduce NaNs everywhere.
    badIndex = find(counts == 0);
    pars.centroids(badIndex, :) = 0;
    
    fprintf('K-means iterations  %d,  sparsity %g, overall loss %g\n',...
        itr, sum(counts)/pars.resample_size/pars.hidnum, loss);
    
    if mod(itr,pars.display_inter)==0 && pars.display==1
		visualize(pars);
    end
end
