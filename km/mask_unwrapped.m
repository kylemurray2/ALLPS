%Mask Unwrapped
clear all;close all
gammathresh=.2;
getstuff

%load mask file
mask_file=maskfilerlk{1};

fid=fopen(mask_file,'r','native');
msk=fread(fid,[newnx,newny],'real*4');
fclose(fid);
% msk=fliplr(msk');
figure;imagesc(msk);colorbar

for ii=1:nints
  filename=[ints(ii).unwrlk{1}];
  display(['Masking ' ints(ii).name])
  fid         = fopen(filename,'r','native');
  [rmg,count] = fread(fid,[newnx,newny*2],'real*4');
  status      = fclose(fid);
  phs         = (rmg(1:newnx,2:2:newny*2));
%   phs=fliplr(phs');
   fid=fopen('phs_unmasked','w','native');
   fwrite(fid,phs,'real*4')
   fclose(fid)
%   figure;imagesc(phs);colorbar
  
  phs(msk<gammathresh)=0;
  
  fid=fopen('phs_masked','w','native');
     fwrite(fid,phs,'real*4')
     fclose(fid);

   system(['mag_phs2rmg phs_unmasked phs_masked ' ints(ii).unwrlk{1} ' ' num2str(newnx)]);
  
end