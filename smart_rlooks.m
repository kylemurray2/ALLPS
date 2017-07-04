set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);

if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
    [nx,ny]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
end

fid1=fopen(gammafile,'r');
im=sqrt(-1);
thresh=2;

newnx=floor(nx./rlooks)
newny=floor(ny./alooks);

for l=1:length(rlooks)
    for k=2:nints
        if(~exist(ints(k).flatrlk{1},'file'));
            fid2    = fopen(ints(k).flat,'r');
            fid3    = fopen(ints(k).flatrlk{1},'w');
            fid4    = fopen([ints(k).flatrlk{1} '.cor'],'w');
            fid5    = fopen(maskfilerlk{l},'r');
            for j=1:newny(l)
                gamma = NaN(alooks(l),nx);
                int   = zeros(alooks(l),nx);
                mask  = zeros(1,newnx(l));
                
                for i=1:alooks(l)
                    tmp=fread(fid1,nx,'real*4'); 
                    gamma(i,1:length(tmp))=tmp;
            
                    tmp=fread(fid2,nx,'real*4');
                    int(i,1:length(tmp))=exp(im*tmp);
                end
                
                
                gamma(isnan(gamma))=1000;
                
                %read old mask file (downlooked)
                tmp  = fread(fid5,newnx(l),'real*4');
                mask(1:length(tmp))=tmp;
                
                cor = zeros(1,newnx(l));
                for i=1:newnx(l)
                    ids    = (i-1)*rlooks(l)+[1:rlooks(l)];
                    tempi  = int(:,ids);
                    phs    = angle(tempi);
                    
                    tempm  = gamma(:,ids);
                    tempm  = 1./tempm;
                    tempm(isnan(tempm))=0;
                    
                    
                    goodid = find((phs~=0) & (isfinite(phs)));
                    if(length(goodid)>1)
                        cor(i) = abs(sum(tempi(goodid)))/length(goodid);
                        meani  = mean(tempi(goodid).*tempm(goodid));
                        fwrite(fid3,[real(meani) imag(meani)],'real*4');
                        fwrite(fid4,cor(i),'real*4');
                    else
                        cor(i) = 0;
                        fwrite(fid3,[0 0],'real*4');
                        fwrite(fid4,[0],'real*4');
                    end
                end
                cor(cor<.75)=0;
                fwrite(fid4,max(cor,mask),'real*4');
            end
            fclose(fid2);
            fclose(fid3);
            fclose(fid4);
            fclose(fid5);
            frewind(fid1);
        else
            disp(['skipping ' ints(k).name]);
        end
    end
end
fclose(fid1);

