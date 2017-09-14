%bandpass image filter
% function bandPass_dates(fstrength)
set_params
for fstrength=[1 5 20 80 160];
    for ii=1:ndates
        % Specify inputs and outputs
        % maskfile = maskfilerlk{1};
        % fid2   = fopen([infile '_filt'],'w');
        
        % Load Phase
        infile = [dates(ii).unwrlk '_corrected'];
        outfile = [dates(ii).unwrlk '_filt'];
        fid1   = fopen(infile,'r');
        [a,count] = fread(fid1,[newnx,newny],'real*4');
        phs=a';
        phs=fliplr(phs);
        % Load Mask
        fid5   = fopen(maskfile,'r');
        [a,count] = fread(fid5,[newnx,newny],'real*4');
        a      = a==1;
        gam    = a';
        bad    = ~gam;
        
        % Apply mask to phase
        pmask=phs;
        pmask(bad) =nan;
        
        % Transform phase to frequency domain
        phs_freq = fft2(phs);
        phs_freq = fftshift(phs_freq);
        
        figure;fftshow(phs_freq,'log')
        title('Fourier Spectrum of Image');colorbar
        %
        % Make filters
        % gauss_width1 = 200;
        % fig=figure(22);
        %   set(fig,'position',[1 1 2000 600],'Color',[.1 .1 .1] );kylestyle
        
        % for ii = 1:3%:40;
        
        
        xoff=floor(newnx/2);
        yoff=floor(newny/2);
        [X,Y] = meshgrid(1-xoff:newnx-xoff,1-yoff:newny-yoff);
        
        fstrength=5;
        g1=fstrength/2;
        gauss1 = exp((-X.^2-Y.^2)/g1);
            g2=fstrength;
            gauss2 = exp((-X.^2-Y.^2)/(g2^2));
         gauss3 = gauss2-gauss1;
        
        
            figure
            subplot(1,3,1);imagesc(gauss1);colorbar;title('filter 1')
            xlim([(newnx/2-10) (newnx/2+10)]);
            ylim([(newny/2-10) (newny/2+10)]);
            subplot(1,3,2);imagesc(gauss2);colorbar;title('filter 2')
            xlim([(newnx/2-10) (newnx/2+10)]);
            ylim([(newny/2-10) (newny/2+10)]);
            subplot(1,3,3);imagesc(gauss3);colorbar;title('filter 3')
            xlim([(newnx/2-10) (newnx/2+10)]);
            ylim([(newny/2-10) (newny/2+10)]);

        % Apply filter to freq domain
        phs_freq_filt = gauss3.*phs_freq;
        phs_freq_filt = ifftshift(phs_freq_filt);
        r=range(phs_freq_filt(:));
        fl = log(1+abs(r))
fm = max(fl(:));
im2uint8(fl/fm)
        phs_filt = ifft2(phs_freq_filt);
        phs_filt = real(phs_filt);
        
        phs_diff=phs-phs_filt;
        
        % Plot masked phase
        fig=figure(1)
        subplot(1,3,1);imagesc(phs);colorbar;title('Original Phase');caxis([-25 100]);
        subplot(1,3,2);imagesc(phs_filt);colorbar;title('Filtered Phase');caxis([-25 100]);
        subplot(1,3,3);imagesc(phs_diff);colorbar;title('Phase minus filtered');caxis([-25 100]);
        colormap('jet')
        if ~exist('filt_figs','dir')
            !mkdir filt_figs
        end
        drawnow
        Mov(ii)=getframe;
        frame=getframe(fig);
        im=frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        imwrite(imind,cm,['filt_figs/filt_' num2str(fstrength) '.png'],'png');
       
        fido=fopen(outfile,'w');
        fwrite(fido,phs_diff','real*4');
        fclose(fido);
        
    end
end
