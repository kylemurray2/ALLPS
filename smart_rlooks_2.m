set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

im=sqrt(-1);


newnx=floor(nx./rlooks)
newny=floor(ny./alooks);


win=ones(alooks,rlooks);
win=win/sum(win(:));
rangevec=[0:newnx-1]*rlooks+1;

fid1    = fopen(gammafile,'r');
gam=fread(fid1,nx,'real*4');
fclose(fid1);

for l=1:length(rlooks)
    parfor k=1%:nints
        if(~exist(ints(k).flatrlk{l},'file'));
            fid2    = fopen(ints(k).flat,'r');
            fid3    = fopen(ints(k).flatrlk{l},'w');
            fid4    = fopen([ints(k).flatrlk{l} '.cor'],'w');
            for j=1:newny(l)
                mask = zeros(alooks(l),nx);
                int  = zeros(alooks(l),nx);
                for i=1:alooks(l)
                    if(length(gam)==nx)
                        mask(i,:)=gam(1:nx);
                    else
                        mask(i,:)=0;
                    end
                    mask(i,isnan(mask(i,:)))=0;
                    tmp=fread(fid2,nx,'real*4');
                    if(length(tmp)==nx)
                        int(i,:)=exp(im*tmp);
                    else
                        int(i,:)=zeros(1,nx);
                    end
                end
                
                rea=real(int);
                ima=imag(int);
                
                rea_filt0  = conv2(rea,win,'valid');
                ima_filt0  = conv2(ima,win,'valid');     
                
                rea=rea.*mask;
                ima=ima.*mask;
                
                rea_filt  = conv2(rea,win,'valid');
                ima_filt  = conv2(ima,win,'valid');
                mag_filt  = conv2(mask,win,'valid');              
                
                phs    = atan2(ima_filt(rangevec),rea_filt(rangevec));
                phscor = sqrt(ima_filt0(rangevec).^2+rea_filt0(rangevec).^2); %abs value of average phase vector.
                %phssig=sqrt(-2*log(phscor));
                
                fwrite(fid3,phs,'real*4');
                fwrite(fid4,phscor,'real*4');
            end            

            fclose(fid2);
            fclose(fid3);
            fclose(fid4);
        else
            disp([ints(k).flatrlk{l} ' already done']);
        end
        
    end
    
end
