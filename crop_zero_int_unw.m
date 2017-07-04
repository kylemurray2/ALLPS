function crop_edges(hgts)
%%%acts on int file
%%% mask = 1x4 vector of left,right, top,bottom to mask, 0 or larger
%for texas dem(and(dem>=48.9,dem<=52.1))=NaN;
set_params
load(ts_paramfile);

rg=[dates.rgoff];
az=[dates.azoff];
masklft=abs(min(rg))+20;
maskrgt=max(rg)+20;
masktop=abs(min(az))+20;
maskbot=10;

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);

if(or(or(or(masklft>nx,maskrgt>nx),masktop>ny),maskbot>ny))
disp('masks must be smaller than size of image')
return
end
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
    
    id1=ceil(masklft/rlooks(l));%x2 for cpx files
    id2=floor((newnx(l)-maskrgt/rlooks(l)));
    id3=ceil(masktop/alooks(l));
    id4=floor(newny(l)-maskbot/alooks(l));
    for k=1:nints
        if(exist(ints(k).unwrlk{l},'file'))
            fidi=fopen(ints(k).unwrlk{l},'r');
            fido=fopen([ints(k).unwrlk{l} 'tmp'],'w');
            for j=1:newny(l)
                badi=find(ismember(dem(j,:),hgts));
                tmp=fread(fidi,newnx(l)*2,'real*4');
                tmp(badi)=0;
                tmp(badi+newnx(l))=0;
                tmp(1:id1)=0;
                tmp(id2:newnx(l))=0;
                tmp([1:id1])=0;
                tmp([id2:newnx(l)]+newnx(l))=0;
                if(and(j>=id3,j<=id4))
                    fwrite(fido,tmp,'real*4');
                else
                    fwrite(fido,zeros(1,newnx(l)*2),'real*4');
                end
            end
       
            fclose(fido);
            fclose(fidi);
     
                  movefile([ints(k).unwrlk{l} 'tmp'],ints(k).unwrlk{l});
        end
    end
end

