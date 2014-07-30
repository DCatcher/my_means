%% Initial the parameters
function pars = pars_initial(varargin)

pars 				= struct();

pars.L1 			= 1;
pars.frame_num 		= 1;
pars.patchsize 		= 16;
pars.samplesize 	= 100000;

pars.display 		= 0;
pars.display_inter 	= 1;

pars.display_vertical 	= 1;
pars.vertical_figure 	= 2;
pars.display_horizont 	= 1;
pars.horizont_figure 	= 3;
pars.display_result 	= 1;
pars.result_figure 		= 1;

tmp_clock       	= clock;
pars.time_now   	= [int2str(tmp_clock(1)) int2str(tmp_clock(2)) int2str(tmp_clock(3)) 'T' int2str(tmp_clock(4)) int2str(tmp_clock(5))];
pars.result_pre 	= 'd:/dataset/Kmeans_data/result/';
pars.log_pre    	= 'd:/dataset/Kmeans_data/logs/';

pars.from_existed_data 	= 0;
pars.existed_data 		= [pars.result_pre ''];

pars.data_path 		= 'd:\dataset\Hollywood2\mat\my_IMAGES';

pars.iterations 	= 100;
pars.hidnum 		= 100;
pars.centroids 		= [];
pars.BATCH_SIZE 	= 1000;
pars.resample_size 	= 50000;
pars.runno 			= 1;

pars.show_num 		= 25;
pars.row_num 		= 20;
pars.max_frames 	= 4;
pars.max_show       = 40;
pars.loop_show      = 0;

pars.cal_loss       = 0;
% pars.fix_sparsity   = 1;