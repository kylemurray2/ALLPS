set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);

G2=[ints.bp]';



for l=1:length(rlooks)
    for i=1:nints
        fidi(i)=fopen(ints(i).unwrlk{l},'r');
        fidoi(i)=fopen([ints(i).unwrlk{l} '_fixheight'],'w');
    end
    
    fidi2=fopen('height_4','r');
    
    for j=1:newny(l)
        %for j=1:770
        tmpdat=zeros(nints,newnx(l)); %data for n-nints = zeros
        for i=1:nints
            %jnk         = fread(fidi(i),newnx(l),'real*4');
            jnk         = fread(fidi(i),newnx(l),'real*4');
            tmpdat(i,1:length(jnk))=jnk;
        end
        height=fread(fidi2,newnx(l),'real*4');
        
        synth  = G2*height';
        for i=1:nints
            fwrite(fidoi(i),tmpdat(i,:)-synth(i,:),'real*4');
        end
     end
    fclose('all');
end
