%Creates .rsc files for each flat.flat int in the ints structure
clear all;close all

set_params
load(ts_paramfile);



for i=1:nints
   %get length and width
    xmlfilename =[ints(i).flat '.xml'];
    system(['sed -n "/width/{n;p;}" ',xmlfilename,' > flat.flat.xml.txt'])
    system(['sed -n "/length/{n;p;}" ',xmlfilename,' >> flat.flat.xml.txt'])  
   [status, width]=system('i=`awk ''NR==2 {print $1}'' flat.flat.xml.txt`;echo ${i:7:5}')
   [status, length]=system('i=`awk ''NR==5 {print $1}'' flat.flat.xml.txt`;echo ${i:7:5}')
   width(strfind(width,'<'))=[];
   length(strfind(length,'<'))=[];
   
   %write the .rsc file
   out=[ints(i).flat '.rsc'];
   fid = fopen(out,'wt+');
   fprintf(fid,'WIDTH %s\n',num2str(width));
   fprintf(fid,'FILE_LENGTH %s\n',num2str(length));
   fprintf(fid,'XMIN %s\n',num2str(0));
   fprintf(fid,'XMAX %s\n',num2str(width));
   fprintf(fid,'YMIN %s\n',num2str(0));
   fprintf(fid,'YMAX %s\n',num2str(length));  
   fprintf(fid,'RLOOKS %s\n',num2str(1));
   fprintf(fid,'ALOOKS %s\n',num2str(1));
   fprintf(fid,'FILE_START %s\n',num2str(1));
   fprintf(fid,'DELTA_LINE_UTC %s\n',num2str(0.00374400023961602));
   fclose(fid)
  ints(i).width=str2num(width);
  ints(i).length=str2num(length);
  ints(i).width_lks=floor(str2num(width)/rlooks);
  ints(i).length_lks=floor(str2num(length)/alooks);
save(ts_paramfile,'ints','dates')
end
    