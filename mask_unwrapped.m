%Mask Unwrapped
clear all;close all
gammathresh=.4;
getstuff

%load mask file
mask_file=maskfilerlk{1};

fid=fopen(mask_file,'r','native');
msk=fread(fid,[newnx,newny],'real*4');
fclose(fid);
figure;imagesc(msk);colorbar

parfor ii=1%:nints
  filename=[ints(ii).unwrlk{1}];
  display(['Masking ' ints(ii).name])
  fid         = fopen(filename,'r','native');
  [phs,count] = fread(fid,[newnx,newny],'real*4');
  fclose(fid);
   fid=fopen('phs_unmasked','w','native');
   fwrite(fid,phs,'real*4')
   fclose(fid)
  
  phs(find(msk<gammathresh))=0;
  
  fid=fopen('phs_masked','w','native');
     fwrite(fid,phs,'real*4');
     fclose(fid);

   system(['mag_phs2rmg phs_unmasked phs_masked ' ints(ii).unwrlk{1} ' ' num2str(newnx)]);
  
end


% Split back to r4
% clear all;close all
% getstuff
% for ii=1%:nints
%     movefile(ints(ii).unwrlk{1},[ints(ii).unwrlk{1} '_o']); 
%    system(['rmg2mag_phs ' ints(ii).unwrlk{1} '_o ' ints(ii).unwrlk{1} ' jnk ' num2str(2840)]);
% end