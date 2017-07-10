% Zero Zone Referencing
% Synthetic 2D interferogram normalization using connected components of 
% low laplacian area to correct for ramp and offset. 
% Kyle Murray 2017

clear all;close all


set_params
load(ts_paramfile);
% load('rates');
ndates         = length(dates);
nints          = length(ints);
N=nints; %number of ints to use
subrow=ceil(sqrt(N));
subcol=subrow;
filt_freq=0.04;
filt_order=10;


if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
    [nx,ny,lambda]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

end
newnx = floor(nx./rlooks);
newny = floor(ny./alooks);
[x,y]=meshgrid(1:newnx,1:newny);

%crop area
min_y = 1;
max_y = newny;
min_x = 1;
max_x = newnx;

l=1;%for now, just use first rlooks value (usually 4)
fid=fopen(maskfilerlk{l},'r');
mask=fread(fid,[newnx(l),newny(l)],'real*4');
mask=mask';
badid=find(mask==0);
fclose(fid);
% c=zeros(newny,newnx,N);
% %read in the interferogram
                newnewnx = max_x-min_x+1;
                newnewny = max_y-min_y+1;
                fid=fopen(ints(1).unwrlk{l},'r');
             def_raw1=fread(fid,[newnx(l),newny(l)*2],'real*4');
             def_raw1=def_raw1(:,2:2:end);
             fclose(fid)
for k=1:N

            fid=fopen(ints(k).unwrlk{l},'r');
            def_raw         = fread(fid,[newnx(1),newny(1)*2],'real*4');
            def_raw         = def_raw(:,2:2:end);
            def_raw         = fliplr(def_raw');
            def_raw         = def_raw(min_y:max_y,min_x:max_x);


%             def_raw(badid)  = NaN;
            def_raw         = inpaint_nans(def_raw);
    %plot unfiltered
    figure(1)
        surf(def_raw,'EdgeColor','none');title('unfiltered original ints');kylestyle;hold on
    figure(2)
        subplot(subrow,subcol,k)
        imagesc(def_raw);title(['Unfiltered ' num2str(k)]);colorbar;kylestyle; hold on
    figure(3)
        subplot(subrow,subcol,k)
        plot(def_raw(:,362));title(['unfiltered ' num2str(k)]);colorbar;kylestyle; hold on
        
    %Low Pass filter
        df=designfilt('lowpassiir','FilterOrder',filt_order, ...
            'HalfPowerFrequency',filt_freq,'DesignMethod','butter');
        def = filtfilt(df,def_raw);
        def = filtfilt(df,def');
        def = def';
    
        %Plot filtered
     figure(4)
        subplot(subrow,subcol,k)
        imagesc(def);title(['filtered ' num2str(k)]);colorbar; kylestyle;hold on
        
     figure(5)
         subplot(2,1,1)
        plot(def(:,362));title(['filtered ' num2str(k)]);colorbar;kylestyle; hold on
          subplot(2,1,2)
        plot(def_raw(:,362));title(['unfiltered ' num2str(k)]);colorbar;kylestyle; hold on
  
        
      %Slices  
%         h=20;
%     for jj=1:h:newny
%         kk=h+1:newnx-h-1;
%         diff2_col(h+1:newnx-h-1,jj)=abs((c(kk+h,jj ,k)-2*c(kk,jj ,k)+c(kk-h,jj ,k))*5);
%         diff2_row(h+1:newnx-h-1,jj)=abs((c(jj,kk+h,k)-2*c(jj,kk ,k)+c(jj,kk-h,k))*5);
% 
%         figure(6)
%         plot(diff2_col(h+1:newnx-h-1,jj));title('every 5th column');kylestyle;hold on
%         figure(7)
%         plot(diff2_row(h+1:newnx-h-1,jj));title('every 5th row');kylestyle;hold on
%     end
    
%Compute Laplacian (2nd derivative 
    c_raw(:,:,k)=def_raw;
    c(:,:,k)=def;
    dif2(:,:,k)=abs(del2(def,50,50)*4e6);
    figure(8)
    subplot(subrow,subcol,k)
    imagesc(dif2(:,:,k));colorbar;title('Laplacian');kylestyle;


end
%%
%Now create a logical matrix with connected area of laplacian values below
%some threshold. We will find the threshold based on statistics of all the
%ints.  Threshold will be defined so that all ints will have an area with
%connected points below it.  We should make a histogram of the values and
%then define the threshold to only include the lowest 10% of points.  
[x,y]=meshgrid(1:newnewnx,1:newnewny);
    %First Calculate the stack median and variance
    medians=median(dif2,3); %calculates median along 3rd dimension
    variances=var(dif2,1,3);
    
    figure(9)
        subplot(2,1,1)
        imagesc(medians);colorbar;title('medians of laplacian');kylestyle;
        subplot(2,1,2)
        imagesc(variances);colorbar;title('variances of laplacian');kylestyle;
    
    figure(10)
        hist(medians(:),101);title('Histogram of median laplacian values');kylestyle;
    
    sort_med=sort(medians(:));
    med_thresh=sort_med(floor(length(medians(:))/4))
    sort_var=sort(variances(:));
    var_thresh=sort_var(floor(length(variances(:))/4))
    
    msk_med=zeros(size(medians));
    msk_med(medians<med_thresh)=1;
    msk_var=zeros(size(variances));
    msk_var(variances<var_thresh)=1;
    
    figure(11)
        subplot(2,1,1)
        imagesc(msk_med);colorbar;title('medians mask');kylestyle;
        subplot(2,1,2)
        imagesc(msk_var);colorbar;title('variances mask');kylestyle;
    
 %Find connected components and find largest area   
    [concomp,count_concomp]=bwlabel(msk_med,4);
    figure(12)
        imagesc(concomp);colorbar;title('Connected Components that meet threshold');kylestyle;
    
    cc=bwconncomp(msk_med);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [biggest,idx] = max(numPixels);
    mask=zeros(length(def(:)),1);
    mi=def(:);
    good_points=(cc.PixelIdxList{idx});
    mask(good_points)=1;
    mask=logical(mask);
    mi(~mask)=0;
    
    masked_int=reshape(mi,size(def));
    figure(13)
        imagesc(masked_int);colorbar;title('Masked interferogram example');kylestyle;
    
  %Now use the area we found to solve for ramp and offset in each
  %interferogram 
  
      Xg = x(mask);
      Yg = y(mask);
      G=[ones(sum(mask(:)),1) Xg Yg Xg.*Yg Xg.^2 Yg.^2 ];
      Gg = inv(G'*G)*G';
  
      corrected=zeros(size(c));
      
dn    = [dates.dn];
dn    = dn-dn(1);
  for k=1:N
      int=c(:,:,k);
      int_raw=c_raw(:,:,k);
%       int(~mask)=0;
      mod=Gg*int(mask);
      synth = mod(1)+mod(2)*x+mod(3)*y+mod(4)*x.*y+mod(5)*x.^2+mod(6)*y.^2;
      res   = int-synth;
      res_raw= int_raw-synth;
    %find median value in each int
%     median(median(masked_int(masked_int~=0)))
      
      corrected(:,:,k)=res_raw;
      figure(14)
       subplot(subrow,subcol,k);
      imagesc(res);colorbar;title(['Corrected int ' k]);kylestyle;hold on

      
        %compare surf plots
      figure(15)
      surf(res,'EdgeColor','none');colorbar;title(['Corrected ints ' k]);kylestyle;hold on
      
        %plot some profiles to check
      figure(16)
      plot(res(:,362));title('filtered/corrected');hold on
      figure(17)
      subplot(2,1,1)
      plot(c_raw(:,362,k));title('originals');
      ylim([-100 40]);hold on
      subplot(2,1,2)
      plot(res_raw(:,362));title('unfiltered/corrected');
      ylim([-100 40]);hold on      
  end     

  %make time series with corrected dates
l=1;

[X,Y]=meshgrid(1:newnx(l),1:newny(l));
    
    alld=zeros(ndates,newny(l),newnx(l));
    for i=1:N
        alld(i,:,:)=c_raw(:,:,i);
    end
    
    G  = [ones(length(dn),1) dn'];
    Gg = inv(G'*G)*G';
    
    alld   = reshape(alld,[ndates,newnx(l)*newny(l)]);
    mod    = Gg*alld;
    offs   = reshape(mod(1,:),[newny(l) newnx(l)]);
    rates  = reshape(mod(2,:),[newny(l),newnx(l)])*lambda/(4*pi)*100*365; %cm/yr
    synth  = G*mod;
    res2   = (alld-synth)*lambda/(4*pi)*100; %cm
    
    %mask
    
    fout1=fopen(['rates_' num2str(rlooks(l))],'w');
    for i=1:newny(l)
        fwrite(fout1,rates(i,:),'real*4');
    end
    fclose('all')

save('rates','rates')
figure
imagesc(-rates);colorbar;caxis([-10 35])


