
set_params
load(ts_paramfile);
ndates=length(dates);
nints=length(ints)

[nx,ny]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx=nx./rlooks;
newny=ny./alooks;
unwres=zeros(nints,newnx(1),newny(1));
for l=1
    for i=1:nints
        fid1=fopen(ints(i).unwrlk{l},'r');
        fid2=fopen([ints(i).unwrlk{l} '_rot'],'r');
        tmp1=fread(fid1,[newnx(l),newny(l)*2],'real*4');
        tmp2=fread(fid2,[newnx(l),newny(l)*2],'real*4');
        fclose(fid1);
        fclose(fid2);
        tmp1=tmp1(:,2:2:end);
        tmp2=tmp2(:,2:2:end);
        res=tmp1-tmp2;
        resstd(i)=std(res(isfinite(res)));
        unwres(i,:,:)=res;
    end
end