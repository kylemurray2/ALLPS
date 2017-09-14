function par_ps_interp(ii,msk,gamma,alpha,rx,ry)
set_params
load(ts_paramfile)
im     = sqrt(-1);


display(['filtering ' ints(ii).name])
    %load int phase and correlation
    intfile=[ints(ii).flatrlk];
    fid=fopen(intfile,'r','native');
    [phs1,count] = fread(fid,[newnx,newny],'real*4');
    fclose(fid);
    
    corfile=[ints(ii).flatrlk '.cor'];
    fid=fopen(corfile,'r','native');
    [cor,count] = fread(fid,[newnx,newny],'real*4');
    fclose(fid);
    
    
    %mask int to leave PS
    mask = msk<gamma & cor<alpha;     %high values are good

    %PLOT masks for the first one
    if ii==1
    figure;imagesc(msk);colorbar
    figure;imagesc(cor);colorbar
    figure;imagesc(mask);colorbar
    end
    
    
    rea = real(exp(im*phs1));
    ima = imag(exp(im*phs1));
    rea(mask)=0;
    ima(mask)=0;
    
    %
    % % Do the interpolation
    %
         
            rx2=floor(rx*3);
            ry2=floor(ry*3);
            gausx = exp(-[-rx2:rx2].^2/rx^2);
            gausy = exp(-(-ry2:ry2).^2/ry^2);
            gaus  = gausy'*gausx;
            gaus = gaus-min(gaus(:));
            gaus  = gaus/sum(gaus(:));
%             rea_f=zeros(size(mask));
%             ima_f=zeros(size(mask));
            
            msk_f=conv2(double(~mask),gaus,'same');
            rea_f=conv2(rea,gaus,'same');
            ima_f=conv2(ima,gaus,'same');
            
            rea_f=rea_f./msk_f;
            ima_f=ima_f./msk_f;
            real_final=rea_f+rea;
            imag_final=ima_f+ima;
            
            phs = angle(real_final+im*imag_final);
            phs(isnan(phs))=0;
            
            display([num2str(100-(100*(sum(mask(:))/(newnx*newny)))) '% of points left after masking'])
%             fid=fopen('phs','w');
%             fwrite(fid,flipud(phs)','real*4');
%             fclose(fid);
%             system(['mag_phs2cpx ' maskfilerlk{1} ' phs ' ints(ii).flatrlk{1} '_bell ' num2str(newnx)]);
            fid=fopen([ints(ii).flatrlk '_bell'],'w');
            fwrite(fid,phs,'real*4');

    
            