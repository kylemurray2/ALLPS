%id: master date id.  Change based on plot from search_data or your own intuition.
clear all;close all
track=485;
frame=2889;
sat='ENVI';
plotflag=1;
id=1;
mkdir('figs')
masterdir = [pwd '/'];%['/data/kdm95/' sat '/' num2str(track) '_' num2str(frame) '/']; %For now, set this by hand, make sure it exists, and run from this dir.

    [dn,footprints,searchresults,sortresults,sortdn,apiCall]=search_data(track,frame,sat,1,[]);
%  [dn,searchresults,sortdn,sortresults]=I_subset([50:56],dn,searchresults,sortdn,sortresults); %do only these date ids     
    write_paramfile(sat,masterdir,id,footprints,1,2,track,frame); %writes set_params.m, which you can edit.
    init_dirs;                                %initializes timeseries directories
    make_dates_struct(sortdn,sortresults);    %makes dates structure, stores in ts_params.mat
    load_data;   %After: Check to see if each dir now has data files  
    disp('Raw files have been created. Now start at setup_init.')
% write_slc_proc
setup_init
% setup_init_runPar   %runs process_2pass through baseline computation relative to master
read_dopbase_km %selects dates that don't violate doppler, baseline, az off
choose_ints_km  %chooses set of interferograms, add or remove pairs by editing set_params.m
disp('Add or remove pairs and rerun from setup_init. When satisfied continue to make_slcs')


%%
make_slcs  
master_int %This needs to be run before rect_slcs, to determine any offsets of the master relative to SIM

% %remove Bad interferograms?
%     baddateids=[33];
%     replace_dates_struct(baddateids,1)

rect_slcs   %If this does not result in rectified SLCs, you have a problem and must tinker by and in TS/rect/rectfiles.  Requires resamp_roi_nofilter compiled. 
calamp      %calculates mean amplitude in each slc
avgrect     %generates TS/avgslc.r4.  Good to view this as quick check on rectification quality.  Should look very sharp.

make_ints
make_ramps
flat_ints
makeGamma(0) %0, 1, 2, or 3
makeGamma(1)
make_mask(0.2)
smart_rlooks_2
crop_edges([30*rlooks 30*rlooks 30*alooks 30*alooks]); %full res location of crop (so that it works for multiple rlooks, left right, top, bottom.
ps_interp
unwrap_rlooks %uses interp files now, does snaphu with tiles. 

% mask_unwrapped %masks using the gamma_4rlks.r4 file. first band is unmasked, second band is masked
unw2png_km1(10,20) %(mode,wraprate,scale%) make a .png image of each unw_4lks in TS/looks4/png_files/
% disp('Examine the unwrapped ints and decide if filtering is required.')
% 
% return
%__________________________________________________________________________
%Try filtering, unwrapping, subtract unw from filtered, then add 2pi*n to
%unfiltered int:
    % filter_unw_diff(1)
%Or try filtering and unwrapping normally:
    % filter_rlooks
    % unwrap_filtered
    % unwfilt2png_km1(2,30,15) %(mode,wraprate,scale%) make a .png image of each unw_4lks in TS/looks4/png_files/
%__________________________________________________________________________

%%
% filter_unw_diff(1)

%remove Bad interferograms?________________________________________________
%     badintids=[2 5 7 8 9 10 11];
%     replace_ints_struct(badintids,1);set_params;load(ts_paramfile);
%      Mode=1: This will remove badintids from ints structure
%      Mode=2: This will change ints structure back to the original
%__________________________________________________________________________

%iterate over this chunk
invert_dates(0); %1 looks for .unw_topo.unw files (not made til fitramp_int), 0 looks for normal unw files. 

    %%%this generates TS/looks#/date.r4 files and res#.  Res# will have a ramp if not alligned. Choose thresh accordingly
thresh      =5; %this currently needs to be "big" for the first round, then iterate once or twice with smaller values.
edge       = [100 100 10 10]; %pixels from left, right, top, bottom edges to mask
waterheight = [-10]; %mask all pixels with height < waterheight.
topoflag    = [];
boxedge     = [0 0 0 0];%[2437 2636 1357 1582]*4;
fitramp_int(thresh,edge,waterheight,topoflag,boxedge,2);  %topoflag=1 removes topo and writes to *_topo.unw files, 0 is normal. Now uses rates file, if it exists!
tic
invert_dates(0);
geocode_dates;
gps_reference;

lf_power(2);
invert_rates
geocode('rates_2','geo_rates_2.unw') %Geocodes the rates_4 file and makes geo_rates_2.unw
geocode('ratestd_2','geo_std_2.unw') %Geocodes the rates_4 file and makes geo_rates_2.unw
plot_std_profile
toc
unwrap_flat %this can or can not be used - will reunwrap the now-flatter interferograms. Then iterate as above.

%%
%invert dates once with final set of flattened interferograms
invert_dates(0); %1 looks for .unw_topo.unw files,0 looks for normal unw files. 
invert_rates %this uses the dates_nlooks.r4 files, however constructed
calc_rate_residual %adds "rms" field to ints structure.  can be used to decide whether to get rid of some ints.  Then rerun choose_ints, and rerun from invert_dates.

rp=[];
rms_thresh=100 %choose rms cutoff
rp=[rp;[ints(abs([ints.rms])>rms_thresh).i1; ints(abs([ints.rms])>rms_thresh).i2]']

lf_power(5); %arg: # of freq bands

%Geocode and make .kml file
geocode('rates_2','geo_rates_2.unw') %Geocodes the rates_4 file and makes geo_rates_2.unw
geocode('ratestd_2','geo_rates_2.unw') %Geocodes the rates_4 file and makes geo_rates_2.unw
plot_std_profile
unw2png_km('geo_rates_2.unw',[sat '_T' num2str(track) '_' num2str(frame) '.png'],2,10,50) %infile, outfile, mode(1 is amp, 2 is phs),wraprate,scale(% resize)
make_frame_gmt

 mysys('unw2grd.pl geo_rates_2.unw ALOS_T210_670.grd 1')
 
end