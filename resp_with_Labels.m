%% Calculate the nearest centroids
function [S, all_labels]=resp_with_Labels(temp,iter)
	[hidnum,m]=size(temp);
	S=zeros(size(temp))';
    all_labels  = [];
	for i=1:iter
		[val,labels] = max(temp);
        all_labels   = [all_labels; labels];
		S1 = sparse(1:m,labels,1,m,hidnum,m);
		temp = temp-S1'*1e10;
		S=S+S1;
	end
