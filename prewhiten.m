%% Prewhiten the images
% 	The input_path should include a 3-D array 'all_pic_g', and a integer 'frames_per_video'
%		all_pic_g : N1 * N2 * (num_video*num_frame), double
%           nf    : num_frame
function prewhiten(input_path, output_path)

% load d:\dataset\Hollywood2\mat\yk_images_raw
load(input_path);

all_pic_g   = (all_pic_g-mean(mean(mean(all_pic_g))));
all_pic_g   = all_pic_g/sqrt((mean(mean(mean(all_pic_g.^2)))));

N1 = size(all_pic_g, 1);
N2 = size(all_pic_g, 2);
M=size(all_pic_g, 3);

IMAGES=zeros(N1,N2,M);
[fx, fy]=meshgrid(-N1/2:N1/2-1, -N2/2:N2/2-1);
rho=sqrt(fx.*fx+fy.*fy);
f_0=0.4*mean([N1,N2]);
filt=rho.*exp(-(rho/f_0).^4);

for i=1:M
  image=all_pic_g(:,:,i);
  If=fft2(image);
  imagew=real(ifft2(If.*(fftshift(filt))'));
  IMAGES(:,:,i)=reshape(imagew,N1,N2,1);
end

IMAGES=sqrt(0.1)*IMAGES/sqrt(mean(mean(var(IMAGES))));

% save d:\dataset\Hollywood2\mat\my_IMAGES IMAGES
save(output_path,'IMAGES', 'nf');