% plot_std_profile
% Takes geocoded rate map and standard deviation map and plots a profile
% accross both images. A and A' defined by xi,yi.


% Define variables to plot profiles later
xi = [-119.2984; -119.8483];
yi = [36.0881; 35.2293];

% Load the rate and std maps
geo_int='geo_rates_2.unw';
rate_struct=load_any_data(geo_int,'11N');
phs_X=rate_struct.X;
phs_Y=rate_struct.Y;
[lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
rates_grd=-rate_struct.phs;
rates_grd(find(rates_grd==0))=nan;

C_rates = improfile(lon_vec,lat_vec,rates_grd,xi,yi);


geo_int='geo_std_2.unw';
rate_struct=load_any_data(geo_int,'11N');
phs_X=rate_struct.X;
phs_Y=rate_struct.Y;
[lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
std_grd=abs(rate_struct.phs);
std_grd(find(rates_grd==0))=nan;

C_std = improfile(lon_vec,lat_vec,std_grd,xi,yi);

figure
subplot(2,1,1)
plot(C_rates)
title('Rate profile')
xlabel('Distance (px)');ylabel('rate (cm/yr)')
kylestyle
subplot(2,1,2)
plot(C_std)
title('Standard deviation profile')
xlabel('Distance (px)');ylabel('std')
kylestyle

saveas(gcf,['TS_rate_std_profile'],'svg')








