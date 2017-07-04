function [allstuff]=cutout_chunk(flag,lft,top,w,len)
%%%filtype depends on flag:
%1 = ints
%2 = unws
%3 = dates

rgt=lft+w-1;
bot=top+len-1;
set_params
load(ts_paramfile);
[lft rgt top bot]
ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks);
newny   = floor(ny./alooks);

im=sqrt(-1);
%for l=1:length(rlooks)
l=1;

switch flag
    case 1
        allstuff=zeros(nints,len,w);
        for k=1:nints
            fidi=fopen(ints(k).intrlk{l},'r');
            tmp=fread(fidi,[newnx*2,newny],'real*4');
            tmp=tmp';
            tmp=angle(tmp(:,1:2:end)+im*tmp(:,2:2:end));
            allstuff(k,:,:)=tmp(top:bot,lft:rgt);
        end
    case 2
        allstuff=zeros(nints,len,w);
        for k=1:nints
            fidi=fopen(ints(k).unwrlk{l},'r');
            tmp=fread(fidi,[newnx,newny*2],'real*4');
            tmp=tmp(:,2:2:end)';
            allstuff(k,:,:)=tmp(top:bot,lft:rgt);
        end
    case 3
        allstuff=zeros(ndates,len,w);
        for k=1:ndates
            fidi=fopen(dates(k).unwrlk{l},'r');
            tmp=fread(fidi,[newnx,newny],'real*4');
            tmp=tmp';
            allstuff(k,:,:)=tmp(top:bot,lft:rgt);           
        end
end
