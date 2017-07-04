%%%set all of these!
setenv('GFORTRAN_STDIN_UNIT','5')
setenv('GFORTRAN_STDOUT_UNIT','6')
setenv('GFORTRAN_STDERR_UNIT','0')
setenv('DYLD_LIBRARY_PATH', '/usr/local/bin:/opt/local/lib:')

masterdir = '/data/TSX/Kansas/T52/'; %For now, set this by hand, make sure it exists, and run from this dir.
track     = 52; %track for ERS/ENVI, path for ALOS
frame     = [820]; %frame for ERS/ENVI, row for ALOS.  Can be vector of multiple adjacent frames
sat       = 'TSX';  %ERS,ENVI,ALOS or TSX
% 
  % track         = 213;
  % frame         = [2907];
  % sat           = 'ENVI'; %ENV1, ERS1, ERS2

%%%two modes - either you've downloaded all the data yourself, into a
%%%series of YYYYMMDD directories, or you are going to use the ASF/UNAVCO
%%%api system to search the catalogs and download them.

id       = 1; %master date id.  Change based on plot from search_data or your own intuition.
datamode = 2; %1 = download, 2=already downloaded, in masterdir
plotflag = 1;

if (datamode==1)
    [dn,footprints,searchresults,sortresults,sortdn]=search_data(track,frame,sat,plotflag);
    write_paramfile(sat,masterdir,id,footprints,plotflag); %writes set_params.m, which you can edit.
    
    init_dirs;                                %initializes timeseries directories
    make_dates_struct(sortdn,sortresults);    %makes dates structure, stores in ts_params.mat
    load_data(sat,searchresults,dn,sortdn);   %After: Check to see if each dir now has data files
    
elseif (datamode==2)
    %download and sort data into directories on your own, each with name YYYYMMDD
    write_paramfile(sat,masterdir,id,[],1);
    init_dirs;
    make_dates_struct([],[]);    %makes dates structure, stores in ts_params.mat
else
    disp('datamode must be 1 (to search and download new data) or 2 (data already exists, in YYYYMMDD dirs)')
end

make_all_raw %runs make_raw.  Note: if the diffnsim_flat_HDR_20070526-20071011.int.in file doeesn't have "SLC relative line offset"=1, you have a problem.
setup_init   %runs process_2pass through baseline computation relative to master
read_dopbase %selects dates that don't violate doppler, baseline, az off

%%%Note - I THINK choose_ints can be run anytime from here on out, and
%%%rerun if chosen ints change, i.e., to throw them out.  And if you add
%%%them, it should go through the remaining scripts (except calc_gamma.m)
%%%and only change what it has to.
choose_ints  %chooses set of interferograms, add or remove pairs by editing set_params.m

make_slcs  %This really shouldn't fail.
rect_slcs  %If this does not result in rectified SLCs, you have a problem and must tinker by and in TS/rect/rectfiles.  Requires resamp_roi_nofilter compiled.
master_int %This needs to be run before flat_ints, can be run in parallel with rect_slcs. Load own dem first into DEM/tmp.dem, or will try loading SRTM.
  
calamp  %calculates mean amplitude in each slc
avgrect %generates TS/avgslc.r4.  Good to view this as quick check on rectification quality.  Should look very sharp.
 
%note - we don't make interferograms anymore-  go straight to flattened after ramps.
make_ramps
flat_ints
FilterFlat
CalcGamma

make_mask(gammathresh)    %outputs not really used right now...
crop_edges([207 20  13 1]); %full res location of crop (so that it works for multiple rlooks, left right, top, bottom.
smart_rlooks  %buffers could make this faster.  Lots of I/O
unwrap_rlooks %does snaphu with tiles.  Make wierd output files on jackalope that need to be deleted.


%iterate over this chunk
invert_dates(0)     %this generates TS/looks#/date.r4 files and res#.  Res# will have a ramp if not alligned. Choose thresh accordingly
thresh      = 4; %this currently needs to be "big" for the first round, then iterate once or twice with smaller values.
edge       = [1843*4 4726 898*4 1517]; %pixels from left and right, top and bottom edge to mask
waterheight = []; %mask all pixels with height < waterheight.
topoflag    = [];
boxedge     = [2437 2636 1357 1582]*4;
fitramp_int(thresh,edge,waterheight,topoflag,boxedge,0)
unwrap_flat %this can or can not be used - will reunwrap the now-flatter interferograms. Then iterate as above.

%invert dates once with final set of flattened interferograms
invert_dates
  
invert_rates

calc_rate_residual %adds "rms" field to ints structure.  can be used to decide whether to get rid of some ints.  Then rerun choose_ints, and rerun from invert_dates.
