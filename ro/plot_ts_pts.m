function values=plot_ts_pts(px,py)
%example:
%px=[1076 1015 1135 693 637 699 722];
%py=[1655 1504 1498 2069 1980 2065 2152];



set_params
load(ts_paramfile);

ndates         = length(dates);
nints          = length(ints);
[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

newnx = floor(nx./rlooks);
newny = floor(ny./alooks); 

[X,Y] = meshgrid(1:newnx,1:newny);

dn    = [dates.dn];
dn    = dn-dn(1);


l=1;%4 rlooks, here
for i=1:ndates
    fid=fopen([dates(i).unwrlk{l} '_filtdiff'],'r');
    for j=1:length(px)
        fseek(fid,0,-1);
        tmp=fread(fid,(newnx(l)*(py(j)-1)+px(j)-1),'real*4');
        values(i,j)=fread(fid,1,'real*4');
    end
    fclose(fid);
end


    
