clear all;close all
do_rates=1;
mcov_flag=0;
set_params
dn    = [dates.dn];
dn    = dn-dn(1);

if do_rates
    alld=zeros(ndates,newny,newnx);
    for i=1:ndates
        fid=fopen([dates(i).unwrlk '_corrected'],'r');
        tmp=fread(fid,[newnx,newny],'real*4');
        alld(i,:,:)=tmp';
    end
    
    G  = [ones(length(dn),1) dn'];
    Gg = inv(G'*G)*G';
    
    alld   = reshape(alld,[ndates,newnx*newny]);

    mod    = Gg*alld;
    offs   = reshape(mod(1,:),[newny newnx]);
    rates  = reshape(mod(2,:),[newny,newnx])*lambda/(4*pi)*100*365; %cm/yr
    synth  = G*mod;
    res    = (alld-synth)*lambda/(4*pi)*100; %cm
    clear synth mod
    resstd = std(res,1);
    resstd = reshape(resstd,[newny newnx]);
    save('rates','rates')
else
    load 'rates'  
end

if(mcov_flag)
    for jj=1:length(alld(1,:))
        co=cov(alld(:,jj));
        mcov=diag(Gg*co*Gg');
        rate_uncertainty(jj)=1.96*mcov(2)^.5;
    end
    rate_uncertainty=reshape(rate_uncertainty,[newny,newnx])*lambda/(4*pi)*100*365; %cm/yr
    figure
    plot(-rates(484:end,2575),'k.');hold on
    plot(-rates(484:end,2575)+rate_uncertainty(484:end,2575),'b--');hold on
    plot(-rates(484:end,2575)-rate_uncertainty(484:end,2575),'b--');hold on
end

%mask
fidin  = fopen(['TS/looks' num2str(rlooks) '/mask_' num2str(rlooks) 'rlks.r4'],'r','native');
msk=fread(fidin,[newnx,newny],'real*4');
msk=msk';
%     rates(watermask'==0)=0;
%     rates(:,2389:end)=0;
rates(msk<0.25)=nan;
%     rates=tmp>0.1;
%     fwrite(fidout,out,'integer*1');
%     crop=logical(zeros(size(rates)));
%     crop(:,1:70)=1;
%     crop(:,(newnx-30):newnx)=1;
%     crop(1:3,:)=1;crop((newny-3):newny,:)=1;
%     rates(crop)=0;

msk=zeros(size(rates));
msk(30:newny-30,30:newnx-30)=1;
rates(msk==0)=nan;

fout1=fopen(['rates_' num2str(rlooks)],'w');
fout2=fopen(['ratestd_' num2str(rlooks)],'w');
for i=1:newny
    fwrite(fout1,rates(i,:),'real*4');
    %     fwrite(fout2,resstd(i,:),'real*4');
end
fclose('all')

figure
imagesc(-rates)
% caxis([-20 20])




