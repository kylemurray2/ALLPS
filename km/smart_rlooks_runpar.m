clear all;close all
getstuff

fid1=fopen(gammafile,'r');
im=sqrt(-1);
thresh=2;

newnx=floor(nx./rlooks)
newny=floor(ny./alooks);


win=ones(alooks,rlooks);
win=win/sum(win(:));
rangevec=[0:newnx-1]*rlooks+1;
intcorthresh=0.7;
l=1;

tic
parfor k=1:nints
    smart_rlooks_par(k,newnx,newny,win,rangevec,intcorthresh,l,fid1)
end
toc

    frewind(fid1);
fclose(fid1);
