%% Get the second layer's centroids, and first layer's centroids
function [first_layer_cent, second_layer_cent]   = get_two_centroids(pars)

if isfield(pars, 'second_layer')==0 && isfield(pars, 'LCA_second_layer')==0
    error('This does not have a second layer!');
end

if isfield(pars, 'second_layer')==1 && pars.second_layer==1 && ...
   (isfield(pars, 'LCA_second_layer')==0 || pars.LCA_second_layer==0)
    first_layer_cent    = pars.first_layer_centroids;
    second_layer_cent   = pars.centroids;
end

if isfield(pars, 'LCA_second_layer')==1 && pars.LCA_second_layer==1 && ...
    (isfield(pars, 'second_layer')==0 || pars.second_layer==0)
    first_layer_cent    = pars.centroids;
    second_layer_cent   = pars.second_layer_centroids;
end