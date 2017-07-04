set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');


[G,Gg,R,N]=build_Gint;
[n,m]=size(G); 
%n is number of constraints -> #ints + #unconstrained intervals 
%m is number of intervals -> #dates-1

G2=[ints.bp]';
Gg2 = inv(G2'*G2)*G2';
close;

newnx=floor(nx./rlooks)
newny=floor(ny./alooks);

%for l=1:1
for l=1:length(rlooks)
    for i=1:nints
        fidi(i)=fopen(ints(i).unwrlk{l},'r');
    end
    for i=1:ndates
        fido(i)=fopen(dates(i).unwrlk{l},'w');
    end
    fido2=fopen(['res_' num2str(rlooks(l))],'w');
    fido3=fopen(['height_' num2str(rlooks(l))],'w');

    for j=1:newny(l)
        tmpdat=zeros(n,newnx(l)); %data for n-nints = zeros
        for i=1:nints
            %jnk         = fread(fidi(i),newnx(l),'real*4');
            jnk         = fread(fidi(i),newnx(l),'real*4');
            tmpdat(i,1:length(jnk))=jnk;
        end
        height = Gg2*tmpdat(1:nints,:);
        synth  = G2*height;
        tmpdat = tmpdat-[synth;zeros((n-nints),newnx(l))];

        mod    = Gg*tmpdat;
        synth  = G*mod;
        res    = tmpdat-synth;
        resstd = std(res,1);
        fwrite(fido2,resstd,'real*4');
        for i=1:ndates
            fwrite(fido(i),mod(i,:),'real*4');
        end
        fwrite(fido3,height,'real*4');

    end
    fclose('all');
end
