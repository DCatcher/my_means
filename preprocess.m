%% Do some preprocessing, NOT ONLY read and sample the data!
% the data_path should include these things:
%   IMAGES  : cells of N1 * N2 * num_frame
function pars = preprocess(pars)

if pars.from_existed_data==1
	load(pars.existed_data);

	pars.centroids 	= pars_old.centroids;

	clear('pars_old');
else

	pars.centroids 	= randn(pars.hidnum,pars.patchsize^2*pars.frame_num)*0.1;

end

load(pars.data_path);

% num_images 	= floor(size(IMAGES,3)/nf)*(nf-pars.frame_num+1);
num_images      = length(IMAGES);
num_patches     = pars.samplesize;
sz              = pars.patchsize;
pars.X_total 	= zeros(sz^2*pars.frame_num, num_patches);
totalsamples 	= 0;

for ii=1:num_images
    IMG_now     = IMAGES{ii};
    image_size1 = size(IMG_now,1);
    image_size2 = size(IMG_now,2);
    image_size3 = size(IMG_now,3);
    BUFF 		= 4;
    
    this_image  = IMG_now;
    
    getsample 	= floor(num_patches/num_images);

    if ii==num_images, getsample = num_patches-totalsamples; end

    for j=1:getsample
        r 	= BUFF+ceil((image_size1-sz-2*BUFF)*rand);
        c 	= BUFF+ceil((image_size2-sz-2*BUFF)*rand);
        z   = randi(image_size3 - pars.frame_num);

        totalsamples 	= totalsamples + 1;
        temp 			= reshape(this_image(r:r+sz-1,c:c+sz-1, z:z+pars.frame_num-1),sz^2*pars.frame_num,1);

        pars.X_total(:,totalsamples) 	= temp;
    end
end

if pars.gauss_win==1
    tmp_G_win       = fspecial('gaussian', [pars.patchsize, pars.patchsize], pars.gwin_delta);
    tmp_G_win       = tmp_G_win(:);
    pars.G_win      = repmat(tmp_G_win, pars.frame_num, 1);
    pars.X_total    = bsxfun(@times, pars.X_total, pars.G_win);
end

if pars.time_win==1
    tmp_t_win       = fspecial('gaussian', [1, pars.frame_num*2], pars.twin_delta);
    tmp_t_win       = tmp_t_win(pars.frame_num+1:end);
    pars.t_win      = repmat(tmp_t_win, pars.patchsize^2, 1);
    pars.t_win      = pars.t_win(:);
    pars.X_total    = bsxfun(@times, pars.X_total, pars.t_win);
end

pars.X_total 	= pars.X_total';
pars.X_total 	= bsxfun(@minus, pars.X_total, mean(pars.X_total,1));    
pars.X_total    = bsxfun(@rdivide, pars.X_total, sqrt(sum(pars.X_total.^2, 2)));