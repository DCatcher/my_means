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
l1  = repmat(l1, pars.hidnum, 1);
l2  = repmat(l2, pars.LCA_second_hidnum, 1);
% a1  = g_non_line(u1, l1, pars.thresh_type, pars.first_g_pars);
% a2  = g_non_line(u2, l2, pars.thresh_type, pars.second_g_pars);
a1  = u1;
a2  = u2;

tic

for t=1:pars.LCA_iteration
    
    b2  = pars.second_layer_centroids * a1;
    u1  = pars.eta*(b1-G1*a1-pars.second_layer_centroids'*a2) + (1-pars.eta)*u1;
    u2  = pars.eta*(b2-G2*a2) + (1-pars.eta)*u2;

%     for i=1:m
%         ne1         = find(a1(:, i)~=0);
%         ne2         = find(a2(:, i)~=0);
%         b2(:,i)     = pars.second_layer_centroids(:, ne1) * a1(ne1, i);
%         u1(:,i)     = pars.eta*(b1(:,i) - G1(:, ne1)*a1(ne1, i) - pars.second_layer_centroids(ne2, :)'*a2(ne2, i)) + (1-pars.eta)*u1(:, i);
%         u2(:,i)     = pars.eta*(b2(:,i) - G2(:, ne2)*a2(ne2, i)) + (1-pars.eta)*u2(:,i);
%     end
    
%     a1  = g_non_line(u1, l1, pars.thresh_type, pars.first_g_pars);
%     a2  = g_non_line(u2, l2, pars.thresh_type, pars.second_g_pars);

    switch pars.thresh_type
        case 'soft'
            a1 = abs(u1)-l1;
            a1(logical(a1<0)) = 0;
            a1 = sign(u1).*a1;
            
            a2 = abs(u2)-l2;
            a2(logical(a2<0)) = 0;
            a2 = sign(u2).*a2;
        case 'hard'
            a1 = u1;
            a1(logical(abs(a1)<l1)) = 0;
            
            a2 = u2;
            a2(logical(abs(a2)<l2)) = 0;
        case 'hard+'
            a1 = u1;
            a1(logical(a1<l1)) = 0;
            
            a2 = u2;
            a2(logical(a2<l2)) = 0;
        case 'hard+sig'
            a1   = u1;
            a1(logical(a1<l1)) = 0;
            a1   = (pars.first_g_pars.A./(1 + exp(-(a1*pars.first_g_pars.mul))) - pars.first_g_pars.base)*pars.first_g_pars.Out_A;
            
            a2   = u2;
            a2(logical(a2<l2)) = 0;
            a2   = (pars.first_g_pars.A./(1 + exp(-(a2*pars.first_g_pars.mul))) - pars.first_g_pars.base)*pars.first_g_pars.Out_A;
    end
    
    l1  = pars.decay_rate * l1;
    l2  = pars.decay_rate * l2;
    l1(l1<pars.lambda)     = pars.lambda;    
    l2(l2<pars.second_lambda)     = pars.second_lambda;
    
end

toc

disp(sum(sum(a1~=0))/(size(a1,1)*size(a1,2)));
disp(sum(sum(a2~=0))/(size(a2,1)*size(a2,2)));

% disp(max(u2(:, 1:8)))
S1  = a1';
S2  = a2';