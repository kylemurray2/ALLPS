%load in an unw int, interpolate, and unwrap
%test
clear all;close all
set_params
load(ts_paramfile)

%Define these things:______________________________________________________
filtmode=1; %1 for bell filter, 2 for cone filter
gamma=0.4; %threshold for gamma0 mask (high values for gamma and alpha are good)
alpha=0.3; %threshold for correlation in individual int
ry=5; rx=ry; %bell radius (used in filtmode 1)
%__________________________________________________________________________

im     = sqrt(-1);
system(['mkdir ' rlkdir 'orig']);
%load mask.cor
mskfile=[rlkdir 'mask_4rlks.r4'];
fid=fopen( maskfilerlk,'r','native');
msk=fread(fid,[newnx,newny],'real*4');
% msk=flipud(msk');
fclose(fid);
figure;imagesc(msk);colorbar

parfor ii=1:nints
%     if(~exist([ints(ii).flatrlk{1} '_bell']))
        par_ps_interp(ii,msk,gamma,alpha,rx,ry)
%     end
end
        
% system(['mv ' rlkdir{1} '*_orig ' rlkdir{1} 'orig/']);

%move orig files back
% for kk=1:nints
%        system(['mv ' rlkdir{1} 'flat_' ints(kk).name '_4rlks.int_orig ' ints(ii).flatrlk{1}]);
% end