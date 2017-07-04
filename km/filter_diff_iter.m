function filter_diff_iter(infile,filtfile,difffile,nx,ny,rx,ry,gammafile,gammathresh)
if(~exist(difffile,'file'))
    buffer = 2000; %lines
    nbuf   = 1+ceil((ny-(buffer+ry))/buffer);
    
    fid1   = fopen(infile,'r');
    fid3   = fopen(filtfile,'w');
    fid4   = fopen(difffile,'w');
    fid5   = fopen(gammafile,'r');
    im     = sqrt(-1);
    
    gam_buff  = zeros(buffer+ry*2,nx);
    rea_buff  = zeros(buffer+ry*2,nx);
    ima_buff  = zeros(buffer+ry*2,nx);
    
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
        
        int_in           = zeros(nx,rbuff);
        [tmp,count] = fread(fid1,[nx,rbuff],'real*4');
        int_in(1:count)  = tmp;
        
        clear tmp
        rea_buff=[rea_buff(keep:end,:);cos(int_in')];
        ima_buff=[ima_buff(keep:end,:);sin(int_in')];
        
        gam_in           = zeros(nx,rbuff);
        [tmp,count]      = fread(fid5,[nx,rbuff],'real*4');
        gam_in(1:count)  = tmp;
        gam_in           = gam_in>gammathresh; %keep high gamma values (high coherence)
        gam_buff         = [gam_buff(keep:end,:);gam_in'];
        
        disp('Processing');
        bad      = ~gam_buff; %bad are all pixels that are higher than threshold variance. make these 0 magnitude complex vectors.
        rea_buff(bad) = 0;
        ima_buff(bad) = 0;
        
        rfilt    = imgaussfilt(rea_buff,[ry rx]);
        ifilt    = imgaussfilt(ima_buff,[ry rx]);
        mfilt    = imgaussfilt(gam_buff,[ry rx]); %filtering gamma image as well
        
        rfilt   = rfilt./mfilt; %high phase variance is penalized
        ifilt   = ifilt./mfilt;
        
         cpx0    = rea_buff+im*ima_buff;   
         cpxf    = rfilt   +im*ifilt;      
%          cpx0    = cpx0./abs(cpx0);       %this makes the complex vector a unit vector?
%          cpxf    = cpxf./abs(cpxf);       
         phsdiff = cpx0.*conj(cpxf);       
         fwrite(fid3,angle(cpxf(ry+1:stopat,:))','real*4');
         fwrite(fid4,angle(phsdiff(ry+1:stopat,:))','real*4');
    end
    fclose('all');

else
    disp(['filtering ' infile ' already done']);
end

