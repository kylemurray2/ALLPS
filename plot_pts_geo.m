function plot_pts_geo(lat_pt,lon_pt,site_name)
% site_name=site_name{1};
%Plots time series at specified lat/lon of geocoded inverted dates
%use geocode_dates to get geocoded dates

%Specify coordinates
% site_name='CRCN';
% lat_pt=36.113986013;
% lon_pt=-119.568033605;

plot_rates=1; %0 turns of rate plotting, 1 turns it on
getstuff
datenumbers=char(dates.name);

%load first geocoded int and get grid
if(~exist('date_1_ts.mat','file'))
    geo_int=[rlkdir{1} dates(1).name 'geo_2rlks.unw'];
    rate_struct=load_any_data(geo_int,'11N');
    phs_X=rate_struct.X;
    phs_Y=rate_struct.Y;
    [lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
    lat_grd=reshape(lat_vec,size(phs_X));
    lon_grd=reshape(lon_vec,size(phs_X));
    phs_grd=-rate_struct.phs;
    phs_vec=phs_grd(:)*lambda/(4*pi)*100; %convert to cm
    [nx,ny,lambda,x1,y2,dx,dy,xunit]=load_rscs(geo_int,'WIDTH','FILE_LENGTH','WAVELENGTH','X_FIRST','Y_FIRST','X_STEP','Y_STEP','X_UNIT');
    save('date_1_ts','lat_vec','lon_vec','phs_vec','nx','ny')
else
    load('date_1_ts')
end

%LOOP through lat/lon to get vector indices
for jj=1:length(lat_pt)
    %find phs value at specified lat/lon
    tmp_lat=abs(lat_vec-lat_pt(jj));
    tmp_lon=abs(lon_vec-lon_pt(jj));
    tmp=tmp_lat+tmp_lon;
    [~, idx(jj)]=min(tmp);
    ts_phs(jj,1)=phs_vec(idx(jj));
    nx1=nx;
    xzone=[1 nx];
    
    %     if(ts_phs(jj,1)==0)
    %         disp([site_name(jj) ' is off map'])
    %         return
    %     end
end

%load the rest of the geocoded ints
for ii=2:ndates
    geo_int=[rlkdir{1} dates(ii).name 'geo_2rlks.unw'];
    fid=fopen(geo_int,'r','native');
    [rmg,~] = fread(fid,[nx1,ny*2],'real*4');
    rmg = -rmg(xzone(1):xzone(2),:);
    fclose(fid);
    phs_grd=flipud((rmg(1:nx,2:2:ny*2))');
    phs_vec=phs_grd(:)*lambda/(4*pi)*100; %convert to cm
    for jj=1:length(lat_pt)
        if(isnan(phs_vec(idx(jj))));
            return
        else
            ts_phs(jj,ii)=phs_vec(idx(jj));
        end
    end
end

for i=1:length(dates)
    dnum(i) = str2num(datenumbers(i,:));
end
d=datenum(datenumbers,'yyyymmdd');
dy=d./365.25;

%Get rate map
geo_int='geo_rates_2.unw';
rate_struct=load_any_data(geo_int,'11N');
phs_X=rate_struct.X;
phs_Y=rate_struct.Y;
[lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
%     lat_grd=reshape(lat_vec,size(phs_X));
%     lon_grd=reshape(lon_vec,size(phs_X));
rates_grd=-rate_struct.phs;
%     rates_vec=rates_grd(:);
rates_grd(find(rates_grd==0))=nan;

for jj=1:length(lat_pt)
    %project to vertical
    vert_disp = ts_phs(jj,:)/cosd(25);
    
    %get the GPS site
    [gps_year, gps_e, gps_n, gps_v]=readGPS_TS(site_name{jj},2); %outputs in cm
    
    %get rid of offset in gps data
    % CRCN
    % gps_v(1932:end) = gps_v(1932:end) + (-gps_v(1932)+gps_v(1930));
    
    gps_v=gps_v - mean(gps_v(1:20)); %subtract mean of some of the values near first insar data points (choose range manually)
    
    figure(jj)
    subplot(2,1,2)
    plot(gps_year,gps_v,'.');hold on
    plot(dy,vert_disp,'.','MarkerSize',9);hold on
%     datetick('x','keepticks','keeplimits')
    legend('GPS','InSAR');
    kylestyle
    hold on
    
    %Plot geo_rates_2.unw
    %Plot the rates with pt location
    subplot(2,1,1)
    imagesc(lon_vec,lat_vec,rates_grd/cosd(25));colorbar
    hold on
    plot(lon_vec(idx(jj)),lat_vec(idx(jj)),'ko','MarkerSize',10)
    plot(lon_vec(idx(jj)),lat_vec(idx(jj)),'wo','MarkerSize',8)
    plot(lon_vec(idx(jj)),lat_vec(idx(jj)),'ko','MarkerSize',6)
    title(site_name{jj})
    set(gca,'Ydir','normal')
    axis image
    kylestyle
    
end

