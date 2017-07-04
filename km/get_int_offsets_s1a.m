%Find offsets from ISCE output (in x and y) 

%find the middle values from offset files.  Look at files in the
%int_date_date/coarse_offsets/overlaps directory. We will take the value in
%the files azimuth_bot_01_02.off and range_bot_01_02.off.  Just need to
%read in the first line and take the median value.  
clear all;close all
set_params
load(ts_paramfile)
ndates=length(dates);
nints=length(ints);
 
    int{1} = 0;
    del(1,1)=0;
    del(1,2)=0;

int{1} = ints(id).name; %name of ints
fid1=fopen([masterdir 'int_' int{1} '/fine_offsets/azimuth_03.off'],'r');
azoff=fread(fid1,3000,'real*4');
maz(1)=median(azoff);
fid2=fopen([masterdir 'int_' int{i} '/fine_offsets/range_03.off'],'r');
rgoff = fread(fid2,3000,'real*4');
mrg(i) = median(rgoff);
fclose('all')
    
for i=2:ndates-2
    inti=find([ints.i1]==i+1 & [ints.i2]==i); 
    int{i} = ints(inti).name; %name of ints

fid1=fopen([masterdir 'int_' int{i} '/fine_offsets/azimuth_03.off'],'r');
azoff=fread(fid1,3000,'real*4');
maz(i)=median(azoff);
if abs(maz(i))>99999
  maz(i)=0;
end
del(i,1)=del(i-1,1)+maz(i);

fid2=fopen([masterdir 'int_' int{i} '/fine_offsets/range_03.off'],'r');
rgoff = fread(fid2,3000,'real*4');
mrg(i) = median(rgoff);
if abs(mrg(i))>99999
  mrg(i)=0;
end
del(i,2)=del(i-1,2)+mrg(i);

fclose('all');
end



%now calculate offset for each int
for k=1:nints-2
    ints(k).azoff = del(ints(k).i2,1);
    ints(k).rgoff = del(ints(k).i2,2);
end

