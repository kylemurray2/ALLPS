set_params
load('ts_paramfile');

ndates         = length(dates);
nints          = length(ints);


[X,Y] = meshgrid(1:newnx,1:newny);

dn    = [dates.dn];
dn    = dn-dn(1);

for l=1:length(rlooks)
%for l=1:1
[X,Y]=meshgrid(1:newnx(l),1:newny(l));
    
    alld=zeros(ndates,newny(l),newnx(l));
    for i=1:ndates
        fid=fopen(dates(i).unwrlk,'r');
        tmp=fread(fid,[newnx(l),newny(l)],'real*4');
        alld(i,:,:)=tmp';
    end
    
    G  = [ones(length(dn),1) dn'];
    Gg = inv(G'*G)*G';
    
    alld   = reshape(alld,[ndates,newnx(l)*newny(l)]);
    mod    = Gg*alld;
    offs   = reshape(mod(1,:),[newny(l) newnx(l)]);
    rates  = reshape(mod(2,:),[newny(l),newnx(l)])*lambda/(4*pi)*1000*365; %mm/yr
    synth  = G*mod;
    res    = (alld-synth)*lambda/(4*pi)*1000; %mm
    resstd = std(res,1);
    resstd = reshape(resstd,[newny(l) newnx(l)]);
    
    %mask
%     fidin  = fopen('TS/looks4/mask_4rlks.r4','r','native');
%     msk=fread(fidin,[newnx,newny],'real*4');
%     msk=msk';
%     rates(msk<0.3)=0;
%         rates=tmp>0.1;
%         fwrite(fidout,out,'integer*1');
 
    
    
    fout1=fopen(['rates_' num2str(rlooks(l))],'w');
    fout2=fopen(['ratestd_' num2str(rlooks(l))],'w');
    for i=1:newny(l)
        fwrite(fout1,rates(i,:),'real*4');
        fwrite(fout2,resstd(i,:),'real*4');
    end
    fclose('all')
end

figure
imagesc(-rates)
caxis([-30 30])