%plot_pts_geo
%Plots time series at specified lat/lon of geocoded inverted dates
%use geocode_dates to get geocoded dates
clear all;close all
%Specify coordinates
lat_pt=36.113986013;
lon_pt=-119.568033605;
plot_rates=1; %0 turns of rate plotting, 1 turns it on
getstuff
datenumbers=char(dates.name);

%load first geocoded int and get grid
geo_int=[rlkdir{1} dates(1).name 'geo_2rlks.unw'];
rate_struct=load_any_data(geo_int,'11N');
  phs_X=rate_struct.X;
  phs_Y=rate_struct.Y;
  [lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
  lat_grd=reshape(lat_vec,size(phs_X));
  lon_grd=reshape(lon_vec,size(phs_X));
  phs_grd=-rate_struct.phs;
  phs_vec=phs_grd(:);
  

  %find phs value at specified lat/lon  
     tmp_lat=abs(lat_vec-lat_pt);
     tmp_lon=abs(lon_vec-lon_pt);
     tmp=tmp_lat+tmp_lon;
     [jnk idx]=min(tmp);
     ts_phs(1)=phs_vec(idx);

[nx,ny,lambda,x1,y2,dx,dy,xunit]=load_rscs(geo_int,'WIDTH','FILE_LENGTH','WAVELENGTH','X_FIRST','Y_FIRST','X_STEP','Y_STEP','X_UNIT');
    nx1=nx;
    xzone=[1 nx];
    yzone=[1 ny];
%load the rest of the geocoded ints
for ii=2:ndates
geo_int=[rlkdir{1} dates(ii).name 'geo_2rlks.unw'];
  fid=fopen(geo_int,'r','native');
  [rmg,count] = fread(fid,[nx1,ny*2],'real*4');
  rmg = -rmg(xzone(1):xzone(2),:);
  fclose(fid);
  phs_grd=flipud((rmg(1:nx,2:2:ny*2))');
  phs_vec=phs_grd(:);
  ts_phs(ii)=phs_vec(idx);
end
     


for i=1:length(dates)
    dnum(i) = str2num(datenumbers(i,:));
end
%project to vertical
vert_disp = ts_phs/cosd(25);
d=datenum(datenumbers,'yyyymmdd');
dy=d./365.25;

figure
plot(dy,vert_disp,'.')
datetick('x','keepticks','keeplimits')
title(['at lon: ' num2str(lon_pt) ', lat:' num2str(lat_pt) ])
kylestyle

% save(['/data/kdm95/Kern/CRCN_TS/' sat '_pts','dy','ts_phs'])
%get the GPS site
%  [gps_year, gps_e, gps_n, gps_v]=readGPS_TS('CRCN',1);

%get rid of offset in gps data
gps_v(1932:end) = gps_v(1932:end) + (-gps_v(1932)+gps_v(1930));
gps_v=(gps_v); %multiply meters by 100 to get cm
gps_v=gps_v - mean(gps_v(1:20))-28; %subtract mean of some of the values near first insar data points (choose range manually)
plot(gps_year,gps_v,'.')
hold on;
plot(dy,ts_phs,'.')

kylestyle

if(plot_rates)
    
    %Plot geo_rates_2.unw
    geo_int='geo_rates_2.unw';
    rate_struct=load_any_data(geo_int,'11N');
      phs_X=rate_struct.X;
      phs_Y=rate_struct.Y;
      [lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
      lat_grd=reshape(lat_vec,size(phs_X));
      lon_grd=reshape(lon_vec,size(phs_X));
      rates_grd=-rate_struct.phs;
      rates_vec=rates_grd(:);
rates_grd(find(rates_grd==0))=nan;
    %Plot the rates with pt location     
    figure;
    imagesc(lon_vec,lat_vec,rates_grd/cosd(32));colorbar
    hold on
    plot(lon_vec(idx),lat_vec(idx),'ko','MarkerSize',10)
    plot(lon_vec(idx),lat_vec(idx),'wo','MarkerSize',8)
    plot(lon_vec(idx),lat_vec(idx),'ko','MarkerSize',6)
    set(gca,'Ydir','normal')
end
