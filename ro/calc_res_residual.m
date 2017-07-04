set_params
load(ts_paramfile);

ndates         = length(dates);
nints          = length(ints);
[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

newnx = floor(nx./rlooks)
newny = floor(ny./alooks);

for l=1:length(rlooks)
    for i=1:nints
        fid   = fopen([ints(i).unwrlk{l} '_res'],'r');
        tmp=fread(fid,[newnx(l),newny(l)],'real*4');
        fclose(fid);
        meanrms(i)=median(tmp(tmp~=0));
        resrms(i)=std(tmp(tmp~=0));
        
        
        ints(i).resrms=resrms(i);
    end
end

resrms = [ints.resrms];
badid  = find(resrms==max(resrms))
disp(['worst interferogram is ' num2str(badid)]);

save(ts_paramfile,'dates','ints');
fclose('all')

plotflag=1;
if(plotflag)
    
i1=[ints.i1];
i2=[ints.i2];
figure
subplot(1,2,1)
    minres=min(resrms);
    maxres=max(resrms);
    dres=maxres-minres
    
 
    c=colormap;
    dnpair=[dates(i1).dn;dates(i2).dn];
    bppair=[dates(i1).bp;dates(i2).bp];
    
    plot([dates.dn],[dates.bp],'k.')
    hold on
    for i=1:nints
        deltad=floor((resrms(i)-minres)/dres*63)+1;
        plot(dnpair(:,i),bppair(:,i),'-','Color',c(deltad,:),'linewidth',3)
        
    end
    text([dates.dn],[dates.bp],num2str([1:ndates]'))
    grid on
    datetick
title('std dev')

    subplot(1,2,2)
    minres=min(meanrms);
    maxres=max(meanrms);
    dres=maxres-minres
    
 
    c=colormap;
    dnpair=[dates(i1).dn;dates(i2).dn];
    bppair=[dates(i1).bp;dates(i2).bp];
    
    plot([dates.dn],[dates.bp],'k.')
    hold on
    for i=1:nints
        deltad=floor((meanrms(i)-minres)/dres*63)+1;
        plot(dnpair(:,i),bppair(:,i),'-','Color',c(deltad,:),'linewidth',3)
        
    end
    text([dates.dn],[dates.bp],num2str([1:ndates]'))
    grid on
    datetick
    title('mean value')
end