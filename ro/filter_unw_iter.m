function filter_unw_iter(infile,nx,ny,rx,ry,maskfile)
%set_params
%load(ts_paramfile)
if(1)
buffer = 1000; %lines
    nbuf   = 1+ceil((ny-(buffer+ry))/buffer);
    
    fid1   = fopen(infile,'r');
    fid3   = fopen([infile '_filtdiff.unw'],'w');
    fid5   = fopen(maskfile,'r');
    im     = sqrt(-1);
    
    gam_buff  = zeros(buffer+ry*2,nx);
    phs_buff  = zeros(buffer+ry*2,nx);
amp_buff  = zeros(buffer+ry*2,nx);
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
b=a;
        [tmp,count] = fread(fid1,[nx*2,rbuff],'real*4');
        a(1:count/2)  = tmp(nx+1:end,:);
b(1:count/2)=tmp(1:nx,:);

        clear tmp
        phs_buff    = [phs_buff(keep:end,:);a'];
amp_buff=[amp_buff(keep:end,:);b'];

        a           = zeros(nx,rbuff);
        [tmp,count] = fread(fid5,[nx,rbuff],'real*4');
        a(1:count)  = tmp;
        a           = a==1;
        gam_buff    = [gam_buff(keep:end,:);a'];
        
        disp('Processing');
        bad      = ~gam_buff;
pmask=phs_buff;        
pmask(bad) = 0;
      
    pfilt    = imfilter(pmask,gaus,'same');
        mfilt    = imfilter(gam_buff,gaus,'same');
        
        pfilt   = pfilt./mfilt;
        pfilt(phs_buff==0)=0;
pfilt(isnan(pfilt))=phs_buff(isnan(pfilt));
         phsdiff = phs_buff-pfilt;
        for m=ry+1:stopat
        fwrite(fid3,amp_buff(m,:)','real*4');
        fwrite(fid3,phsdiff(m,:)','real*4');  
end

 end
%return
 fclose('all');

else
    disp(['filtering ' infile ' already done']);
end

