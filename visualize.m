%% Visualize the result
function visualize(pars)

tmp_centroids               = get_centroids(pars);
cent_global_norm_all        = tmp_centroids./(ones(size(tmp_centroids,2), 1)*max(abs(tmp_centroids')))';
% cent_global_norm_all        = cent_global_norm_all(pars.counts>0, :);

tmp_length                  = min(size(pars.centroids, 1), pars.max_show);
if size(pars.centroids, 1) > pars.max_show
    cent_global_norm            = cent_global_norm_all(randsample(size(cent_global_norm_all, 1), tmp_length), :);
else
    cent_global_norm            = cent_global_norm_all;
end

frame_num_now   = min(pars.frame_num, pars.max_frames);

if pars.display_result==1
    if ~ishandle(pars.result_figure)
        pars.result_figure 		= figure('name', 'result choosen');
    end
	set(0, 'CurrentFigure', pars.result_figure);
	cent_show       = [];
	pars.show_label    = pars.show_label./(ones(size(pars.show_label,2), 1)*max(abs(pars.show_label')))';

	for j=1:floor(size(pars.show_label,1)/pars.row_num)
		for k=1:frame_num_now
			cent_show   = [cent_show;pars.show_label((j-1)*pars.row_num+1:j*pars.row_num,((k-1)*pars.patchsize^2+1):(k*pars.patchsize^2))];
		end
	end
	plotrf(cent_show', pars.row_num);
end

while (1)
    if pars.display_vertical==1
        if ~ishandle(pars.vertical_figure)
            pars.vertical_figure 	= figure('name', 'vertical');
        end
        set(0, 'CurrentFigure', pars.vertical_figure);
        cent_show       = [];

        for j=1:floor(tmp_length/pars.row_num)
            for k=1:frame_num_now
                cent_show   = [cent_show;cent_global_norm((j-1)*pars.row_num+1:j*pars.row_num,((k-1)*pars.patchsize^2+1):(k*pars.patchsize^2))];
            end
        end

        plotrf(cent_show', pars.row_num);
    end

    if pars.display_horizont==1
        if ~ishandle(pars.horizont_figure)
            pars.horizont_figure    = figure('name', 'horizont');
        end
        set(0, 'CurrentFigure', pars.horizont_figure);
        cent_show       = [];

        for j=1:tmp_length
            for k=1:frame_num_now
                cent_show   = [cent_show;cent_global_norm(j,((k-1)*pars.patchsize^2+1):(k*pars.patchsize^2))];
            end
        end

        plotrf(cent_show', pars.row_num); 
    end
    
    if pars.loop_show==1
        cent_global_norm    = cent_global_norm_all(randsample(size(cent_global_norm_all, 1), tmp_length), :);
        pause;
    else
        break;
    end
end

% disp(pars);
% pause;

pause(0.01);