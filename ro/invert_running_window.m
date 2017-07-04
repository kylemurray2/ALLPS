set_params
load(ts_paramfile);

bp=[ints.bp];
dt=[ints.dt];

G3=[bp' dt'];
G3g=inv(G3'*G3)*G3';

win=50;
window=win*2+1;
[X,Y]=meshgrid(1:window,1:window);
ind=sub2ind(size(X),win+1,win+1);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks);
newny   = floor(ny./alooks);

hs=zeros(newny,newnx);
rs=zeros(newny,newnx);

l=1;
for k=1:nints
    fidi(k)=fopen(ints(k).unwrlk{l},'r');
    tmp=fread(fidi(k),[newnx,(window-1)*2],'real*4');
    allints(k,:,:)=tmp(:,2:2:end)';
end
allramp=zeros(nints,newny,newnx);
for k=1:newny-window
    for j=1:nints
        tmp=fread(fidi(j),[newnx,2],'real*4');
        allints(j,window,:)=tmp(2:2:end);
    end
    
    for j=win+1:newnx-win
        ids=j+[-win:win];
        ints=allints(:,:,ids);
        int2=reshape(ints,nints,window*window);
        mod=G3g*int2;
        synth=G3*mod;
        res=int2-synth;
        resn=sum(res.^2,1);
        id=find(resn<(median(resn)+std(resn)));
        Gr=[ones(size(id')) X(id') Y(id')];
        Ggr=inv(Gr'*Gr)*Gr';
        modr=Ggr*int2(:,id)';
        for m=1:nints
            synth=modr(1,m)+X*modr(2,m)+Y*modr(3,m);
            int2(m,:)=int2(m,:)-synth(:)';
        end
        mod=G3g*int2;
        hs(k,j)=mod(1,ind);
        rs(k,j)=mod(2,ind);
        allramp(:,k,j)=modr(1,:);
    end
    allints(:,1:end-1,:)=allints(:,2:end,:);
    save bigstuff
end
for k=1:nints
    fclose(fidi(k));
end
