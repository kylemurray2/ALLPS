set_params
load(ts_paramfile);
[nx,ny]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
%make DEM
if(~exist([DEMdir 'tmp.dem']))
    home=pwd;
    chdir(DEMdir);
    command=['get_SRTM.pl tmp.dem ' num2str([min([frames.lat])-1 max([frames.lat])+1 min([frames.lon])-1 max([frames.lon])+1 1 1])];
    mysys(command);
    chdir(home)
end
procname=[masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '.proc'];
fid=fopen(procname ,'w');
fprintf(fid,['SarDir1=' masterdir dates(ints(intid).i1).name '\n']);
fprintf(fid,['SarDir2=' masterdir dates(ints(intid).i2).name '\n']);
fprintf(fid,['IntDir=' masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '\n']);
fprintf(fid,['GeoDir=GEO\n']);
fprintf(fid,['SimDir=SIM\n']);
fprintf(fid,['OrbitType=HDR\n']);
fprintf(fid,['DEM=' DEMdir 'tmp.dem\n']);
fprintf(fid,['pixel_ratio=1\n']);
fprintf(fid,['FilterStrength=0.4\n'])
fprintf(fid,['UnwrappedThreshold=0.01\n']);
fprintf(fid,['Rlooks_sim=2\n']);
fprintf(fid,['Rlooks_unw=2\n']);
fprintf(fid,'\n');

fclose(fid);
command=(['process_2pass.pl ' procname ' raw orbbase']);
mysys(command);
command=(['process_2pass.pl ' procname ' slcs done']);
mysys(command);


%rerun rect
home=pwd;
chdir([masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name]);
clear input
copyfile('rect.in','rect_big.in');
input(1).name='Affine Matrix Row 1';
input(2).name='Affine Matrix Row 2';

tmp=use_rdf('rect.in','read',input);
aff1=str2num(tmp(1).val);
aff2=str2num(tmp(2).val);

input(1).val=num2str(aff1/2); %needs to be fixed for non-2rlks
input(2).val=num2str(aff2/2);
input(3).name='Output Image File Name';
input(3).val='radar.hgt';
input(4).name='Output Dimensions';
input(4).val=num2str([nx ny]);

use_rdf('rect_big.in','write',input);
command=['rect rect_big.in'];
mysys(command);
chdir(home);


%plot the azimuth offsets relative to master int (red dot)
figure;plot(1:length(dates),[dates.azoff],'k.','MarkerSize',12);hold on;
plot(id,[dates(id).azoff],'r.','MarkerSize',12);
xlabel('Date number');ylabel('Azimuth Offset');kylestyle


