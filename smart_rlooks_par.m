function smart_rlooks_par(k,newnx,newny,win,rangevec,intcorthresh,l,fid1)
getstuff
        %if(~exist(ints(k).flatrlk{l},'file'));
        if(1)
        fid2    = fopen(ints(k).flat,'r');
        fid3    = fopen('phs','w');
        fid4    = fopen('cor','w');
        fid5    = fopen([ints(k).flat '_diff'],'r');
        for j=1:newny(l)
            mask = zeros(alooks(l),nx);
            int  = zeros(alooks(l),nx);
		intcor=zeros(alooks(l),nx);
            for i=1:alooks(l)
                tmp_gamma=fread(fid1,nx,'real*4');
                if(length(tmp_gamma)==nx)
                    mask(i,:)=tmp_gamma(1:nx);
                else
                    mask(i,:)=0;
                end
                mask(i,isnan(mask(i,:)))=0;
                tmp_int=fread(fid2,nx,'real*4');
                if(length(tmp_int)==nx)
                    int(i,:)=exp(im*tmp_int);
                else
                    int(i,:)=zeros(1,nx);
                end
		tmp_int_diff=fread(fid5,nx,'real*4');
		if(length(tmp_int_diff)==nx)
		  intcor(i,:)=cos(tmp_int_diff);
		else
		  intcor(i,:)=0;
		end
    end
		goodcorid=and(intcor>mask,intcor>intcorthresh);
		mask(goodcorid)=intcor(goodcorid); %this will add any good values specific to the individual int to the mask(gamma) file
                  
            rea=real(int);
            ima=imag(int);
            
            rea_filt0  = conv2(rea,win,'valid');
            ima_filt0  = conv2(ima,win,'valid');
            
            rea=rea.*mask; %multiplies by the value from 0 to 1 in the mask
            ima=ima.*mask;
            
            rea_filt  = conv2(rea,win,'valid');
            ima_filt  = conv2(ima,win,'valid');
            %mag_filt  = conv2(mask,win,'valid');
            
            phs    = atan2(ima_filt(rangevec),rea_filt(rangevec));
            phscor = sqrt(ima_filt0(rangevec).^2+rea_filt0(rangevec).^2); %abs value of average phase vector.
            %phssig=sqrt(-2*log(phscor));
            
            fwrite(fid3,phs,'real*4');
            fwrite(fid4,phscor,'real*4');
        end
             
        fclose(fid2);
        fclose(fid3);
        system(['mag_phs2cpx ' maskfilerlk{l} ' phs ' ints(k).flatrlk{l} ' ' num2str(newnx(l))]);
        system(['mag_phs2rmg cor cor ' ints(k).flatrlk{l} '_cor ' num2str(newnx(l))]);
        end