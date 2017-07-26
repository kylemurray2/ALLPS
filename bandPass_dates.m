%bandpass image filter
function bandPass_dates(fstrength)
getstuff
% fstrength=3;
for ii=1:nints
    % Specify inputs and outputs
    % maskfile = maskfilerlk{1};
    % fid2   = fopen([infile '_filt'],'w');
    
    % Load Phase
    infile = [ints(ii).unwrlk{1} '_orig'];
    outfile = [ints(ii).unwrlk{1}];
    fid1   = fopen(infile,'r');
    [a,count] = fread(fid1,[newnx,newny],'real*4');
    phs=a';
    
    % Load Mask
    % fid5   = fopen(maskfile,'r');
    % [a,count] = fread(fid5,[newnx,newny],'real*4');
    % a      = a==1;
    % gam    = a';
    % bad    = ~gam;
    
    % % Apply mask to phase
    % pmask=phs;
    % pmask(bad) =nan;
    
    
    
    % Transform phase to frequency domain
    phs_freq = fft2(phs);
    phs_freq = fftshift(phs_freq);
    
    
    % figure;fftshow(phs_freq,'log')
    % title('Fourier Spectrum of Image');colorbar
    %
    % Make filters
    % gauss_width1 = 200;
    % fig=figure(22);
    %   set(fig,'position',[1 1 2000 600],'Color',[.1 .1 .1] );kylestyle
    
    % for ii = 1:3%:40;
    
    
    xoff=floor(newnx/2);
    yoff=floor(newny/2);
    [X,Y] = meshgrid(1-xoff:newnx-xoff,1-yoff:newny-yoff);
    
    g1=5;%fstrength1^1.5;
    gauss1 = 0;%exp((-X.^2-Y.^2)/g1^2);
    g2=g1+(2+fstrength^1.4);
    gauss2 = exp((-X.^2-Y.^2)/(g2^2));
    gauss3 = gauss2-gauss1;
    
    %
    %  figure
    % subplot(1,3,1);imagesc(gauss1);colorbar;title('filter 1')
    % subplot(1,3,2);imagesc(gauss2);colorbar;title('filter 2')
    % subplot(1,3,3);imagesc(gauss3);colorbar;title('filter 3')
    
    % Apply filter to freq domain
    phs_freq_filt = gauss3.*phs_freq;
    phs_freq_filt = ifftshift(phs_freq_filt);
    phs_filt = ifft2(phs_freq_filt);
    phs_filt = real(phs_filt);
    
    phs_diff=phs-phs_filt;
    
    % % Plot masked phase
    %
    % subplot(1,3,1);imagesc(phs);colorbar;title('Original Phase');caxis([-20 10]);
    % subplot(1,3,2);imagesc(phs_filt);colorbar;title('Filtered Phase');caxis([-20 10]);
    % subplot(1,3,3);imagesc(phs_diff);colorbar;title('Phase minus filtered');caxis([-20 10]);
    %
    %  drawnow
    %                 Mov(ii)=getframe;
    %                 frame=getframe(fig);
    %                 im=frame2im(frame);
    %                 [imind,cm] = rgb2ind(im,256);
    %                 filename = 'filters_BP.gif';
    %
    %                   if ii == 1;
    %                         imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    %                   else
    %                         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1/2);
    %                   end
    fido=fopen(outfile,'w');
    fwrite(fido,phs_diff','real*4');
    fclose(fido);
    
end

