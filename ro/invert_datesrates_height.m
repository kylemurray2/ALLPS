set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
bp=[ints.bp];
dt=[ints.dt];

[G,Gg,R,N]=build_Gint;
G=G(1:end-1,:);
[n,m]=size(G); 
%n is number of constraints -> #ints + #unconstrained intervals 
%m is number of intervals -> #dates-1
lamb=0.1;

G2=[G bp'/max(bp) dt'/max(dt)];
G3=[G2; ones(1,ndates)/ndates 0 0;lamb*eye(ndates) zeros(ndates,2)];
close;
Gg2=inv(G3'*G3)*G2';

newnx=floor(nx./rlooks)
newny=floor(ny./alooks);

%for l=1:1
for l=1:length(rlooks)
    for i=1:nints
        fidi(i)=fopen(ints(i).unwrlk{l},'r');
    end
    for i=1:ndates
        fido(i)=fopen([dates(i).unwrlk{l} '_new'],'w');
    end
    fido2=fopen(['rnew_' num2str(rlooks(l))],'w');
    fido3=fopen(['heightnew_' num2str(rlooks(l))],'w');
    fido4=fopen(['ratenew_' num2str(rlooks(l))],'w');
    for j=1:newny(l)
        tmpdat=zeros(n,newnx(l)); %data for n-nints = zeros
        for i=1:nints
            jnk         = fread(fidi(i),newnx(l),'real*4');
            jnk         = fread(fidi(i),newnx(l),'real*4');
            tmpdat(i,1:length(jnk))=jnk;
        end
        %height = Gg2*tmpdat(1:nints,:);
        %synth  = G2*height;
        %tmpdat = tmpdat-[synth;zeros((n-nints),newnx(l))];

        mod    = Gg2*tmpdat;
        synth  = G2*mod;
        res    = tmpdat-synth;
        resstd = std(res,1);
        fwrite(fido2,resstd,'real*4');
        for i=1:ndates
            fwrite(fido(i),mod(i,:),'real*4');
        end
        fwrite(fido3,mod(ndates+1,:),'real*4');
        fwrite(fido4,mod(ndates+2,:),'real*4');
    end
    fclose('all');
end
