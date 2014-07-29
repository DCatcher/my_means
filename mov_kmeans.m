%% The entrance of the program
function mov_kmeans(varargin)

close all
rand('state', 0);
randn('state', 0);

disp(varargin)
pars    = pars_initial(varargin);
pars    = parseArgs(varargin ,pars);

pars.result_save    = [pars.result_pre 'result_' pars.time_now];
pars.log_save  	 	= [pars.log_pre 'log_' pars.time_now];

diary(pars.log_save);
diary on;

disp(pars);
tic

for runno=1:pars.runno
	pars.now_rn 	= runno;

	pars 	= preprocess(pars);
	pars 	= run_kmeans(pars);
end

toc
diary off;

pars.X_total 	= [];
pars_old 		= pars;
save(pars.result_save, 'pars_old')
