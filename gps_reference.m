% GPS InSAR referencing
% Kyle Murray
% July, 2017
% Description:
%   Loads all available UNR GPS time series in a given lat/lon range
%   Find reference date in all GPS sites.  Displacement should be zero at this date in all GPS TS's 
%   
clear all; close all
getstuff

max_lat = max(frames.lat);
min_lat = min(frames.lat);
max_lon = max(frames.lon);
min_lon = min(frames.lon);

!mkdir GPS
chdir('GPS')

% Download GPS lat/lon file from UNR
!rm llh*
system('wget ftp://gneiss.nbmg.unr.edu/rapids/llh');

% Get list of GPS site within area of interest
fid= fopen('llh');
sllh= textscan(fid,'%s%f%f%f','headerLines',1); %site lat lon height
sites=sllh{1,1};
lats =sllh{1,2};
lons =sllh{1,3};
heights =[sllh{1,4}];
clear sllh

idx=(lats>min_lat & lats<max_lat & lons>min_lon & lons<max_lon);
sites=sites(idx);
llh=[lats(idx) lons(idx) heights(idx)]; %lat lon height
clear lats lons heights idx


% Download GPS time series of all sites in list
!rm *tenv3*
for ii=1:length(sites)
readGPS_TS(sites{ii}, 1);
end

% 
