function filter_diff(infile,filtfile,difffile,nx,ny,rx,ry)

    buffer = 2000; %lines
    nbuf   = 1+ceil((ny-(buffer+ry))/buffer);
    
    fid1   = fopen(infile,'r');
    fid3   = fopen(filtfile,'w');
    fid4   = fopen(difffile,'w');
    im     = sqrt(-1);
 
    rea_buff  = zeros(buffer+ry*2,nx);
    ima_buff  = zeros(buffer+ry*2,nx);
    
%h=fspecial('gaussian',[ry rx],1);
    tot=0;
    for l=1:nbuf
%      for l=1:4   
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
        clear int_in
       
        disp('Processing');

         rfilt=imgaussfilt(rea_buff,[ry rx]);
         ifilt=imgaussfilt(ima_buff,[ry rx]);

         cpx0    = rea_buff+im*ima_buff;
         cpxf    = rfilt   +im*ifilt;
         cpx0    = cpx0./abs(cpx0);
         cpxf    = cpxf./abs(cpxf);
         phsdiff = cpx0.*conj(cpxf);
         fwrite(fid3,angle(cpxf(ry+1:stopat,:))','real*4');
         fwrite(fid4,angle(phsdiff(ry+1:stopat,:))','real*4'); 
    end
    fclose('all');

end

