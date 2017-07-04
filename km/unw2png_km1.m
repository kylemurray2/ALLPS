function unw2png_km1(mode,wraprate,scale)
%mode=2 for phase

set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
    [nx,ny]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

end
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);


chdir(['TS/looks' num2str(rlooks) '/'])

for l=1:length(rlooks)
    for k=1:nints
        command = ['rmg2mag_phs ' ints(k).unwrlk{1} ' mag phs ' num2str(newnx)];
        mysys(command)

   if mode==1
        command=['mdx mag -r4 -ponly '  num2str(newnx)];
        mysys(command);
   else
       command=['mdx phs -r4 -cmap cmy  -wrap ' num2str(wraprate) ' -ponly ' num2str(newnx)];
       mysys(command);
   end
       
!rm mag phs

% read first pixel
% command = ['convert out.ppm -crop 1x1+0+0 txt:->tmp'];
% mysys(command);
% 
% color  = 'cyan';
% !rm tmp

command = ['convert out.ppm -resize ' num2str(scale) '%' ' -transparent cyan ' ints(k).name '.png'];
system(command);

    end
end
!mkdir png_files
!mv *.png png_files/
chdir('../../')
end
