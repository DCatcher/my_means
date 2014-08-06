function tmp_centroids = get_centroids(pars)

if isfield(pars, 'second_layer')==0 || pars.second_layer==0
    tmp_centroids               = pars.centroids;
else
    if (isfield(pars, 'time_bigger')==0 || pars.time_bigger==0) && ...
       (isfield(pars, 'space_bigger')==0 || pars.space_bigger==0)
        tmp_centroids               = pars.centroids*pars.first_layer_centroids;
    end
    
    if isfield(pars, 'time_bigger')==1 && pars.time_bigger==1 && ...
       (isfield(pars, 'space_bigger')==0 || pars.space_bigger==0)
        tmp_centroids               = zeros(pars.hidnum, size(pars.first_layer_centroids, 2)*pars.time_sepa_num);
        for i=1:pars.time_sepa_num
            tmp_centroids(:, pars.centroids_inter(i,:))     = tmp_centroids(:, pars.centroids_inter(i,:)) + pars.centroids(:,pars.X_total_inter(i,:))*pars.first_layer_centroids;
        end
    end    
    
    if isfield(pars, 'space_bigger')==1 && pars.space_bigger==1 && ...
       (isfield(pars, 'time_bigger')==0 || pars.time_bigger==0) 
        tmp_centroids               = zeros(pars.hidnum, pars.patchsize, pars.patchsize, pars.frame_num);
        for i=1:pars.space_sepa_num
            xst     = pars.space_sepa_inter(i,1);
            xen     = pars.space_sepa_inter(i,2);
            yst     = pars.space_sepa_inter(i,3);
            yen     = pars.space_sepa_inter(i,4);  
            size_m  = [pars.hidnum, xen-xst+1, yen-yst+1, pars.frame_num];
            tmp_centroids(:, xst:xen, yst:yen, :)   = tmp_centroids(:, xst:xen, yst:yen, :) + reshape(pars.centroids(:,pars.X_total_inter(i,:))*pars.first_layer_centroids, size_m);
        end
        tmp_centroids               = reshape(tmp_centroids, size(tmp_centroids, 1), ...
                            size(tmp_centroids, 2)*size(tmp_centroids, 3)*size(tmp_centroids, 4));
    end
    
    tmp_centroids   = bsxfun(@rdivide, tmp_centroids, sqrt(sum(tmp_centroids.^2, 2))+0.00001);
end