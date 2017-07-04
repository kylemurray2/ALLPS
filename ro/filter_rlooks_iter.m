function filter_rlooks_iter(infile,filtfile,difffile,nx,ny,rx,ry,maskfile)
%if(~exist(difffile,'file'))
if(1)
buffer = 1000; %lines
    nbuf   = 1+ceil((ny-(buffer+ry))/buffer);
    
    fid1   = fopen(infile,'r');
    fid3   = fopen(filtfile,'w');
    fid4   = fopen(difffile,'w');
    fid5   = fopen(maskfile,'r');
    im     = sqrt(-1);
    
    gam_buff  = zeros(buffer+ry*2,nx);
    phs_buff  = zeros(buffer+ry*2,nx);
    
    gausx = exp(-[-rx:rx].^2/rx^2);
    gausy = exp(-(-ry:ry).^2/ry^2);
    gaus  = gausy'*gausx;
    gaus = gaus-min(gaus(:));
    gaus  = gaus/sum(gaus(:));
    
    tot=0;
    for l=1:nbuf
        disp(['reading in buffer ' num2str(l) '/' num2str(nbuf)]);
        rbuff   = buffer;
        keep    = buffer+1;
        stopat  = buffer+ry;
        tot     = tot+buffer;
        if(l==1)
            rbuff  = buffer+ry;
            keep   = buffer+ry+1;
        elseif(tot>ny)
            stopat =rem(ny,buffer)+ry;
        end
        
        %disp(['rbuf ' num2str(rbuff) ' keep ' num2str(keep) ' stopat ' num2str(stopat) ' ' num2str(tot)])
        a           = zeros(nx,rbuff);
        [tmp,count] = fread(fid1,[nx*2,rbuff],'real*4');
        a(1:count/2)  = angle(tmp(1:2:end,:)+im*tmp(2:2:end,:));
        
        clear tmp
        phs_buff    = [phs_buff(keep:end,:);a'];
        rea         = cos(phs_buff);
        ima         = sin(phs_buff);
        
        a           = zeros(nx,rbuff);
        [tmp,count] = fread(fid5,[nx,rbuff],'real*4');
        a(1:count)  = tmp;
        a           = a==1;
        gam_buff    = [gam_buff(keep:end,:);a'];
        
        disp('Processing');
        bad      = ~gam_buff;
        rea(bad) = 0;
        ima(bad) = 0;
        
        rfilt    = imfilter(rea,gaus,'same');
        ifilt    = imfilter(ima,gaus,'same');
        mfilt    = imfilter(gam_buff,gaus,'same');
        
        rfilt   = rfilt./mfilt;
        ifilt   = ifilt./mfilt;
        
        cpxf    = rfilt+im*ifilt;
        cpxf    = cpxf./abs(cpxf);
        phsdiff = exp(im*phs_buff).*conj(cpxf);
        
        fwrite(fid3,angle(cpxf(ry+1:stopat,:))','real*4');
        fwrite(fid4,angle(phsdiff(ry+1:stopat,:))','real*4'); %need to fix so that doesn't run over ny
    end
    fclose('all');

else
    disp(['filtering ' infile ' already done']);
end

