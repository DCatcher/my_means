%% Calculate the non-linearity    
function a = g_non_line(u, theta, thresh_type, g_pars)

M = size(u,1);

switch thresh_type
    case 'soft'
        a = abs(u)-repmat(theta,M,1);
        a(logical(a<0)) = 0;
        a = sign(u).*a;
    case 'hard'
        a = u;
        a(logical(abs(a)<repmat(theta,M,1))) = 0;
    case 'hard+'
        a = u;
        a(logical(a<repmat(theta,M,1))) = 0;
    case 'hard+sig'
        a   = u;
        a(logical(a<repmat(theta,M,1))) = 0;
        a   = (g_pars.A./(1 + exp(-(a*g_pars.mul))) - g_pars.base)*g_pars.Out_A;
%         a = (1./(1 + exp(-(a*20))) - 0.5)*0.5;
end