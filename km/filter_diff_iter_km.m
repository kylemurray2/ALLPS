function filter_diff_iter_km(infile,filtfile,difffile,nx,ny,rx,ry,gammafile,gammathresh)
if(~exist(difffile,'file'))
    buffer = 2000; %lines
    nbuf   = 1+ceil((ny-(buffer+ry))/buffer);
    
    fid1   = fopen(infile,'r');
    fid3   = fopen(filtfile,'w');
    fid4   = fopen(difffile,'w');
        fid5   = fopen(gammafile,'r');

    im     = sqrt(-1);
    
    z         = zeros(1,nx);
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

%         disp(['buffer ' num2str(l) ' ' num2str(stopat) ' ' num2str(tot)])
        a           = zeros(nx,rbuff);
        [tmp,count] = fread(fid1,[nx,rbuff],'real*4');
        a(1:count)  = tmp;
    
        clear tmp
        rea_buff=[rea_buff(keep:end,:);cos(a')];
        ima_buff=[ima_buff(keep:end,:);sin(a')];
        clear a
  
        a           = zeros(nx,rbuff);
        [tmp,count] = fread(fid5,[nx,rbuff],'real*4');
        a(1:count)  = tmp;
        a           = a<gammathresh;
        gam_buff    = [gam_buff(keep:end,:);a'];
%         disp('Processing');
        bad      = ~gam_buff;
        rea_buff(bad) = 0;
        ima_buff(bad) = 0;

         rfilt=imgaussfilt(rea_buff,[ry rx]);
         ifilt=imgaussfilt(ima_buff,[ry rx]);

         cpx0    = rea_buff+im*ima_buff;
        cpxf    = rfilt   +im*ifilt;
        cpx0    = cpx0./abs(cpx0);
        cpxf    = cpxf./abs(cpxf);
        phsdiff = cpx0.*conj(cpxf);
%        fwrite(fid3,rea_buff(ry+1:stopat,:)','real*4');
%        fwrite(fid4,rfilt(ry+1:stopat,:)','real*4');
         fwrite(fid3,angle(cpxf(ry+1:stopat,:))','real*4');
         fwrite(fid4,angle(phsdiff(ry+1:stopat,:))','real*4'); %need to fix so that doesn't run over ny
    end
    fclose('all');

end

    disp(['filtering ' infile ' already done']);
end