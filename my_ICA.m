%Do independent component analysis

%This will interpolate between SBAS dates and make a 3D surface time series
%animation.  

close all;clear all
down_factor=2;
filt_strength = 0.2;
set_params
load(ts_paramfile);

ndates         = length(dates);
nints          = length(ints);
if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
    [nx,ny,lambda]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

end
newnx = floor(nx./rlooks);
newny = floor(ny./alooks);

l=1;%for now, just use first rlooks value (usually 4)
% fid=fopen(maskfilerlk{l},'r');
% mask=fread(fid,[newnx(l),newny(l)],'real*4');
% mask=mask';
% badid=find(mask==0);
% fclose(fid);

datenumbers=char(dates.name);

for i=1:length(dates)
    dnum(i) = str2num(datenumbers(i,:));
end

d=datenum(datenumbers,'yyyymmdd');
dy=d(1:ndates)./365.25;
             
            %Design down sampling block function
            fun = @(block_struct) mean2(block_struct.data) * ones(size(block_struct.data));
            %Design Low pass butterworth filter
%              df=designfilt('lowpassiir','FilterOrder',5, ...
%             'HalfPowerFrequency',filt_strength,'DesignMethod','butter');
        
%Load Master int

        fid=fopen(char(dates(1).unwrlk),'r');
            a1=fread(fid,[newnx(l),newny(l)*2],'real*4');
            a1=fliplr(a1'); 
            a1 = blockproc(a1,[down_factor+2 down_factor+2],fun);
            a1 = a1(:,down_factor:down_factor:end);
            a1 = a1(down_factor:down_factor:end,:);

% figure
% load('watermask');

        for i=1:ndates
            if exist(dates(1).unwrlk{1})
            fid=fopen(char(dates(i).unwrlk),'r');
            a=fread(fid,[newnx(l),newny(l)*2],'real*4');
            a=fliplr(a');       
            a = blockproc(a,[down_factor+2 down_factor+2],fun);
            a = a(:,down_factor:down_factor:end);
            a = a(down_factor:down_factor:end,:);
            a = a-a1;
            fclose(fid); 
            stack(i,:)=a(:);
            end
        end

%  %do ICA at each pixel
%   icasig=zeros(size(stack));      
% for i=1:length(stack(:,1,1))
%     for j=1:length(stack(1,:,1))        
%         it=[squeeze(stack(i,j,:)),squeeze(stack(i+1,j,:)),squeeze(stack(i,j+1,:)),squeeze(stack(i+1,j+1,:))]';
%         
%         icasig=fastica(stack);
   ica=fastica(stack);
%      end
% end       



nICA=8; %ICAs to plot
icaP=zeros(size(a));
for kk=1:nICA
icaP=reshape(ica(kk,:),size(a));
figure
imagesc(icaP);title(['ICA ' num2str(kk)]);colorbar
end
%calc rates for ica 1



