
function Mov=plot_images(flag)
%%% case 1 - plot all unwrapped ints
%%% case 2 - plot all unwrapped ints, in order of rate residual
%%% case 3 - plot inferred dates
% close all;clear all

set_params
% load(ts_paramfile);
% % load('rates');
% ndates         = length(dates);
% nints          = length(ints);
% if strcmp(sat,'S1A')
%     nx=ints(id).width;
%     ny=ints(id).length;
% else
%     [nx,ny,lambda]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');
% 
% end
% newnx = floor(nx./rlooks);
% newny = floor(ny./alooks);

l=1;%for now, just use first rlooks value (usually 4)
fid=fopen(maskfilerlk,'r');
mask=fread(fid,[newnx(l),newny(l)],'real*4');
mask=mask';
badid=find(mask==0);
fclose(fid);

% figure;imagesc(rates);colormap jet

switch flag
    case 1 %plot all ints
        for i=1:nints
            fid=fopen([ints(i).flatrlk '_bell'],'r');
            unw=fread(fid,[newnx,newny],'real*4');
            unw=unw';
%             unw(badid)=NaN;
            imagesc(unw);colorbar
%             caxis([-pi pi])
           
            title(ints(i).name)
             pause
%             Mov(i)=getframe;
            fclose(fid);
        end
        
    case 2 %plot all unw ints, sorted by rate residual (must have run calc_rate_residual.m)
        if(isfield(ints,'rms'))
            [jnk,sortid]=sort([ints.rms]);
            for i=sortid
                fid=fopen(ints(i).unwrlk,'r');
                unw=fread(fid,[newnx(l),newny(l)*2],'real*4');
                unw=unw(:,2:2:end)';
                unw(badid)=NaN;
                imagesc(unw)
                title(ints(i).name)
                Mov(i)=getframe;
                fclose(fid);
                
                
            end
        else
            disp('must run calc_rate_residual first')
        end
     case 3  %plot inferred time series, by date
            fid=fopen([dates(id).unwrlk '_corrected'],'r');
            def1=fread(fid,[newnx(l),newny(l)],'real*4');
            fclose(fid);
        for i=1:ndates
            fid=fopen([dates(i).unwrlk '_corrected'],'r');
            def=fread(fid,[newnx(l),newny(l)],'real*4');
            def=def-def1;
            def=-fliplr(def');
           def=def(500:3800,200:4000);
           fig=figure(2);
           colormap('jet')
           CLIM=([-200 200]);
%             def(badid)=NaN;
            imagesc(def,CLIM);colorbar;hold on
            text(90, 120,num2str(dates(i).name));
            
            
%             title(dates(i).name)
%             title(dates(i).name)
            pause(1)
            Mov(i)=getframe;
                frame=getframe(fig);
                im=frame2im(frame);
                [imind,cm] = rgb2ind(im,256);
            fclose(fid);
            
            imwrite(imind,cm,['date_figs/' dates(i).name],'png');
        end
        
    case 4  %plot inferred time series, by date and create a profile
        for i=1:ndates
            fid=fopen(char(dates(i).unwrlk),'r');
            def=fread(fid,[newnx(l),newny(l)*2],'real*4');
            def=-def';
%             def(badid)=NaN;

            crop_stack=def;%(500:1011,602:775);
        figure(1)
            imagesc(def)
            title(dates(i).name)
            
            meanv(i)=mean(mean(def(2510:2520,695:705)));
            mean_whole(i)=mean(mean(crop_stack));
            crop_stack_meanremoved=crop_stack-meanv(i);
            crop_stack_wholemeanremoved=crop_stack-mean_whole(i);
            u(:,i) = crop_stack(1:end,700);
            u_meanremoved(:,i) = crop_stack_meanremoved(1:end,700);
            u_wholemeanremoved(:,i) = crop_stack_wholemeanremoved(1:end,700);
%             coeff=ones(1,50)/50;
%             u_avg=filter(coeff,1,u(:,i));
  fig=figure(2);
  set(fig,'position',[100 100 900 900])
         subplot(3,1,1); plot(u(:,i));hold on;title(dates(i).name);ylim([-120 50]);%xlim([0 500])
         subplot(3,1,2); plot(u_meanremoved(:,i));hold on;title([dates(i).name ' zero mean removed']);ylim([-120 50]);%xlim([0 500])
         subplot(3,1,3); plot(u_wholemeanremoved(:,i));hold on;title([dates(i).name ' whole mean removed']);ylim([-120 50]);%xlim([0 500])
                %make a GIF for figure2   
                drawnow
                Mov(i)=getframe;
                frame=getframe(fig);
                im=frame2im(frame);
                [imind,cm] = rgb2ind(im,256);
                filename = 'Stacks.gif';

                  if i == 1;
                        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
                  else
                        imwrite(imind,cm,filename,'gif','WriteMode','append');
                  end 
        max_def_pixel(i)                    = (u(540,i)/2)/cosd(23);
        
        max_def_pixel_meanremoved(i)        = (u_meanremoved(540,i)/2)/cosd(23);
        max_def_pixel_wholemeanremoved(i)   = (u_wholemeanremoved(540,i)/2)/cosd(23);

            pause(1)

          fclose(fid);
        end

        
        
    case 6     
      for i=1:ndates
            fid=fopen(char(dates(i).unwrlk),'r');
            def=fread(fid,[newnx(l),newny(l)*2],'real*4');
            def=def';
%             def(badid)=NaN;
%         figure(1)
%             imagesc(def)
%             title(dates(i).name)
            crop_stack=def(500:1011,602:775);
%             meanv(i)=mean(mean(def(630:650,620:630)));

            u(:,i) = crop_stack(1:end,40);
            meanv(i)=mean(u(100:120,i));
            crop_stack_meanremoved=crop_stack-meanv(i);

            u_meanremoved(:,i) = crop_stack_meanremoved(1:end,40);
% 
%         figure(2); 
%          subplot(3,1,1); plot(u(:,i));hold on;title(dates(i).name)
%          subplot(3,1,2); plot(u_meanremoved(:,i));hold on;title([dates(i).name ' zero mean removed'])
%          max_def_pixel(i)                    = u(378,i);
%          max_def_pixel_meanremoved(i)        = u_meanremoved(378,i);
%          pause(1)
          fclose(fid);
      end
        
end       
        
        
%make date vectors for inversion and plotting       
    datenumbers=char(dates.name);
    for i=1:length(dates)
        dnum(i) = str2num(datenumbers(i,:));
    end
    dts=datenum(datenumbers,'yyyymmdd');

% %Invert data points for best fitting line 
         x=dts;%[1:length(max_def_pixel)]';
         G=[ones(ndates,1) x];
        m=inv(G'*G)*G'*max_def_pixel';
        y=m(2)*x+m(1); 
        m2=inv(G'*G)*G'*max_def_pixel_meanremoved';
        y2=m2(2)*x+m2(1); 
        m3=inv(G'*G)*G'*max_def_pixel_wholemeanremoved';
        y3=m3(2)*x+m3(1); 
         %Plot the data points and fits
        figure

        plot(dts,max_def_pixel,'r.');hold on
        datetick('x','keepticks','keeplimits')
        plot(dts,y,'r')
        plot(dts,max_def_pixel_meanremoved,'b.');
        plot(dts,y2,'b');kylestyle
        plot(dts,max_def_pixel_wholemeanremoved,'g.');
        plot(dts,y3,'g');kylestyle

       legend('raw',[num2str(m(2)*365) ' cm/yr'],'zero mean removed', [num2str(m2(2)*365) ' cm/yr'],'whole mean removed', [num2str(m3(2)*365) ' cm/yr']) 

        for i=1:length(u_meanremoved)
            m_all(:,i)=inv(G'*G)*G'*u_meanremoved(i,:)';
            rate(i)=m_all(2,i); 
        end
%         
% %Ro's method
%     %1. remove mean.  This is the vector u_meanremoved(:,i)
%     %2. Find velocity at each point
%         for i=1:length(u_meanremoved)
%             m_all(:,i)=inv(G'*G)*G'*u_meanremoved(i,:)';
%             rate(i)=m_all(2,i); 
%         end
%     %3. In each int, multiply its time spane by the rate from last step to
%     %get a displacement 
%     %4. Remove disp_to_remove from each pixel in each int
%         for i=1:ndates-1
%             for j=1:length(u_meanremoved)
%             disp_to_remove(j,i)= rate(j)*(dates(i+1).dn-dates(i).dn);
%             end
%             new_u(:,i) = u_meanremoved(:,i)-disp_to_remove(:,i);      
%         end
%    
%     %5. re remove mean
%     %6. Add values from step 3 back into each int
%         for i=1:ndates-1
%             new_meanv(i)            = mean(new_u(100:120,i));
%             new_u_meanremoved(:,i)  = new_u(:,i)-new_meanv(i)+disp_to_remove(:,i);
%              fig=figure(2);
%   set(fig,'position',[100 100 900 700])
%          subplot(2,1,1); plot(u(:,i));hold on;title([dates(i).name ' Raw']);ylim([-20 25]);xlim([0 500])
%          subplot(2,1,2); plot(new_u_meanremoved(:,i));hold on;title([dates(i).name ' Rowenas Method']);ylim([-20 25]);xlim([0 500])
%                 %make a GIF for figure2   
%                 drawnow
%                 Mov(i)=getframe;
%                 frame=getframe(fig);
%                 im=frame2im(frame);
%                 [imind,cm] = rgb2ind(im,256);
%                 filename = 'RosMethod.gif';
% 
%                   if i == 1;
%                         imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%                   else
%                         imwrite(imind,cm,filename,'gif','WriteMode','append');
%                   end 
%                   
% % pause(1)
%         end
%              new_u_meanremoved=[new_u_meanremoved ones(length(new_u_meanremoved),1)];
%  
%     %7. Find new velocity at each point
%         for i=1:length(u_meanremoved)
%             new_m_all(:,i)=inv(G'*G)*G'*new_u_meanremoved(i,:)';
%             new_rate(i)=new_m_all(2,i); 
%         end      
%       
% figure;plot(new_rate*365);hold on; plot(rate*365)
% legend('original rate','new rate')
% xlabel('Distance Along Profile (pixels)')
% ylabel('Rate (cm/yr)')
% kylestyle
      
    
    
%     text(10,-4,['raw: ' num2str(m(2)) 'cm/yr'])
%     text(10,-6,['mean removed: ' num2str(m2(2)) 'cm/yr'])

% for i=1:ndates
%     coeff=ones(1,50)/50;
%     u_avg=filter(coeff,1,u(:,i));
%    figure(2); plot(u_avg);hold on
%                    title(ints(i).name)
%                                    Mov(i)=getframe;
% 
% 
% end
