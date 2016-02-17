function fitramp(thresh,xedge,waterheight)
set_params
load(ts_paramfile);

ndates    = length(dates);
nints     = length(ints);
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

[nx,ny]   = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx     = floor(nx./rlooks)
newny     = floor(ny./alooks);

if(isempty(xedge))
    xedge=[1 0];
end
if(isempty(waterheight))
    waterheight=-3000;
end
fullresheightfile=[oldintdir 'radar.hgt'];
if(~exist(fullresheightfile))
    disp(['full res height file should exist: ' fullresheightfile])
    return
end

for l=1:length(rlooks)

    [X,Y]=meshgrid(1:newnx(l),1:newny(l));
    
    lookheightfile=[oldintdir 'radar_' num2str(rlooks(l)) 'rlks.hgt'];
    if(~exist(lookheightfile))
        command=['look.pl ' fullresheightfile ' ' num2str(rlooks(l)) ' ' num2str(rlooks(l)*pixel_ratio)];
        mysys(command);
    end
    
    fiddem  = fopen(lookheightfile,'r');
    tmp     = fread(fiddem,[newnx(l),newny(l)*2],'real*4');
    dem     = tmp(:,2:2:end)';
    fclose(fiddem);
    
    fidmask = fopen(['res_' num2str(rlooks(l))],'r');
    tmp     = fread(fidmask,[newnx(l),newny(l)],'real*4');
    stdmask = tmp';
    stdmask(stdmask>thresh)=NaN;   
    fclose(fidmask);
    
    edgemask = ones(size(stdmask));
    edgemask(:,[1:xedge(1) end-xedge(2):end],:)=NaN;
    
    watermask = dem;
    watermask(watermask<waterheight)=NaN;
    %add all together
    mask = isfinite(stdmask+edgemask+watermask);
    disp([num2str(sum(mask(:))/newnx(l)/newny(l)*100) '% points left after masking'])
    
    %invert for ramp with remaining points
    Xg = X(mask);
    Yg = Y(mask);
    G  = [ones(sum(mask(:)),1) Xg Yg Xg.*Yg Xg.^2 Yg.^2 dem(mask)];
    Gg = inv(G'*G)*G';
    
    
    for i=1:nints
        fid = fopen(ints(i).unwrlk{l},'r');
        tmp = fread(fid,[newnx(l),newny(l)*2],'real*4');
        fclose(fid);
        
        phs   = tmp(:,2:2:end)';
        mod   = Gg*phs(mask);
        synth = mod(1)+mod(2)*X+mod(3)*Y+mod(4)*X.*Y+mod(5)*X.^2+mod(6)*Y.^2+mod(7)*dem;
        res   = phs-synth;
        res(isnan(watermask+edgemask))=0;
        tmp(:,2:2:end) = res';
        
        %write flatenned unw file to output.
        movefile(ints(i).unwrlk{l},[ints(i).unwrlk{l} '_old']);
        fid=fopen(ints(i).unwrlk{l},'w');
        fwrite(fid,tmp,'real*4');
        fclose(fid);
        
    end
end
save(ts_paramfile,'dates','ints');

