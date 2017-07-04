function crop_edges(hgts)
%%%acts on int file
%%% mask = 1x4 vector of left,right, top,bottom to mask, 0 or larger
%for texas dem(and(dem>=48.9,dem<=52.1))=NaN;
set_params
load(ts_paramfile);

rg=[dates.rgoff];
az=[dates.azoff];
masklft=abs(min(rg));
maskrgt=max(rg);
masktop=abs(min(az));
maskbot=0;

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
    %for texas
    mask=false(newny(l),newnx(l));
    
    badid   = and(dem>=48.9,dem<=52.1);
    regions = bwlabel(badid);
    info    = regionprops(regions,'Area');
    areas   = [info.Area];
    badid   = find(areas>1e3);
    %    badid   = find(areas>1e5); %already messed this up this round
    mask(ismember(regions,badid))=1;
    
    if(length(hgts)>0) %80 103 for  big reservoirs in texas.
        badid=ismember(dem,hgts);
        regions = bwlabel(badid);
        info    = regionprops(regions,'Area');
        areas   = [info.Area];
        badid   = find(areas>1e3);
        mask(ismember(regions,badid))=1;
    end
        id1=ceil(masklft/rlooks(l));%x2 for cpx files
    id2=floor((newnx(l)-maskrgt/rlooks(l)));
    id3=ceil(masktop/alooks(l));
    id4=floor(newny(l)-maskbot/alooks(l));

    mask(1:id3,:)=1;
    mask(id4:end,:)=1;
    mask(:,1:id1)=1;
    mask(:,id2:end)=1;
    
    fiddem=fopen('watermask','w');
    fwrite(fiddem,~mask','real*4');
    fclose(fiddem);

    

    for k=1:nints
        if(exist(ints(k).unwrlk{l},'file'))
            fidi=fopen(ints(k).unwrlk{l},'r');
            fido=fopen([ints(k).unwrlk{l} 'tmp'],'w');
            for j=1:newny(l)
           
                tmp=fread(fidi,newnx(l),'real*4');
                tmp(mask(j,:))=0;
      
                tmp(1:id1)=0;
                tmp(id2:end)=0;
                if(and(j>=id3,j<=id4))
                    fwrite(fido,tmp,'real*4');
                else
                    fwrite(fido,zeros(1,newnx(l)),'real*4');
                end
            end
       
            fclose(fido);
            fclose(fidi);
                  movefile([ints(k).unwrlk{l} 'tmp'],ints(k).unwrlk{l});
        end
    end
end

