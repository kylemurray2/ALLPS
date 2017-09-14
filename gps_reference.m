
% GPS InSAR referencing
% Kyle Murray
% July, 2017
% Description:
%   Loads all available UNR GPS time series in a given lat/lon range with
%   get_gps_ts script. All time series are put into a directory GPS
%   Finds reference date in all GPS sites.  Displacement should be zero at 
%   this date in all GPS TS's 
%   
clear all; close all
getstuff

dl_files=0;
%   dl_files=1:  Download new files
%   dl_files=0:  Just load the velocities
[enu_vels,llh_vels,sites_vels]=get_gps_ts_vels(dl_files); 

% Plot horizontal
figure;quiver(llh_vels(:,2),llh_vels(:,1),enu_vels(:,1),enu_vels(:,2))
title('Horizontal GPS velocities');axis image; kylestyle
xlabel('Longitude');ylabel('latitude')

% Plot Vertical
figure;quiver(llh_vels(:,2),llh_vels(:,1),zeros(length(enu_vels(:,3)),1),enu_vels(:,3))
title('Vertical GPS velocities');axis image; kylestyle
xlabel('Longitude');ylabel('latitude');hold on
text(llh_vels(:,2),llh_vels(:,1),sites_vels)

% %off map
offmap={'WGPP'; 'P782';'P602'; 'P578';'P571';'P567';'P546';'P540'
'P539';'P522';'P518';'GDEC';'EDPP';'CUHS';'BCWR';'ARM2';'ARM1' };

% [~,~,bad_ids] =  intersect(offmap(:),sites_vels(:));
% llh_vels(bad_ids,:)=[];
% sites_vels(bad_ids)=[];
% enu_vels(bad_ids,:)=[];
% % Give it a vector of indices
% site_idx=1:length(sites_vels);
% plot_pts_geo(llh_vels(site_idx,1),llh_vels(site_idx,2),sites_vels(site_idx))

% main subsidence lat lon
a=[35.93, -119.4];
% lost hills lat lon
b=[35.43, -119.7];

subsidence=[a;b];


% Just do a subset of the better GPS sites
% good_subset={'P565';'P564';'P563';'P547';'P545';'P544';'P543';'P541';'P538'
%     'P537';'P536';'P056';'CRCN';'BVPP';'BKR2';'BKR1';'BAK1'};
good_subset={'CRCN'};
[~,~,good_ids] =  intersect(good_subset(:),sites_vels(:));
plot_all_pts(llh_vels(good_ids,1),llh_vels(good_ids,2),sites_vels(good_ids)) %plots insar and gps
% plot_pts_geo(subsidence(:,1),subsidence(:,2)); %This also plots profiles


%ideas:
% use GPS in decorrelated areas, and interpolate points around it with good
% insar dates

% interpolate all GPS displacements to make a priori guesses for each
% interferogram before unwrapping?  

% find areas of low deformation

