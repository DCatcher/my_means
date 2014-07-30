%% Do some preprocessing, NOT ONLY read and sample the data!
% the data_path should include these things:
%   IMAGES  : N1 * N2 * (num_video*num_frame)
%       nf  : num_frame
function pars = preprocess(pars)

if pars.from_existed_data==1
	load(pars.existed_data);

	pars.centroids 	= pars_old.centroids;

	clear('pars_old');
else

	pars.centroids 	= randn(pars.hidnum,pars.patchsize^2*pars.frame_num)*0.1;

end

load(pars.data_path);

num_images 	= floor(size(IMAGES,3)/nf)*(nf-pars.frame_num+1);
image_size1 = size(IMAGES,1);
image_size2 = size(IMAGES,2);
sz 			= pars.patchsize;
BUFF 		= 4;
num_patches	= pars.samplesize;

totalsamples 	= 0;
pars.X_total 	= zeros(sz^2*pars.frame_num, num_patches);
for ii=1:nf:(size(IMAGES,3)-nf)
    for i=ii:1:ii+nf-pars.frame_num
        this_image 	=IMAGES(:,:,i:(i+pars.frame_num-1));
        getsample 	= floor(num_patches/num_images);

        if size(IMAGES, 3) - i< pars.frame_num, getsample = num_patches-totalsamples; end

        for j=1:getsample
            r 	=BUFF+ceil((image_size1-sz-2*BUFF)*rand);
            c 	=BUFF+ceil((image_size2-sz-2*BUFF)*rand);

            totalsamples 	= totalsamples + 1;
            temp 			=reshape(this_image(r:r+sz-1,c:c+sz-1, :),sz^2*pars.frame_num,1);

            pars.X_total(:,totalsamples) 	= temp - mean(temp);
        end
    end  
end

pars.X_total 	= pars.X_total';
pars.X_total 	= bsxfun(@minus, pars.X_total, mean(pars.X_total,1));    
pars.X_total    = bsxfun(@rdivide, pars.X_total, sqrt(sum(pars.X_total.^2, 2)));