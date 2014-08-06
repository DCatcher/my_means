%% Do some preprocessing, NOT ONLY read and sample the data!
% the data_path should include these things:
%   IMAGES  : cells of N1 * N2 * num_frame
function pars = preprocess(pars)

if pars.from_existed_data==1
	load(pars.existed_data);

	pars.centroids 	= pars_old.centroids;
    
    %add to satisfy the second layer
    pars.old_frame_num      = pars_old.frame_num;
    pars.old_patchsize      = pars_old.patchsize;
    
	clear('pars_old');
else

	pars.centroids 	= randn(pars.hidnum,pars.patchsize^2*pars.frame_num)*0.1;

end

if isfield(pars, 'soft_coding')==1 && pars.soft_coding==1
    pars.max_L  = min(4*pars.L1, pars.hidnum);
end

if pars.second_layer==1
    if pars.time_type==1 && pars.frame_num~=pars.old_frame_num*2 && pars.time_bigger==1
        error('frame num should be twice the old frame num!\n');
    end
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
    
    if isfield(pars, 'twin_present')==0 || pars.twin_present==0
        tmp_t_win       = tmp_t_win(pars.frame_num+1:end);
    else
        tmp_t_win       = tmp_t_win(1:pars.frame_num);
    end
    
    pars.t_win      = repmat(tmp_t_win, pars.patchsize^2, 1);
    pars.t_win      = pars.t_win(:);
    pars.X_total    = bsxfun(@times, pars.X_total, pars.t_win);
end

pars.X_total 	= pars.X_total';
pars.X_total 	= bsxfun(@minus, pars.X_total, mean(pars.X_total,1));    
pars.X_total    = bsxfun(@rdivide, pars.X_total, sqrt(sum(pars.X_total.^2, 2)));

if pars.second_layer==1
    if pars.from_existed_data ==0
        error('Second layer must use first layer data!');
    end

    load(pars.existed_data); 

    pars.first_layer_centroids      = pars_old.centroids;
    pars.first_layer_L              = pars_old.L1;
    pars.first_layer_hidnum         = pars_old.hidnum;
    
    clear pars_old    
    
    X_total_reshape     = reshape(pars.X_total, pars.samplesize, ...
                            pars.patchsize^2, pars.frame_num);
                        
    if pars.time_bigger==0
        temp    = pars.first_layer_centroids*pars.X_total';

        pars.second_layer_L     = pars.L1;
        pars.L1                 = pars.first_layer_L;
        [pars.X_total, not_use, pars]     = resp_with_Labels(temp, pars);
        pars.L1                 = pars.second_layer_L;
    end
    
    if pars.time_bigger==1
        if pars.time_type==1
            pars.time_sepa_num      = 2;
            pars.time_sepa_inter    = [1:pars.old_frame_num;pars.old_frame_num+1:2*pars.old_frame_num];
            pars.X_total_inter      = [1:pars.first_layer_hidnum;pars.first_layer_hidnum+1:2*pars.first_layer_hidnum];
            tmp_size_centroids      = size(pars.first_layer_centroids, 2);
            pars.centroids_inter    = [1:tmp_size_centroids;tmp_size_centroids+1:tmp_size_centroids*2];
        end
        
        tmp_X_total     = zeros(pars.samplesize, pars.first_layer_hidnum*pars.time_sepa_num);
        for i=1:pars.time_sepa_num
            tmp_X_total_part    = X_total_reshape(:,:,pars.time_sepa_inter(i, :));
            tmp_X_total_part    = reshape(tmp_X_total_part, size(tmp_X_total_part, 1), size(tmp_X_total_part, 2)*size(tmp_X_total_part, 3));
            tmp_X_total_part 	= bsxfun(@minus, tmp_X_total_part, mean(tmp_X_total_part,1));    
            tmp_X_total_part    = bsxfun(@rdivide, tmp_X_total_part, sqrt(sum(tmp_X_total_part.^2, 2)));            
            temp                = pars.first_layer_centroids * tmp_X_total_part';
            pars.second_layer_L = pars.L1;
            pars.L1             = pars.first_layer_L;
            [tmp_for_error, not_use, pars]     = resp_with_Labels(temp, pars);
            tmp_X_total(:,pars.X_total_inter(i,:))  = tmp_for_error;
            pars.L1             = pars.second_layer_L;
        end
        
        pars.X_total    = tmp_X_total;
    end

    r_tmp           = rand(pars.hidnum, size(pars.X_total, 2));
    g_tmp           = var(pars.X_total(1,:))/var(r_tmp(:));
    pars.centroids  = (r_tmp-0.5)*sqrt(g_tmp) + mean(pars.X_total(1,:));            
end