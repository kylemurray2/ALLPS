function geocode(unw_in, out_2lks)

getstuff
if rlooks==2
%     system('cp int_????????_????????/????????-????????_2rlks.cor.rsc rates_2.rsc')
%     lookup_file = 'GEO/geomap_2rlks.trans';
% 	system(['geocode.pl ' lookup_file ' rates_2 ' out_2lks]);


froot=unw_in;
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','YMAX','WAVELENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);

%Step 1. Create rmg file
    amp_img = unw_in;
    phs_img = unw_in;
    rmg_in = [froot '_4rlks.unw'];

mysys(['mag_phs2rmg ' amp_img ' ' phs_img ' ' rmg_in ' ' num2str(newnx)])
[nx2,ny2] = load_rscs([oldintdir 'radar_2rlks.hgt'],'WIDTH','FILE_LENGTH');

aff1=1;
aff2=aff1/pixel_ratio;

%Step 2. Create a 2-looks version
    %first, write out a rect_back.in file
fid=fopen('rect_back.in','w');

fprintf(fid,['Input Image File Name  (-) = ' rmg_in '      ! dimension of file to be rectified\n']);
fprintf(fid,['Output Image File Name (-) = rates_2.unw       ! dimension of output\n']);
fprintf(fid,['Input Dimensions       (-) = ' num2str(newnx) ' ' num2str(newny)  ' ! across, down\n']);
fprintf(fid,['Output Dimensions      (-) = ' num2str(nx2) ' ' num2str(ny2)  ' ! across, down\n']);
fprintf(fid,['Affine Matrix Row 1    (-) = ' num2str(aff1) ' 0      ! a b\n']);
fprintf(fid,['Affine Matrix Row 2    (-) = 0 ' num2str(aff2)  '     ! c d\n']);
fprintf(fid,['Affine Offset Vector   (-) = 0 0            ! e f\n']);
fprintf(fid,['File Type              (-) = RMG             ! [RMG, COMPLEX]\n']);
fprintf(fid,['Interpolation Method   (-) = NN             ! [NN, Bilinear, Sinc]\n']);

    %now, use rect rect_back.in to up look the 4looks rates file
mysys(['rect rect_back.in'])
   %now we have a rates_2.unw to geocode 
   
%Step 3. Geocode
system('cp int_????????_????????/????????-????????_2rlks.cor.rsc rates_2.unw.rsc')
lookup_file = 'GEO/geomap_2rlks.trans';
command = ['geocode.pl ' lookup_file ' rates_2.unw ' out_2lks];
mysys(command)














else

%Geocode a 4rlks unw file
froot=unw_in;
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','YMAX','WAVELENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);

%Step 1. Create rmg file
    amp_img = unw_in;
    phs_img = unw_in;
    rmg_in = [froot '_4rlks.unw'];

mysys(['mag_phs2rmg ' amp_img ' ' phs_img ' ' rmg_in ' ' num2str(newnx)])
[nx2,ny2] = load_rscs([oldintdir 'radar_2rlks.hgt'],'WIDTH','FILE_LENGTH');

aff1=.5;
aff2=aff1/pixel_ratio;

%Step 2. Create a 2-looks version
    %first, write out a rect_back.in file
fid=fopen('rect_back.in','w');

fprintf(fid,['Input Image File Name  (-) = ' rmg_in '      ! dimension of file to be rectified\n']);
fprintf(fid,['Output Image File Name (-) = rates_2.unw       ! dimension of output\n']);
fprintf(fid,['Input Dimensions       (-) = ' num2str(newnx) ' ' num2str(newny)  ' ! across, down\n']);
fprintf(fid,['Output Dimensions      (-) = ' num2str(nx2) ' ' num2str(ny2)  ' ! across, down\n']);
fprintf(fid,['Affine Matrix Row 1    (-) = ' num2str(aff1) ' 0      ! a b\n']);
fprintf(fid,['Affine Matrix Row 2    (-) = 0 ' num2str(aff2)  '     ! c d\n']);
fprintf(fid,['Affine Offset Vector   (-) = 0 0            ! e f\n']);
fprintf(fid,['File Type              (-) = RMG             ! [RMG, COMPLEX]\n']);
fprintf(fid,['Interpolation Method   (-) = NN             ! [NN, Bilinear, Sinc]\n']);

    %now, use rect rect_back.in to up look the 4looks rates file
mysys(['rect rect_back.in'])
   %now we have a rates_2.unw to geocode 
   
%Step 3. Geocode
system('cp int_????????_????????/????????-????????_2rlks.cor.rsc rates_2.unw.rsc')
lookup_file = 'GEO/geomap_2rlks.trans';
command = ['geocode.pl ' lookup_file ' rates_2.unw ' out_2lks];
mysys(command)

end