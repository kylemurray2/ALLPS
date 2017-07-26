function plot_pts_geo(lat_pt,lon_pt)
% site_name=site_name{1};
%Plots time series at specified lat/lon of geocoded inverted dates
%use geocode_dates to get geocoded dates

% %Specify coordinates
% lat_pt=36.113986013;
% lon_pt=-119.568033605;

getstuff
datenumbers=char(dates.name);
% Define variables to plot profiles later
    xi = [-119.2984; -119.8483];
    yi = [36.0881; 35.2293];
    
%load first geocoded int and get grid
    geo_int=[rlkdir{1} dates(1).name '_geo_2rlks.unw'];
    rate_struct=load_any_data(geo_int,'11N');
    phs_X=rate_struct.X;
    phs_Y=rate_struct.Y;
    [lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
    phs_grd_one=-rate_struct.phs*lambda/(4*pi)*100;
    phs_grd=phs_grd_one-phs_grd_one;
    phs_vec=phs_grd(:); %convert to cm
    
    C(:,1) = improfile(lon_vec,lat_vec,phs_grd,xi,yi);

ts_phs=zeros(length(lat_pt),ndates);

%LOOP through lat/lon to get vector indices
for jj=1:length(lat_pt)
    %find phs value at specified lat/lon
    tmp_lat=abs(lat_vec-lat_pt(jj));
    tmp_lon=abs(lon_vec-lon_pt(jj));
    tmp=tmp_lat+tmp_lon;
    [~, idx(jj)]=min(tmp);
    ts_phs(jj,1)=phs_vec(idx(jj));
    
    
    %     if(ts_phs(jj,1)==0)
    %         disp([site_name(jj) ' is off map'])
    %         return
    %     end
end

%load the rest of the geocoded ints
for ii=2:ndates
    geo_int=[rlkdir{1} dates(ii).name '_geo_2rlks.unw'];
    rate_struct=load_any_data(geo_int,'11N');
    phs_grd=-rate_struct.phs *lambda/(4*pi)*100; %convert to cm
    phs_grd=phs_grd-phs_grd_one;
    phs_vec=phs_grd(:);
    
    C(:,ii) = improfile(lon_vec,lat_vec,phs_grd,xi,yi);

    for jj=1:length(lat_pt)
        if(isnan(phs_vec(idx(jj))));
            return
        else
            ts_phs(jj,ii)=phs_vec(idx(jj));
        end
    end
end


d=datenum(datenumbers,'yyyymmdd');
dy=d./365.25;
dy=dy(1:ndates);

%Get rate map
geo_int='geo_rates_2.unw';
rate_struct=load_any_data(geo_int,'11N');
phs_X=rate_struct.X;
phs_Y=rate_struct.Y;
[lat_vec,lon_vec]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
rates_grd=-rate_struct.phs;
rates_grd(find(rates_grd==0))=nan;

for jj=1:length(lat_pt)
    %project to vertical
    vert_disp = ts_phs(jj,:)/cosd(25);
    
    % Fit line to insar
    G=[ones(length(dy),1),dy];
    m=(G'*G)\(G'*vert_disp');
    y_mod=m(2)*dy+m(1);
    
    figure
    subplot(2,1,2)
    plot(dy,vert_disp,'.','MarkerSize',9);hold on
    plot(dy,y_mod,'k')
    title(['Rate = ' num2str(m(2)) ' cm/yr']);
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
    set(gca,'Ydir','normal')
    axis image
    kylestyle
   
    saveas(gcf,['TS_' num2str(jj)],'epsc')
end

% Plot the profiles
for ii=1:ndates
  figure(222);plot(C(:,ii));hold on
  ylabel('Displacement (cm)')
  xlabel('Distance along profile (pixels)')
  kylestyle
  saveas(gcf,'TS_profiles','svg')
end

