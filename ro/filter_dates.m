function filter_dates(infile,nx,ny,rx,ry,maskfile)
%set_params
%load(ts_paramfile)

fid1   = fopen(infile,'r');
fid2   = fopen([infile '_filt'],'w');
fid3   = fopen([infile '_filtdiff'],'w');
fid5   = fopen(maskfile,'r');
im     = sqrt(-1);

rx2=floor(rx*2);
ry2=floor(ry*2);
gausx = exp(-[-rx2:rx2].^2/rx^2);
gausy = exp(-(-ry2:ry2).^2/ry^2);
gaus  = gausy'*gausx;
gaus = gaus-min(gaus(:));
gaus  = gaus/sum(gaus(:));

[a,count] = fread(fid1,[nx,ny],'real*4');
phs=a';

[a,count] = fread(fid5,[nx,ny],'real*4');
a           = a==1;
gam    = a';

bad      = ~gam;
pmask=phs;
pmask(bad) = 0;

mfilt=conv2(double(gam),gaus,'same');
pfilt=conv2(pmask,gaus,'same');
%pfilt    = imfilter(pmask,gaus,'same');
%mfilt    = imfilter(a',gaus,'same');

pfilt   = pfilt./mfilt;
pfilt(phs==0)=0;
sum(isnan(pfilt(:)))
pfilt(isnan(pfilt))=phs(isnan(pfilt));
phsdiff = phs-pfilt;
fwrite(fid2,pfilt','real*4');
fwrite(fid3,phsdiff','real*4');

%return
fclose('all');


