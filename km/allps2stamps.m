%Script to take ALLPS structure and interferograms and put them in StaMPS
%structure for the 3D phase unwrapping. 
 clear all;close all
getstuff
% newny=4770;
% newnx=400;newny=400;
% nints=6
%First, we need to take a subset of pixels from our ints that are
%persistent scatterers. This will be based on the mask created using the
%gamma0 file.  

%load in the mask
    fidin  = fopen(maskfilerlk{1},'r','native');
    [jnk,count]=fread(fidin,[newnx newny],'real*4');fclose(fidin)
    msk=logical(fliplr(jnk'));figure;imagesc(msk);
[row,col]=find(msk==1); %save ij values

iidx=find(msk==1);
n_ps=length(row);
ij(:,1)=[1:n_ps];
ij(:,2)=row;
ij(:,3)=col;
a=zeros(size(msk));
for ii=1:n_ps
    a(row(ii),col(ii))=1;
end
% figure;imagesc(a)

%loop through each int and take out the subset of pixels and store each one
%as columns in matrix/file called ph_w
ph_rc=zeros(n_ps,nints);
for ii=1:nints
    fid=fopen([ints(ii).flatrlk{1}],'r');
    int = fread(fid,[newnx*2, newny],'real*4');%CHange to newnx*2 if you didnt' crop initially
%     tmp=fliplr(tmp');%figure;imagesc(tmp) %CHange to read tmp(2:2:end,:) if you didnt' crop initially
    c8=int(1:2:newnx*2,1:newny) + im*int(2:2:newnx*2,1:newny);
    c8=fliplr(c8');
    ph_rc(:,ii)=c8(msk);
   fclose(fid);
end

a=zeros(size(msk));
for ii=1:n_ps
    a(row(ii),col(ii))=ph_rc(ii,1);
end
% figure;imagesc(a)

% geomap_latlon %uncomment this if you don't already have lat/lon

fid1 =   fopen('GEO/lon','r');
lon=    fread(fid1,[newnx,newny],'real*4');fclose(fid1);
fid2 =   fopen('GEO/lat','r');
lat=    fread(fid2,[newnx,newny],'real*4');fclose(fid2);

clear lon_tmp lat_tmp
lon=inpaint_nans(lon');lat=inpaint_nans(lat');
lonlat=zeros(n_ps,2);
% now find the subset of lat/lon corresponding to the PS (row,col)
lonlat(:,1)=lon(msk);
lonlat(:,2)=lat(msk);
a=zeros(size(msk));
for ii=1:n_ps
    a(row(ii),col(ii))=lonlat(ii,2);
end
figure;imagesc(a);


ll0=(max(lonlat)+min(lonlat))/2;
xy=llh2local(lonlat',ll0)*1000;
xy=xy';
sort_x=sortrows(xy,1);
sort_y=sortrows(xy,2);
n_pc=round(n_ps*0.001);
bl=mean(sort_x(1:n_pc,:));          % bottom left corner
tr=mean(sort_x(end-n_pc:end,:));     % top right corner
br=mean(sort_y(1:n_pc,:));          % bottom right  corner
tl=mean(sort_y(end-n_pc:end,:));    % top left corner

heading=load_rscs(dates(id).slc,'HEADING');
theta=(180-heading)*pi/180;
if theta>pi
    theta=theta-2*pi;
end

rotm=[cos(theta),sin(theta); -sin(theta),cos(theta)];
xy=xy';
xynew=rotm*xy; % rotate so that scene axes approx align with x=0 and y=0
if max(xynew(1,:))-min(xynew(1,:))<max(xy(1,:))-min(xy(1,:)) &...
   max(xynew(2,:))-min(xynew(2,:))<max(xy(2,:))-min(xy(2,:))
    xy=xynew; % check that rotation is an improvement
    disp(['Rotating by ',num2str(theta*180/pi),' degrees']);
end
        
xy=single(xy');
[dummy,sort_ix]=sortrows(xy,[2,1]); % sort in ascending y order
xy=xy(sort_ix,:);
xy=[[1:n_ps]',xy];
xy(:,2:3)=round(xy(:,2:3)*1000)/1000; % round to mm

ph_rc=ph_rc(sort_ix,:);
ij=ij(sort_ix,:);
ij(:,1)=1:n_ps;
lonlat=lonlat(sort_ix,:);


 
%build PS structure
day_ix=[1:ndates]';
master_day=[dates(id).dn];
master_ix=id;
day=[dates.dn]';
n_image=ndates;
ifgday(1:nints,1)=[dates([ints.i1]).dn];
ifgday(1:nints,2)=[dates([ints.i2]).dn];
n_ifg=nints;
ifgday_ix(1:nints,1)=[ints.i1];
ifgday_ix(1:nints,2)=[ints.i2];
bperp=[ints.bp]';

% 
save('ps1','day_ix','master_day','master_ix','day','n_image','n_image', ...
    'ifgday','n_ifg','ifgday_ix','bperp','n_ps','ll0','xy','ij','lonlat')
save('rc1','ph_rc','-v7.3')
% save('rc','ph_rc')
% % %%
% clear all;close all
%  ps_unwrap_allps
stamps(6)


