function crop_zero_unw
%replaces all points in unw with 0 if amp=0.
set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);
magfile=[TSdir 'avgslc_4rlks.r4'];

if(exist(magfile,'file'))
    switchmag=1;
    disp('replacing mag, too');
else
    switchmag=0;
end

for l=1:length(rlooks)
    
    for k=1:nints
        if(exist(ints(k).unwrlk{l},'file'))
            fidi=fopen(ints(k).unwrlk{l},'r');
            fidi2=fopen(ints(k).flatrlk{l},'r');
            fido=fopen([ints(k).unwrlk{l} 'tmp'],'w');
            if(switchmag)
                fidmag=fopen(magfile,'r');
            end
            for j=1:newny(l)
                tmp=fread(fidi,newnx(l)*2,'real*4');
                tmp2=fread(fidi2,newnx(l)*2,'real*4');
                badi=find(tmp2(1:2:newnx(l)*2)==0);
      
                
                tmp(badi+newnx(l))=0;

                if(switchmag)
                    tmp2=fread(fidmag,newnx(l),'real*4');
                    tmp2(badi)=0;
                    fwrite(fido,tmp2,'real*4');
                    fwrite(fido,tmp([1:newnx(l)]+newnx(l)),'real*4');
                else
                    fwrite(fido,tmp,'real*4');
                end
                
            end
            fclose(fidmag);
            fclose(fido);
            fclose(fidi);
            fclose(fidi2);
         
            movefile([ints(k).unwrlk{l} 'tmp'],ints(k).unwrlk{l});
        end
    end
end

