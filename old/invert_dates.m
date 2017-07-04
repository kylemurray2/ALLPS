function invert_dates(topoflag)
%0 looks for unwrlk{l}, 1 adds _topo.unw to name.
topoflag=0;
set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);

[G,Gg,R,N]=build_Gint;
[m,n]=size(Gg);

for l=1:length(rlooks)    
    for i=1:nints
        if(topoflag)
            infile=[ints(i).unwrlk{l} '_topo.unw'];
        else
            infile=ints(i).unwrlk{l};
        end
        if(~exist(infile))
            disp([infile ' does not exist'])
            return
        end
        fidi(i)=fopen(infile,'r');
    end
    for i=1:ndates
        fido(i)=fopen(dates(i).unwrlk{l},'w');
    end
    fido2=fopen(['res_' num2str(rlooks(l))],'w');

    for j=1:newny(l)
        tmpdat=zeros(n,newnx(l)); %data for n-nints = zeros
        
        
        for i=1:nints
            jnk         = fread(fidi(i),newnx(l),'real*4');
            tmpdat(i,1:length(jnk))=jnk;
        end
       
        mod    = Gg*tmpdat;
        synth  = G*mod;
        res    = tmpdat-synth; 
        resstd = std(res,1);
        fwrite(fido2,resstd,'real*4');
        for i=1:ndates
            fwrite(fido(i),mod(i,:),'real*4');
        end
    end
    fclose('all');
end
