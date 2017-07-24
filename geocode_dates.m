clear all;close all
getstuff
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

% crop_edges_dates([1*4 1*4 30*8 1*8]); %full res location of crop (so that it works for multiple rlooks, left right, top, bottom. RLBT?

for ii=1:length(dates)
    froot=[rlkdir{1} dates(ii).name];
    unw_in=[froot '_' num2str(rlooks) 'rlks.r4'];

    %Step 1. Create rmg file
    amp_img = unw_in;
    phs_img = unw_in;
    rmg_out = [froot '_' num2str(rlooks) 'rlks_in.unw'];

    system(['mag_phs2rmg ' amp_img ' ' phs_img ' ' rmg_out ' ' num2str(newnx)]);
    [nx2,ny2] = load_rscs([oldintdir 'radar_2rlks.hgt'],'WIDTH','FILE_LENGTH');

    aff1=1; %.5
    aff2=.5; %aff1/pixel_ratio;

    %Step 2. Create a 2-looks version
        %first, write out a rect_back.in file
    fid=fopen('rect_back.in','w');

    fprintf(fid,['Input Image File Name  (-) = ' rmg_out '      ! dimension of file to be rectified\n']);
    fprintf(fid,['Output Image File Name (-) = ' froot '_2rlks.unw       ! dimension of output\n']);
    fprintf(fid,['Input Dimensions       (-) = ' num2str(newnx) ' ' num2str(newny)  ' ! across, down\n']);
    fprintf(fid,['Output Dimensions      (-) = ' num2str(nx2) ' ' num2str(ny2)  ' ! across, down\n']);
    fprintf(fid,['Affine Matrix Row 1    (-) = ' num2str(aff1) ' 0      ! a b\n']);
    fprintf(fid,['Affine Matrix Row 2    (-) = 0 ' num2str(aff2)  '     ! c d\n']);
    fprintf(fid,['Affine Offset Vector   (-) = 0 0            ! e f\n']);
    fprintf(fid,['File Type              (-) = RMG             ! [RMG, COMPLEX]\n']);
    fprintf(fid,['Interpolation Method   (-) = NN             ! [NN, Bilinear, Sinc]\n']);

    %Use rect rect_back.in to up look the 4looks rates file
    system(['rect rect_back.in']);

    %Step 3. Geocode
    %we need to copy a rsc file
    system(['cp ' masterdir 'int_????????_????????/????????-????????_2rlks.cor.rsc ' froot '_2rlks.unw.rsc']);
    lookup_file = 'GEO/geomap_2rlks.trans';
    system(['geocode.pl ' lookup_file ' ' froot '_2rlks.unw ' froot '_geo_2rlks.unw']);
%     system(['look.pl ' froot '_geo_2rlks.unw' 12]);
end