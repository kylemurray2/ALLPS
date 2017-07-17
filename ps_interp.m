%load in an unw int, interpolate, and unwrap
%test
clear all;close all
getstuff
%Define these things:______________________________________________________
filtmode=1; %1 for bell filter, 2 for cone filter
gamma=0.4; %threshold for gamma0 mask (high values for gamma and alpha are good)
alpha=0.9; %threshold for correlation in individual int
rx=4; ry=rx*pixel_ratio; %bell radius (used in filtmode 1)
R=2; %cone radius (used in filtmode 2)
%__________________________________________________________________________

getstuff;
im     = sqrt(-1);
system(['mkdir ' rlkdir{1} 'orig']);
%load mask.cor
mskfile=[rlkdir{1} 'mask_4rlks.r4'];
fid=fopen( maskfilerlk{1},'r','native');
msk=fread(fid,[newnx,newny],'real*4');
% msk=flipud(msk');
fclose(fid);


parfor ii=1:nints
 par_ps_interp(ii,msk,gamma,alpha,rx,ry)
            
%         case 2
%             win_dimension=R*2+1;
%             win=ones(win_dimension);%make an odd window of ones
%             weight=zeros(size(win));
%             for i=1:win_dimension
%                 for j=1:win_dimension
%                     r(i,j)=sqrt(((R+1)-i)^2+((R+1)-j)^2); %distance from center of window
%                     weight(i,j)=exp((-r(i,j)^2)/(2*R)); %distance weighting
%                 end
%             end
%             
%             weight=weight/sum(weight(:));
%             % %
%             rea_f=zeros(size(mask));
%             ima_f=zeros(size(mask));
%             
%             for j=1:newny-win_dimension
%                 rea_f(j:j+win_dimension-1,:)=conv2(real(j:j+win_dimension-1,:),weight,'same');
%                 ima_f(j:j+win_dimension-1,:)=conv2(imag(j:j+win_dimension-1,:),weight,'same');
%             end
%             real_final=rea_f+real;
%             imag_final=ima_f+imag;
%             
%             phs = angle(real_final+im*imag_final);
%             
%             display([num2str(100*(sum(mask(:))/(newnx*newny))) '% of points left after masking'])
%             fid=fopen('phs','w');
%             fwrite(fid,flipud(phs)','real*4');
%             fclose(fid);
%             system(['mag_phs2cpx ' maskfilerlk{1} ' phs ' ints(ii).flatrlk{1} '_cone ' num2str(newnx)]);
            
    end
    
    


% system(['mv ' rlkdir{1} '*_orig ' rlkdir{1} 'orig/']);

%move orig files back
% for kk=1:nints
%        system(['mv ' rlkdir{1} 'flat_' ints(kk).name '_4rlks.int_orig ' ints(ii).flatrlk{1}]);
% end