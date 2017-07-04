
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

make_mask     %outputs not really used right now...
smart_rlooks  %buffers could make this faster.  Lots of I/O
unwrap_rlooks %does snaphu with tiles.  Make wierd output files on jackalope that need to be deleted.


%iterate over this chunk
invert_dates     %this generates TS/looks#/date.r4 files and res#.  Res# will have a ramp if not alligned. Choose thresh accordingly
thresh      = 5; %this currently needs to be "big" for the first round, then iterate once or twice with smaller values.
xedge       = [100 100]; %pixels from left and right edge to mask
waterheight = 74; %mask all pixels with height < waterheight.
fitramp_int(thresh)  %ideally should use "rate#" file if it exists, as calc_res_int does.
unwrap_flat %this can or can not be used - will reunwrap the now-flatter interferograms. Then iterate as above.

%invert dates once with final set of flattened interferograms
invert_dates
  
invert_rates

calc_rate_residual %adds "rms" field to ints structure.  can be used to decide whether to get rid of some ints.  Then rerun choose_ints, and rerun from invert_dates.
