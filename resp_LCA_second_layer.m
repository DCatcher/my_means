%% For LCA second layer
function [S1,S2,pars]= resp_LCA_second_layer(temp, pars)

baktemp     = temp;
[hidnum,m]  = size(temp);

G1  = pars.cent_corr - eye(pars.hidnum);
b1  = baktemp;
G2  = pars.second_layer_cent_corr - eye(pars.LCA_second_hidnum);
b2  = zeros(pars.LCA_second_hidnum, m);
G12 = pars.centroids *pars.second_layer_centroids_expand';

u1  = zeros(pars.hidnum, m);
u2  = zeros(pars.LCA_second_hidnum, m);
l   = 0.5*max(abs(b1));
a1  = g_non_line(u1, l);
a2  = g_non_line(u2, l);

for t=1:pars.LCA_iteration
    u1  = pars.eta*(b1-G1*a1-G12*a2) + (1-pars.eta)*u1;
    u2  = pars.eta*(b2-G2*a2) + (1-pars.eta)*u2;
    
    a1  = g_non_line(u1, l, pars.thresh_type);
    a2  = g_non_line(u2, l, pars.thresh_type);
    b2  = pars.second_layer_centroids * a1;
    
    l   = pars.decay_rate * l;
    l(l<pars.lambda)     = pars.lambda;    
end

S1  = a1';
S2  = a2';