function [allints,alldates,avgslc]=cutout_chunk(lft,top,w,l)
%%%acts on int file

rgt=lft+w-1;
bot=top+l-1;
set_params
load(ts_paramfile);
[lft rgt top bot]
ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);
[newnx newny]
allints=zeros(nints,l,w);
alldates=zeros(nints,l,w);
l=1;
for l=1:length(rlooks)
  for k=1:nints     
ints(k).unwrlk{l};
      fidi=fopen(ints(k).unwrlk{l},'r');
tmp=fread(fidi,[newnx,newny],'real*4');
%tmpamp=tmp(:,1:2:end)';
tmp=tmp';
%tmp=tmp(:,2:2:end)';
%allamp(k,:,:)=tmpamp(top:bot,lft:rgt);
allints(k,:,:)=tmp(top:bot,lft:rgt);
      fclose(fidi);
 
 
  end
   fid=fopen('TS/avgslc_4rlks.r4','r');
    tmp=fread(fidi,[newnx,newny],'real*4');
tmp=tmp';
avgslc=tmp(top:bot,lft:rgt);
fclose(fid);
[top bot lft rgt];
for k=1:ndates
fidi=fopen(dates(k).unwrlk{l},'r');
tmp=fread(fidi,[newnx,newny],'real*4');
tmp=tmp';
alldates(k,:,:)=tmp(top:bot,lft:rgt);
fclose(fidi);
end
end
save allintcrop allints alldates avgslc
