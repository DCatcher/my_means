%% Prewhiten the images
% 	The input_path should include a 3-D array 'all_pic_g', and a integer 'frames_per_video'
%		all_pic_g : cells of N1 * N2 * num_frame, double
%   Output will be:
%       IMAGES    : cells of N1 * N2 * num_frame, withened, double.
function prewhiten(input_path, output_path)

% load d:\dataset\Hollywood2\mat\yk_images_raw
load(input_path);

% Len_now = length(IMAGES);
Len_now = 10;
IMAGES  = cell(1, Len_now);

for ii=1:Len_now
    IM_now  = all_pic_g{ii};
    
    N1      = size(IM_now, 1);
    N2      = size(IM_now, 2);
    M       =size(IM_now, 3);

    IMAGES_now  = zeros(N1,N2,M);
    [fx, fy]    = meshgrid(-N1/2:N1/2-1, -N2/2:N2/2-1);
    rho         = sqrt(fx.*fx+fy.*fy);
    f_0         = 0.4*mean([N1,N2]);
    filt        = rho.*exp(-(rho/f_0).^4);

    for i=1:M
        image   = IM_now(:,:,i);
        image   = image - mean(mean(image));
        image   = image/sqrt(mean(mean(image.^2)));  

        If      = fft2(image);
        imagew  = real(ifft2(If.*(fftshift(filt))'));
        
        IMAGES_now(:,:,i)   = reshape(imagew,N1,N2,1);
    end
    
    IMAGES{ii}      = IMAGES_now;
    all_pic_g{ii}   = [];
end

% save d:\dataset\Hollywood2\mat\my_IMAGES IMAGES
save(output_path,'IMAGES');