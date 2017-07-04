function unw2png_km(infile,outfile,mode,wraprate,scale)

set_params
load(ts_paramfile);
[nx,ny,lambda] = load_rscs([infile '.rsc'],'WIDTH','FILE_LENGTH','WAVELENGTH');

command = ['rmg2mag_phs ' infile ' mag phs ' num2str(nx)];
mysys(command)

   if mode==1
        command=['mdx mag -r4 -ponly '  num2str(nx)];
        mysys(command);
   else
       command=['mdx phs -r4 -cmap cmy  -wrap ' num2str(wraprate) ' -ponly ' num2str(nx)];
       mysys(command);
   end
       
!rm mag phs

% read first pixel
% command = ['convert out.ppm -crop 1x1+0+0 txt:->tmp'];
% mysys(command);
% 
% color  = 'cyan';
% !rm tmp

command = ['convert out.ppm -resize ' num2str(scale) '%' ' -transparent cyan ' outfile];
system(command);

command =  ['importIMGtoKML.pl ' outfile ' ' infile ' ' outfile '.png.kml'];
mysys(command);


% outfile='ENVI_T120_675';
% %make a grd file for GMT
% command = ['unw2grd.pl geo_rates_2.unw ' outfile '.grd 1'];
% mysys(command); 

end
