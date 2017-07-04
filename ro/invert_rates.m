set_params
load(ts_paramfile);

ndates         = length(dates);
nints          = length(ints);
[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

newnx = floor(nx./rlooks)
newny = floor(ny./alooks); 
if (1)
for i=2:ndates
    filter_dates(dates(i).unwrlk{1},newnx,newny,100,100,'filtmask');
end
end
system(['ln -s ' dates(1).unwrlk{1} ' ' dates(1).unwrlk{1} '_filt']);
system(['ln -s ' dates(1).unwrlk{1} ' ' dates(1).unwrlk{1} '_filtdiff']);



[X,Y] = meshgrid(1:newnx,1:newny);
bp    = [dates.bp];
dn    = [dates.dn];
dn    = dn-dn(1);

for l=1:length(rlooks)
%for l=1:1
[X,Y]=meshgrid(1:newnx(l),1:newny(l));
    
    alld=zeros(ndates,newny(l),newnx(l));
    for i=1:ndates
        fid=fopen([dates(i).unwrlk{l} '_filtdiff'],'r');
        tmp=fread(fid,[newnx(l),newny(l)],'real*4');
        alld(i,:,:)=tmp';
    end
    
    G  = [ dn' bp'/max(bp)];
    Gg = inv(G'*G)*G';
    covm=Gg*Gg';
    
    alld   = reshape(alld,[ndates,newnx(l)*newny(l)]);
    mod    = Gg*alld;
    %offs   = reshape(mod(1,:),[newny(l) newnx(l)]);
    rates  = reshape(mod(1,:),[newny(l),newnx(l)])*lambda/(4*pi)*1000*365; %mm/yr
    heights= reshape(mod(2,:),[newny(l),newnx(l)]);
    synth  = G*mod;
    res    = (alld-synth);
    resvar = var(res,1); %variance of residual, in radians
    modvar = resvar*covm(1); % variance in radians
    modstd = reshape(sqrt(modvar)*lambda/(4*pi)*1000*365,[newny(l) newnx(l)]); %in mm/yr
    
    fout1=fopen(['rates_' num2str(rlooks(l))],'w');
    fout2=fopen(['ratestd_' num2str(rlooks(l))],'w');
    fout3=fopen(['heights_' num2str(rlooks(l))],'w');
    for i=1:newny(l)
        fwrite(fout1,rates(i,:),'real*4');
        fwrite(fout2,modstd(i,:),'real*4');
        fwrite(fout3,heights(i,:),'real*4');
    end
    fclose('all')
end
