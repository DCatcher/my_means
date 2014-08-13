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
l1  = 0.5*max(abs(b1));
l2  = 0.5*l1;
a1  = g_non_line(u1, l1, pars.thresh_type, pars.first_g_pars);
a2  = g_non_line(u2, l2, pars.thresh_type, pars.second_g_pars);

for t=1:pars.LCA_iteration
    u1  = pars.eta*(b1-G1*a1-pars.second_layer_centroids'*a2) + (1-pars.eta)*u1;
    u2  = pars.eta*(b2-G2*a2) + (1-pars.eta)*u2;
    
    a1  = g_non_line(u1, l1, pars.thresh_type, pars.first_g_pars);
    a2  = g_non_line(u2, l2, pars.thresh_type, pars.second_g_pars);
    b2  = pars.second_layer_centroids * a1;
    
    l1  = pars.decay_rate * l1;
    l2  = pars.decay_rate * l2;
    l1(l1<pars.lambda)     = pars.lambda;    
    l2(l2<pars.second_lambda)     = pars.second_lambda;
end

% disp(max(u2(:, 1:8)))
S1  = a1';
S2  = a2';