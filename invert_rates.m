set_params
load(ts_paramfile);
if exist('watermask','file')
load('watermask');
end
ndates         = length(dates);
nints          = length(ints);
if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
     [nx,ny,lambda]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');
end
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);

% if exist('TS/looks4/4rlks.rsc')
% [newnx,newny,lambda] = load_rscs('TS/looks4/4rlks','WIDTH','FILE_LENGTH','WAVELENGTH');
% end

% [X,Y] = meshgrid(1:newnx,1:newny);

dn    = [dates.dn];
dn    = dn-dn(1);

for l=1:length(rlooks)
 
    alld=zeros(ndates,newny(l),newnx(l));
    for i=1:ndates
        fid=fopen(dates(i).unwrlk{1},'r');
        tmp=fread(fid,[newnx(l),newny(l)],'real*4');
        alld(i,:,:)=tmp';
    end
    
    G  = [ones(length(dn),1) dn'];
    Gg = inv(G'*G)*G';
    
    alld   = reshape(alld,[ndates,newnx(l)*newny(l)]);
    mod    = Gg*alld;
    offs   = reshape(mod(1,:),[newny(l) newnx(l)]);
    rates  = reshape(mod(2,:),[newny(l),newnx(l)])*lambda/(4*pi)*100*365; %cm/yr
    synth  = G*mod;
    res    = (alld-synth)*lambda/(4*pi)*100; %cm
    resstd = std(res,1);
    resstd = reshape(resstd,[newny(l) newnx(l)]);
    
    %mask
    fidin  = fopen(['TS/looks' num2str(rlooks) '/mask_' num2str(rlooks) 'rlks.r4'],'r','native');
    msk=fread(fidin,[newnx,newny],'real*4');
    msk=msk';
%     rates(watermask'==0)=0;
%     rates(:,2389:end)=0;
%   rates(msk<0.3)=nan;
%          rates=tmp>0.1;
%         fwrite(fidout,out,'integer*1');
%     crop=logical(zeros(size(rates)));
%     crop(:,1:70)=1;
%     crop(:,(newnx-30):newnx)=1;
%     crop(1:3,:)=1;crop((newny-3):newny,:)=1;
%     rates(crop)=0;
     
    fout1=fopen(['rates_' num2str(rlooks(l))],'w');
    fout2=fopen(['ratestd_' num2str(rlooks(l))],'w');
    for i=1:newny(l)
        fwrite(fout1,rates(i,:),'real*4');
        fwrite(fout2,resstd(i,:),'real*4');
    end
    fclose('all')
end
save('rates','rates')
figure
imagesc(-rates)
% caxis([-20 20])