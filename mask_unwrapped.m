%Mask Unwrapped
clear all;close all
gammathresh=.1;
set_params

%load mask file
mask_file=maskfilerlk;

fid=fopen(mask_file,'r','native');
msk=fread(fid,[newnx,newny],'real*4');
fclose(fid);
figure;imagesc(msk);colorbar

ii=4;
  filename=[ints(ii).unwrlk];
  display(['Masking ' ints(ii).unwrlk '_no_filt'])
  fid         = fopen(filename,'r','native');
  [phs,count] = fread(fid,[newnx,newny],'real*4');
  fclose(fid);
   fid=fopen('phs_unmasked','w','native');
   fwrite(fid,phs,'real*4')
   fclose(fid)
  
   mask=ones(size(phs));
   mask(find(msk<gammathresh))=0;
  phs(find(msk<gammathresh))=0;
  
  fid=fopen('phs_masked1','w','native');
     fwrite(fid,phs,'real*4');
     fclose(fid);

  fid=fopen('mask1','w','native');
     fwrite(fid,mask,'real*4');
     fclose(fid);

system(['mag_phs2rmg mask1 phs_masked1 out1 4233'])
% Split back to r4
% clear all;close all
% getstuff
% for ii=1%:nints
%     movefile(ints(ii).unwrlk{1},[ints(ii).unwrlk{1} '_o']); 
%    system(['rmg2mag_phs ' ints(ii).unwrlk{1} '_o ' ints(ii).unwrlk{1} ' jnk ' num2str(2840)]);
% end