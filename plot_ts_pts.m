% function values=plot_ts_pts(px,py)
clear all;close all
% px=[727 460  541 1328 251];
% py=[550 1491 79 2337 2897];
clear all;close all
sites=[{'main'}; {'P544'}; {'CRCN'}; {'BAK1'}; {'P537'}]
% px=1553;
% py=1248;
px=2221;py=1422;
%example:
%px=[1076 1015 1135 693 637 699 722];
%py=[1655 1504 1498 2069 1980 2065 2152];

set_params
% load(ts_paramfile)
% ndates  = length(dates);
% nints   = length(ints);
% if strcmp(sat,'S1A')
%     nx=ints(id).width;
%     ny=ints(id).length;
% else
%     [nx,ny,lambda]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');
% 
% end
% newnx   = floor(nx./rlooks)
% newny   = floor(ny./alooks);

[X,Y] = meshgrid(1:newnx,1:newny);

dn    = [dates.dn];
dn    = dn-dn(1);

l=1;

for i=1:ndates
    fid=fopen([dates(i).unwrlk '_corrected'],'r');
    for j=1:length(px)
        fseek(fid,0,-1);
        tmp=fread(fid,(newnx(l)*(py(j)-1)+px(j)-1),'real*4');
        ts_phs(i,j)=fread(fid,1,'real*4')*lambda/(4*pi)*-100; %convert to cm
        
    end
    fclose(fid);
end

%get int values
% for i=1:nints
%     fid=fopen(ints(i).unwrlk '_corrected','r');
%     for j=1:length(px)
%         fseek(fid,0,-1);
%         tmp=fread(fid,(newnx(l)*(py(j)-1)+px(j)-1),'real*4');
%         values_ints(i,j)=fread(fid,1,'real*4');
%     end
%     fclose(fid);
% end


% %for each int, find difference between its displacement and the cumulative
% %displacement from the sbas inversion (span of the values vector).
% for i=1:nints
%     dn1 = ints(i).i1;
%     dn2 = ints(i).i2;
%     cum_mod = values(dn2,1)-values(dn1,1);
%     ints(i).res = values_ints(i,1) - cum_mod;
% end
%     
% %make a baseline plot with the pair segments colored by the residual
% %calcualted above.
% i1=[ints.i1];
% i2=[ints.i2];
% dn=[dates.dn];                                                                                                                       
% bp=[dates.bp]; 
% 
%     dnpair=[dates(i1).dn;dates(i2).dn];
%     bppair=[dates(i1).bp;dates(i2).bp];
% 
%     res_abs=abs([ints.res]);
%     res_intensity=round(10*abs(mean(res_abs)-res_abs)/mean(res_abs))+1;
%     
%     % res_intensity=round(abs([ints.res]))+1
%     cmap= jet(range(res_intensity)+1);
% 
%  %Plot the baseline plot for the single pixel
%     figure
%      text(dn,bp,num2str([1:ndates]')); hold on
%     for i=1:length(ints)
%        
%         plot(dnpair(:,i),bppair(:,i),'Color',cmap(res_intensity(i),:));hold on
%         grid on
%         datetick
%         title('int - inverted displacement')
%         xlabel('Years'); ylabel('Baseline (m)')
%         kylestyle
%         colormap(cmap)
%         colorbar('Ticks',[1,2,3,4,5,6]);
%     end
%     
%   %Plot the baseline plot for the rms of the whole int 
%    rms=abs([ints.rms]);
%     rms_intensity=round(10*abs(mean(rms)-rms)/mean(rms))+1;
%     
%   cmap=jet(range([rms_intensity])+1);
%   
%      figure
%      text(dn,bp,num2str([1:ndates]')); hold on
%     for i=1:length(ints)
%        
%         plot(dnpair(:,i),bppair(:,i),'Color',cmap(rms_intensity(i),:));hold on
%         grid on
%         datetick
%         title('Baselines colored by int RMS')
%         xlabel('Years'); ylabel('Baseline (m)')
%         kylestyle
%         colormap(cmap)
% %         colorbar('Ticks',[1,2,3,4,5,6]);
%     end
%     
% for i=1:ndates
%     fid=fopen(dates(i).unwrlk,'r');
%     for j=1:length(px)
%         fseek(fid,0,-1);
%         tmp=fread(fid,(newnx(l)*(py(j)-1)+px(j)-1),'real*4');
%         values(i,j)=fread(fid,1,'real*4');
%     end
%     fclose(fid);
% end

fid=fopen(['rates_' num2str(rlooks)],'r');
rate=fread(fid,[newnx,newny*2],'real*4');
% rate=flipud(rate');
figure
imagesc(rate');hold on
plot(px,py,'ko')
% text(px,py,sites)
% caxis([-40 40])
colorbar
colormap('jet')

datenumbers=char(dates.name);

for i=1:length(dates)
    dnum(i) = str2num(datenumbers(i,:));
end
%project to vertical
ts_phs = ts_phs;%/cosd(25);
save('sent_ts_global_offset_ramp','ts_phs')
d=datenum(datenumbers,'yyyymmdd');
dy=d./365.25;
figure
plot(dy,ts_phs,'k.');hold on
datetick('x','keepticks','keeplimits')
title(['at pixel: ' num2str(px) ', ' num2str(py) ])
kylestyle

% get the GPS site
 [gps_year, gps_e, gps_n, gps_v]=readGPS_TS('CRCN',1);

%get rid of offset in gps data
 gps_v(1932:end) = gps_v(1932:end) + (-gps_v(1932)+gps_v(1930));
 
% start_id = find(round((gps_year*1000))/1000 == round((dy(1)*1000))/1000);
% insar_vert=nan(1,length(gps_year));
% insar_vert(start_id:length(dy)+start_id-1)=values/cosd(23)+gps_v(start_id);
% insar_vert2 = values/cosd(30);
% insar_vert2= insar_vert2+110
% 
% load 's1a_dates'
% load 's1a_disp'

% figure
% plot(dy,values,'r.');hold on
% % legend('GPS','Envisat','Sentinel')
% xlabel('years')
% ylabel('Displacement (cm)')
% kylestyle
% 
% gps_v=(gps_v); %multiply meters by 100 to get cm
% gps_v=gps_v - mean(gps_v(1:20))-28; %subtract mean of some of the values near first insar data points (choose range manually)
% plot(gps_v,'.')
% kylestyle

%% now fit a seasonal rate
% run_seasfun

% %% now plot GPS data on same figures (7,6,5,4) {'P544'}; {'CRCN'}; {'BAK1'}; {'P537'}
% 
% figure(4)
% [gps_year, gps_e, gps_n, gps_v]=readGPS_TS('P544.NA12.tenv3')
% % gps_los = dot(gps
% gps_v=(gps_v*100); %multiply meters by 100 to get cm
% gps_v=gps_v - mean(gps_v(589:595))+3; %subtract mean of some of the values near first insar data points (choose range manually)
% plot(gps_year,gps_v,'.')
% 
%  figure(5)
%  [gps_year, gps_e, gps_n, gps_v]=readGPS_TS('CRCN.NA12.tenv3')
%  gps_v(1932:end) = gps_v(1932:end) + (-gps_v(1932)+gps_v(1930));
% gps_v=(gps_v); %multiply meters by 100 to get cm
% gps_v=gps_v - mean(gps_v(1:20))-28; %subtract mean of some of the values near first insar data points (choose range manually)
% plot(gps_year,gps_v,'.')
% % 
% figure(6)
% [gps_year, gps_e, gps_n, gps_v]=readGPS_TS('BAK1.NA12.tenv3')
% gps_v=(gps_v*100); %multiply meters by 100 to get cm
% gps_v=gps_v - mean(gps_v(1:20))-.5; %subtract mean of some of the values near first insar data points (choose range manually)
% plot(gps_year,gps_v,'.')
% % 
%  figure(7)   
% [gps_year, gps_e, gps_n, gps_v]=readGPS_TS('P537.NA12.tenv3')
% gps_v=(gps_v*100); %multiply meters by 100 to get cm
% gps_v=gps_v - mean(gps_v(600:620)); %subtract mean of some of the values near first insar data points (choose range manually)
% plot(gps_year,gps_v,'.')
