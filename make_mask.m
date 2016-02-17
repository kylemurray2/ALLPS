set_params
load(ts_paramfile);

ndates=length(dates);
nints=length(ints);
[nx,ny]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

newnx  = floor(nx./rlooks)
newny  = floor(ny./alooks);
thresh = 3;


fidin  = fopen(gammafile,'r','native');
fidout = fopen(maskfile,'w','native');

for i=1:ny
    tmp=fread(fidin,nx,'real*4');
    out=tmp<thresh;
    fwrite(fidout,out,'integer*1');
end
fclose(fidin);
fclose(fidout);


for l=1:length(rlooks)
    fidin  = fopen(maskfile,'r','native');
    fidout = fopen(maskfilerlk{l},'w');
    
    for i=1:newny(l)
        tmp=zeros(alooks(l),nx);
        for j=1:alooks(l)
            [jnk,count]=fread(fidin,nx,'integer*1');
            if(count==nx)
                tmp(j,:)=jnk;
            end
        end
        tmp2=sum(tmp,1);
        tmp=zeros(1,newnx(l));
        for j=1:rlooks(l)
            tmp3=tmp2(j:rlooks(l):nx);
            tmp=tmp+tmp3(1:newnx(l));
        end
        tmp=tmp/rlooks(l)/alooks(l);
        fwrite(fidout,tmp,'real*4');
        
        
    end
    fclose(fidin);
    fclose(fidout);
end
