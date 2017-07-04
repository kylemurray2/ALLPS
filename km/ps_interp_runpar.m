%load in an unw int, interpolate, and unwrap
%test
clear all;close all

%Define these things:______________________________________________________
gamma=0.3; %threshold for gamma0 mask
alpha=0.5; %threshold for correlation in individual int
    %(high values for gamma and alpha are good)
R=5; %define radius of filter
%__________________________________________________________________________

getstuff;
im     = sqrt(-1);
system(['mkdir ' rlkdir{1} 'orig']);
%load mask.cor
      mskfile=[rlkdir{1} 'mask_4rlks.r4'];
      fid=fopen( maskfilerlk{1},'r','native');
      msk=fread(fid,[newnx,newny],'real*4');
      msk=flipud(msk');
      fclose(fid);
      tic
parfor ii=1:nints
ps_interp_par(ii,gamma,alpha,R,im,msk)
end
toc

% system(['mv ' rlkdir{1} '*_orig ' rlkdir{1} 'orig/']);

%move orig files back 
% for kk=1:nints
%        system(['mv ' rlkdir{1} 'flat_' ints(kk).name '_4rlks.int_orig ' ints(ii).flatrlk{1}]);
% end