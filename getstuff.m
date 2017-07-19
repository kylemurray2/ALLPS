set_params
load(ts_paramfile)
ndates   = length(dates);
nints    = length(ints);
if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
    
else
     [nx,ny,lambda]= load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

end
% newnx   = 400%floor(nx./rlooks)
% newny   =400%floor(ny./alooks);
im=sqrt(-1);
newnx   = floor(nx./rlooks);
newny   =floor(ny./alooks);