 function unw2png_km_s1a(infile,outfile,mode,wraprate,scale)
% infile = 'rates_1';
% outfile = ['s1a_' num2str(track) '_' num2str(frame) '.png'];
% mode = 2;
% wraprate = 30;
% scale= 50; 
l=1;
set_params
load(ts_paramfile);
% [nx,ny,lambda] = load_rscs([infile '.rsc'],'WIDTH','FILE_LENGTH','WAVELENGTH');


fid=fopen(infile,'r')
tmp=fread(fid,[newnx newny*2],'real*4');
phs   = tmp';
fclose(fid);


fid=fopen('phs','w')
for i=1:newny(l)
fwrite(fid,phs(i,:),'real*4');
end
fclose(fid);


   if mode==1
        command=['mdx mag -r4 -ponly '  num2str(newnx)];
        mysys(command);
   else
       command=['mdx phs -r4 -cmap cmy  -wrap ' num2str(wraprate) ' -ponly ' num2str(newnx)];
       mysys(command);
   end
       


% read first pixel
% command = ['convert out.ppm -crop 1x1+0+0 txt:->tmp'];
% mysys(command);
% 
% color  = 'cyan';
% !rm tmp

command = ['convert out.ppm -resize ' num2str(scale) '%' ' -transparent cyan ' outfile];
system(command);

command =  ['importIMGtoKML.pl ' outfile ' ' infile ' ' outfile '.kml'];
mysys(command);

% end
