function low_freq_power = lf_power(num_lf_bands)
% Kyle Murray
% July 2017
% Calculates low frequency power of stack of inverted dates and writes to a
% file called lowFreqPower, and saves .mat file called lf_power.mat
% num_lf_bands is the number of low frequency bands to sum to get the
% power. Should be around 2 or 3?  Higher numbers will include more high
% frequency power in the final number. A strong secular rate + seasonal
% signal would have high power at 1 cycle/year or less

getstuff;l=1;
% Load in stack of dates and find FFT at each pixel
alld=zeros(ndates,newny(l),newnx(l));
for i=1:ndates
    if(~exist(dates(i).unwrlk{1}))
        display([dates(i).unwrlk{1} ' does not exist'])
        return
    else
        fid=fopen(dates(i).unwrlk{1},'r');
        tmp=fread(fid,[newnx(l),newny(l)],'real*4');
        alld(i,:,:)=tmp';
    end
end
alld = reshape(alld,[ndates,newnx*newny]);

% Calculate the frequency
freqs=fft(alld,[],1); %transform to freq domain at each pixel
clear alld tmp
P2 = abs(freqs/ndates); %power spectrum
clear freqs
P1 = P2(1:ndates/2+1,:); %one sided power spectrum
P1(2:end-1,:) = 2*P1(2:end-1,:); %one sided power spectrum
ss = sum(P2(1:num_lf_bands,:),1); %sum the power at the lowest 3 freq bands
low_freq_power = reshape(ss,[newny,newnx]); %

% Plot resulting LF power image and write to file
figure;imagesc(low_freq_power);colorbar;caxis([0 40])
    saveas(gcf,['lf_power_raw'],'svg')

fido=fopen(['lowFreqPower' num2str(rlooks(l))],'w');
fwrite(fido,low_freq_power,'real*4');fclose(fido);
save('lf_power','low_freq_power');