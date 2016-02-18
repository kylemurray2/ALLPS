%Geocode the rates_4 file

set_params

name='mojave';

%Step 1. Create rmg file
amp_img = 'ratestd_4';
phs_img = 'rates_4';
rmg_out = 'rates_4.unw';
mysys(['mag_phs2rmg ' amp_img ' ' phs_img ' ' rmg_out ' ' num2str(newnx)])


%Step 2. Create a 2-looks version
    %first, write out a rect_back.in file
fid=fopen('rect_back.in','w');

fprintf(fid,['Input Image File Name  (-) = ' rmg_out '      ! dimension of file to be rectified\n']);
fprintf(fid,['Output Image File Name (-) = rates_2.unw       ! dimension of output\n']);
fprintf(fid,['Input Dimensions       (-) = ' num2str(newnx) ' ' num2str(newny)  ' ! across, down\n']);
fprintf(fid,['Output Dimensions      (-) = ' num2str(nx) ' ' num2str(ny)  ' ! across, down\n']);
fprintf(fid,['Affine Matrix Row 1    (-) = .5 0      ! a b\n']);
fprintf(fid,['Affine Matrix Row 2    (-) = 0 .25      ! c d\n']);
fprintf(fid,['Affine Offset Vector   (-) = 0 0        ! e f\n']);
fprintf(fid,['File Type              (-) = RMG        ! [RMG, COMPLEX]\n']);
fprintf(fid,['Interpolation Method   (-) = Bilinear        ! [NN, Bilinear, Sinc]\n']);

    %now, use rect rect_back.in to up look the 4looks rates file
mysys(['rect rect_back.in'])
   %now we have a rates_2.unw to geocode 
    
    
%Step 3. Geocode
    %we need to copy a rsc file
    mysys('cp int_????????_????????/????????-????????.amp.rsc rates_2.unw.rsc')
lookup_file = 'int_????????_????????/geomap_2rlks.trans';
command = ['geocode.pl ' lookup_file ' rates_2.unw geo_rates_2.unw'];
mysys(command)