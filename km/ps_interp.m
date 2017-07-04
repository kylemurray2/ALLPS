%load in an unw int, interpolate, and unwrap
%test
clear all;close all
getstuff
%Define these things:______________________________________________________
filtmode=1; %1 for bell filter, 2 for cone filter
gamma=0.4; %threshold for gamma0 mask (high values for gamma and alpha are good)
alpha=0.9; %threshold for correlation in individual int
rx=2; ry=rx*pixel_ratio; %bell radius (used in filtmode 1)
R=2; %cone radius (used in filtmode 2)
%__________________________________________________________________________

getstuff;
im     = sqrt(-1);
system(['mkdir ' rlkdir{1} 'orig']);
%load mask.cor
mskfile=[rlkdir{1} 'mask_4rlks.r4'];
fid=fopen( maskfilerlk{1},'r','native');
msk=fread(fid,[newnx,newny],'real*4');
msk=flipud(msk');
fclose(fid);
for ii=1:nints
    
    display(['filtering ' ints(ii).name])
    %load int phase and correlation
    intfile=[ints(ii).flatrlk{1}];
    fid=fopen(intfile,'r','native');
    [rmg,count] = fread(fid,[newnx*2,newny],'real*4');
    status      = fclose(fid);
    real        = flipud((rmg(1:2:newnx*2,1:newny))');
    imag        = flipud((rmg(2:2:newnx*2,1:newny))');
    %       cor         = abs(real+im*imag);
    phs1        = angle(real+im*imag);
    
    corfile=[ints(ii).flatrlk{1} '_cor'];
    fid=fopen(corfile,'r','native');
    [rmg,count] = fread(fid,[newnx,newny*2],'real*4');
    status      = fclose(fid);
    cor         = flipud((rmg(1:newnx,1:2:newny*2))');
    
    %mask int to leave PS
    mask=msk<gamma & cor<alpha;     %high values are good
    
%     figure;imagesc(msk);colorbar
%     figure;imagesc(cor);colorbar
%     figure;imagesc(mask);colorbar
%     
    real(mask)=0;
    imag(mask)=0;
    
    %
    % % Do the interpolation
    %
    switch filtmode
        case 1
          
            rx2=floor(rx*3);
            ry2=floor(ry*3);
            gausx = exp(-[-rx2:rx2].^2/rx^2);
            gausy = exp(-(-ry2:ry2).^2/ry^2);
            gaus  = gausy'*gausx;
            gaus = gaus-min(gaus(:));
            gaus  = gaus/sum(gaus(:));
            rea_f=zeros(size(mask));
            ima_f=zeros(size(mask));
            
            msk_f=conv2(double(~mask),gaus,'same');
            rea_f=conv2(real,gaus,'same');
            ima_f=conv2(imag,gaus,'same');
            
            rea_f=rea_f./msk_f;
            ima_f=ima_f./msk_f;
            real_final=rea_f+real;
            imag_final=ima_f+imag;
            
            phs = angle(real_final+im*imag_final);
            phs(isnan(phs))=0;
            
            display([num2str(100*(sum(mask(:))/(newnx*newny))) '% of points left after masking'])
            fid=fopen('phs','w');
            fwrite(fid,flipud(phs)','real*4');
            fclose(fid);
            system(['mag_phs2cpx ' maskfilerlk{1} ' phs ' ints(ii).flatrlk{1} '_bell ' num2str(newnx)]);
            
        case 2
            win_dimension=R*2+1;
            win=ones(win_dimension);%make an odd window of ones
            weight=zeros(size(win));
            for i=1:win_dimension
                for j=1:win_dimension
                    r(i,j)=sqrt(((R+1)-i)^2+((R+1)-j)^2); %distance from center of window
                    weight(i,j)=exp((-r(i,j)^2)/(2*R)); %distance weighting
                end
            end
            
            weight=weight/sum(weight(:));
            % %
            rea_f=zeros(size(mask));
            ima_f=zeros(size(mask));
            
            for j=1:newny-win_dimension
                rea_f(j:j+win_dimension-1,:)=conv2(real(j:j+win_dimension-1,:),weight,'same');
                ima_f(j:j+win_dimension-1,:)=conv2(imag(j:j+win_dimension-1,:),weight,'same');
            end
            real_final=rea_f+real;
            imag_final=ima_f+imag;
            
            phs = angle(real_final+im*imag_final);
            
            display([num2str(100*(sum(mask(:))/(newnx*newny))) '% of points left after masking'])
            fid=fopen('phs','w');
            fwrite(fid,flipud(phs)','real*4');
            fclose(fid);
            system(['mag_phs2cpx ' maskfilerlk{1} ' phs ' ints(ii).flatrlk{1} '_cone ' num2str(newnx)]);
            
    end
    
    
end

% system(['mv ' rlkdir{1} '*_orig ' rlkdir{1} 'orig/']);

%move orig files back
% for kk=1:nints
%        system(['mv ' rlkdir{1} 'flat_' ints(kk).name '_4rlks.int_orig ' ints(ii).flatrlk{1}]);
% end