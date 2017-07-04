function mask_height(hgts)
%%%acts on int file
%%% mask = 1x4 vector of left,right, top,bottom to mask, 0 or larger

set_params
load(ts_paramfile);


ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

for l=1:length(rlooks)
    
    
    lookheightfile=[oldintdir 'radar_' num2str(rlooks(l)) 'rlks.hgt'];
    if(~exist(lookheightfile))
        command=['look.pl ' fullresheightfile ' ' num2str(rlooks(l)) ' ' num2str(rlooks(l)*pixel_ratio)];
        mysys(command);
    end
    
    fiddem  = fopen(lookheightfile,'r');
    tmp     = fread(fiddem,[newnx(l),newny(l)*2],'real*4');
    dem     = tmp(:,2:2:end)';
    fclose(fiddem);
    
    for k=1:nints
        if(exist(ints(k).unwrlk{l},'file'))
            fidi=fopen(ints(k).unwrlk{l},'r');
            fido=fopen([ints(k).unwrlk{l} 'tmp'],'w');
            for j=1:newny(l)
                badi=find(ismember(dem(j,:),hgts));
                tmp=fread(fidi,newnx(l)*2,'real*4');
                tmp(badi)=0;
                tmp(badi+newnx(l))=0;
                fwrite(fido,tmp,'real*4');
            end
            
            fclose(fido);
            fclose(fidi);
            return
            movefile([ints(k).unwrlk{l} 'tmp'],ints(k).unwrlk{l});
        end
    end
end

