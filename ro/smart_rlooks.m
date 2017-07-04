set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

fid1=fopen(gammafile,'r');
im=sqrt(-1);
thresh=2;

newnx=floor(nx./rlooks)
newny=floor(ny./alooks);

for l=1:length(rlooks)
    for k=1:nints
        if(~exist(ints(k).flatrlk{l},'file'));
            fid2    = fopen(ints(k).flat,'r');
            fid3    = fopen(ints(k).flatrlk{l},'w');
            
            for j=1:newny(l)
                mask = zeros(alooks(l),nx);
                int  = zeros(alooks(l),nx);
                for i=1:alooks(l)
                    tmp1=fread(fid1,nx,'real*4');
                    if(length(tmp1)==nx)
                        mask(i,:)=tmp1(1:nx);
                    else
                        mask(i,:)=1000;
                    end
                    mask(i,isnan(mask(i,:)))=1000;
                    tmp=fread(fid2,nx,'real*4');
                    if(length(tmp)==nx)
                        int(i,:)=exp(im*tmp);
                    else
                        int(i,:)=zeros(1,nx);
                    end
                end
                
                for i=1:newnx(l)
                    ids=(i-1)*rlooks(l)+[1:rlooks(l)];
                    tempi=int(:,ids);
                    tempm=mask(:,ids);
                    tempm=1./tempm;
                    phs=angle(tempi);
                    goodid=find(and(phs~=0,isfinite(phs)));
                    if(length(goodid)>1)
                        meani=mean(tempi(goodid).*tempm(goodid));
                        fwrite(fid3,[real(meani) imag(meani)],'real*4');
                        
                    else
                        fwrite(fid3,[0 0],'real*4');
                    end
                end
            end
            fclose(fid2);
            fclose(fid3);
            frewind(fid1);
        else
            disp(['skipping ' ints(k).name]);
        end
    end
end
fclose(fid1);

