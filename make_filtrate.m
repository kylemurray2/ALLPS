%make a full resolution rate file from rates_4 and filter it
unw_in='rates_4'
%Geocode a 4rlks unw file
froot=unw_in;
set_params
load(ts_paramfile);
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);
%Step 1. Create rmg file
amp_img = unw_in;
phs_img = unw_in;
rmg_in = [froot '_4rlks.unw'];

mysys(['mag_phs2rmg ' amp_img ' ' phs_img ' ' rmg_in ' ' num2str(newnx)])
% [nx2,ny2] = load_rscs([oldintdir 'radar.hgt'],'WIDTH','FILE_LENGTH');

aff1=1/rlooks;
aff2=aff1/pixel_ratio;

%Step 2. Create a 2-looks version
%first, write out a rect_back.in file
fid=fopen('rect_back.in','w');

fprintf(fid,['Input Image File Name  (-) = ' rmg_in '      ! dimension of file to be rectified\n']);
fprintf(fid,['Output Image File Name (-) = rates.unw       ! dimension of output\n']);
fprintf(fid,['Input Dimensions       (-) = ' num2str(newnx) ' ' num2str(newny)  ' ! across, down\n']);
fprintf(fid,['Output Dimensions      (-) = ' num2str(nx) ' ' num2str(ny)  ' ! across, down\n']);
fprintf(fid,['Affine Matrix Row 1    (-) = ' num2str(aff1) ' 0      ! a b\n']);
fprintf(fid,['Affine Matrix Row 2    (-) = 0 ' num2str(aff2)  '     ! c d\n']);
fprintf(fid,['Affine Offset Vector   (-) = 0 0             ! e f\n']);
fprintf(fid,['File Type              (-) = RMG             ! [RMG, COMPLEX]\n']);
fprintf(fid,['Interpolation Method   (-) = Bilinear        ! [NN, Bilinear, Sinc]\n']);

%now, use rect rect_back.in to up look the 4looks rates file
mysys(['rect rect_back.in'])
%now we have a rates.unw to geocode

