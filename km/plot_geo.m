clear all;close all
getstuff
%load dem
dem=[DEMdir 'tmp.dem'];
DEM=load_any_data(dem,'11N');
  dem_X=DEM.X;
  dem_Y=DEM.Y;
  [dem_lat,dem_lon]=utm2ll(dem_X(:),dem_Y(:),11,'wgs84');
  dem_lon=reshape(dem_lon,size(dem_X));
  dem_lat=reshape(dem_lat,size(dem_Y));
  dem_data=DEM.data;
  dem_data(find(dem_data<0))=nan;

%load geocoded int
geo_int=[rlkdir{1} dates(id).name 'geo_2rlks.unw'];
gi=load_any_data(geo_int,'11N');
  phs_X=gi.X;
  phs_Y=gi.Y;
  [phs_lat,phs_lon]=utm2ll(phs_X(:),phs_Y(:),11,'wgs84');
  phs_lon=reshape(phs_lon,size(phs_X));
  phs_lat=reshape(phs_lat,size(phs_Y));
  phs=gi.phs;



    down_factor=16;
    fun = @(block_struct) mean2(block_struct.data) * ones(size(block_struct.data));
        phs = blockproc(phs,[down_factor+2 down_factor+2],fun);
        phs = phs(:,down_factor:down_factor:end);
        phs = phs(down_factor:down_factor:end,:);           
        phs_lon = blockproc(phs_lon,[down_factor+2 down_factor+2],fun);
        phs_lon = phs_lon(:,down_factor:down_factor:end);
        phs_lon = phs_lon(down_factor:down_factor:end,:);
        phs_lat = blockproc(phs_lat,[down_factor+2 down_factor+2],fun);
        phs_lat = phs_lat(:,down_factor:down_factor:end);
        phs_lat = phs_lat(down_factor:down_factor:end,:);
        phs(find(phs==0))=nan;
        %make grid data into vector data
        phs_vectors(:,1)=phs_lon(:);
        phs_vectors(:,2)=phs_lat(:);
        phs_vectors(:,3)=phs(:);
        
        dem_data = blockproc(dem_data,[down_factor+2 down_factor+2],fun);
        dem_data = dem_data(:,down_factor:down_factor:end);
        dem_data = dem_data(down_factor:down_factor:end,:);           
        dem_lon = blockproc(dem_lon,[down_factor+2 down_factor+2],fun);
        dem_lon = dem_lon(:,down_factor:down_factor:end);
        dem_lon = dem_lon(down_factor:down_factor:end,:);
        dem_lat = blockproc(dem_lat,[down_factor+2 down_factor+2],fun);
        dem_lat = dem_lat(:,down_factor:down_factor:end);
        dem_lat = dem_lat(down_factor:down_factor:end,:);
        dem_data(find(dem_data==0))=nan;
        %make grid data into vector data
        dem_vectors(:,1)=dem_lon(:);
        dem_vectors(:,2)=dem_lat(:);
        dem_vectors(:,3)=dem_data(:);
        
fig=figure(1); %plot int
 set(fig,'position',[1 1 1000 700],'Color',[.1 .1 .1])
  cmap = parula(32);
  [cindx,cimap,clim] = shaderel(phs_lon,phs_lat,phs,cmap);
  h=surf(phs_lon,phs_lat,phs,cindx) ;colormap(cimap);caxis(clim)
  shading flat
    grid off
    axis off

    
fig=figure(2); %plot dem
 set(fig,'position',[1 1 1000 700],'Color',[.1 .1 .1])
  cmap = parula(32);
  [cindx,cimap,clim] = shaderel(dem_lon,dem_lat,dem_data,cmap);
  h=surf(dem_lon,dem_lat,dem_data,cindx) ;colormap(cimap);caxis(clim)
  shading flat
    grid off
    axis off
    zlim([-15000 15000])
    
    
%make new grid
range1=floor(min(dem_vectors(:,1))):.001:ceil(max(dem_vectors(:,1)));
range2=floor(min(dem_vectors(:,2))):.001:ceil(max(dem_vectors(:,2)));
[xq,yq]=meshgrid(range1, range2);

vq=griddata(dem_vectors(:,1), dem_vectors(:,2),dem_vectors(:,3),xq,yq);
vq2=griddata(phs_vectors(:,1), phs_vectors(:,2),phs_vectors(:,3),xq,yq);
vq3=vq+vq2*100;
figure
mesh(xq,yq,vq)
% hold on
% plot3(dem_vectors(:,1),dem_vectors(:,2),dem_vectors(:,3),'o')
grid off

figure
mesh(xq,yq,vq3)
% hold on
% plot3(dem_vectors(:,1),dem_vectors(:,2),dem_vectors(:,3),'o')
grid off
zlim([-15000,15000])





