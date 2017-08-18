function make_mask(thresh)
%threshold ~.7?
set_params
load(ts_paramfile);

ndates=length(dates);
nints=length(ints);

% if strcmp(sat,'S1A')
%     nx=ints(id).width;
%     ny=ints(id).length;
% else
%     [nx,ny]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
% end

newnx  = floor(nx./rlooks)
newny  = floor(ny./alooks);


fidin  = fopen(gammafile,'r','native');
fidout = fopen(maskfile,'w','native');

for i=1:ny
    tmp=fread(fidin,nx,'real*4');
    out=tmp>thresh;
    fwrite(fidout,out,'integer*1');
end
fclose(fidin);
fclose(fidout);


for l=1:length(rlooks)
    fidin  = fopen(maskfile,'r','native');
    fidout = fopen(maskfilerlk{l},'w');
    for i=1:newny(l)
        tmp=zeros(nx,alooks(l));
        [jnk,count]=fread(fidin,[nx alooks(l)],'integer*1');
        tmp(1:count)=jnk;
        tmp = sum(tmp,2); %sum along alooks dir
        
        tmp = reshape(tmp(1:rlooks(l)*newnx(l)),rlooks(l),newnx(l));
        tmp = sum(tmp,1); %sum along rlooks dir
        
        tmp=tmp/rlooks(l)/alooks(l);
        %tmp(tmp<.25)=0;
        fwrite(fidout,tmp,'real*4');
        
        
    end
    fclose(fidin);
    fclose(fidout);
   system(['mag_phs2rmg ' maskfilerlk{l} ' ' maskfilerlk{l} ' ' rlkdir{l} 'mask.cor ' num2str(newnx(l))]);

end

% fid=fopen('TS/gamma0.r4','r','native');
% mm=fread(fid,[nx,ny],'real*4')';
% figure;imagesc(mm);



