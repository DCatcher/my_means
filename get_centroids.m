function tmp_centroids = get_centroids(pars)

if isfield(pars, 'second_layer')==0 || pars.second_layer==0
    tmp_centroids               = pars.centroids;
else
    if isfield(pars, 'time_bigger')==0 || pars.time_bigger==0
        tmp_centroids               = pars.centroids*pars.first_layer_centroids;
    end
    
    if isfield(pars, 'time_bigger')==1 && pars.time_bigger==1
        tmp_centroids               = zeros(pars.hidnum, size(pars.first_layer_centroids, 2)*pars.time_sepa_num);
        for i=1:pars.time_sepa_num
            tmp_centroids(:, pars.centroids_inter(i,:))     = tmp_centroids(:, pars.centroids_inter(i,:)) + pars.centroids(:,pars.X_total_inter(i,:))*pars.first_layer_centroids;
        end
    end    
    
    tmp_centroids   = bsxfun(@rdivide, tmp_centroids, sqrt(sum(tmp_centroids.^2, 2))+0.00001);
end