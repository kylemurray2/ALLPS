% Description:
% Loads each date, removes a model of GPS surface, remove low freq, add 
% back GPS, save dates
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


% Get the lat and lon vectors from geocoded date
 geo_int=[rlkdir{1} dates(1).name '_geo_2rlks.unw'];
        rate_struct=load_any_data(geo_int,'11N');
        phs_X=rate_struct.X;
        phs_Y=rate_struct.Y;
        [lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
            phs_grd=rate_struct.phs;

% [xq,yq] = meshgrid(min_lon:.005:max_lon, min_lat:.005:max_lat); %one pixel at 2rlks is ~1/2000 degree
lat_grd=reshape(lat_vec,size(phs_grd));
lon_grd=reshape(lon_vec,size(phs_grd));
x=llh_vels(:,2);
y=llh_vels(:,1);
v=enu_vels(:,3);
vq = griddata(x,y,v,lon_grd,lat_grd,'cubic'); %cm/yr

% Plot the gridded data as a mesh and the scattered data as dots.
% figure
% mesh(lon_grd,lat_grd,vq)
% hold on
% plot3(x,y,v,'o')

% Convert velocity to displacements for each inverted time interval
    % Get the time intervals
    datenumbers=char(dates.name);
    d=datenum(datenumbers,'yyyymmdd');
    dy=d./365.25;

    %make copies of original geocoded dates
for k=1:ndates
    if(~exist([rlkdir{1} dates(k).name '_geo_2rlks_orig.unw'],'file'))
            copyfile([rlkdir{1} dates(k).name '_geo_2rlks.unw'],[rlkdir{1} dates(k).name '_geo_2rlks_orig.unw'])
            copyfile([rlkdir{1} dates(k).name '_geo_2rlks.unw.rsc'],[rlkdir{1} dates(k).name '_geo_2rlks_orig.unw.rsc'])

            disp(['copying ' rlkdir{1} dates(k).name '_geo_2rlks.unw to ' rlkdir{1} dates(k).name '_geo_2rlks_orig.unw']);
    end
end

    % Load each date, remove GPS, remove low freq, add back GPS, save
    for ii=2:4%ndates
        geo_int=[rlkdir{1} dates(ii-1).name '_geo_2rlks_orig.unw'];
        rate_struct=load_any_data(geo_int,'11N');
        phs_X=rate_struct.X;
        phs_Y=rate_struct.Y;
        [lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
        phs_grd_one=-rate_struct.phs*lambda/(4*pi)*100; %convert to cm
        phs_grd=phs_grd_one-phs_grd_one;
        time_interval=dy(ii)-dy(id); %time interval in years
        gps_disp = time_interval * vq; %this is the model to be removed
        phs_removed=phs_grd-gps_disp; %check these for transpose
    
      % Remove low pass
        % Transform phase to frequency domain
        phs_freq = fft2(phs_removed);
        phs_freq = fftshift(phs_freq);
        
        % Make filter
        xoff=floor(newnx/2);
        yoff=floor(newny/2);
%         [X,Y] = meshgrid(1-xoff:newnx-xoff,1-yoff:newny-yoff);
        fstrength=1;
        g2=(2+fstrength^1.5);
        gauss2 = exp((-lon_grd.^2-lat_grd.^2)/(g2^2));

        
        % Apply filter
        phs_freq_filt = gauss2.*phs_freq;
        phs_freq_filt = ifftshift(phs_freq_filt);
        phs_filt = ifft2(phs_freq_filt);
        phs_filt = real(phs_filt);
        
        % Subtract filtered phase
        phs_diff=phs_removed-phs_filt;
        
        % Add back in GPS model
        phs_final = phs_diff+gps_disp;
        
        % Write output
        outfile = [dates(ii).unwrlk{1} '_test'];
        fido=fopen(outfile,'w');
        fwrite(fido,phs_final,'real*4');
        fclose(fido);
        
    end
