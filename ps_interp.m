%load in an unw int, interpolate, and unwrap
%test
clear all;close all
getstuff
%Define these things:______________________________________________________
filtmode=1; %1 for bell filter, 2 for cone filter
gamma=0.4; %threshold for gamma0 mask (high values for gamma and alpha are good)
alpha=0.9; %threshold for correlation in individual int
rx=4; ry=rx*pixel_ratio; %bell radius (used in filtmode 1)
R=2; %cone radius (used in filtmode 2)
%__________________________________________________________________________

getstuff;
im     = sqrt(-1);
system(['mkdir ' rlkdir{1} 'orig']);
%load mask.cor
mskfile=[rlkdir{1} 'mask_4rlks.r4'];
fid=fopen( maskfilerlk{1},'r','native');
msk=fread(fid,[newnx,newny],'real*4');
% msk=flipud(msk');
fclose(fid);


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