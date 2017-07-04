set_params
load(ts_paramfile);
ndates=length(dates);
buffer=1000;


if strcmp(sat,'S1A')
    [nx,ny]=load_rscs(ints(id).flat,'WIDTH','FILE_LENGTH');
    nbuf=ceil(ny/buffer);
     for i=1:nints
         
        i
        fidin=fopen(ints(i).flat,'r','native');
        med=0;
        totcount=0;

        for j=1:nbuf
            [tmp,count]=fread(fidin,nx*2*buffer,'real*4');
            totcount=totcount+count/2;
            amp=abs(complex(tmp(1:2:count),tmp(2:2:count)));
            med=med+sum(amp);
        end
        fclose(fidin);
        ints(i).ampmed=med/totcount;
    end

    if(exist('ints','var'))
        save(ts_paramfile,'dates','ints');
    else
        save(ts_paramfile,'dates');
    end   
    
else
    [nx,ny]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
    nbuf=ceil(ny/buffer);
    for i=1:ndates
        i
        fidin=fopen(dates(i).rectslc,'r','native');
        med=0;
        totcount=0;

        for j=1:nbuf
            [tmp,count]=fread(fidin,nx*2*buffer,'real*4');
            totcount=totcount+count/2;
            amp=abs(complex(tmp(1:2:count),tmp(2:2:count)));
            med=med+sum(amp);
        end
        fclose(fidin);
        dates(i).ampmed=med/totcount;
    end

    if(exist('ints','var'))
        save(ts_paramfile,'dates','ints');
    else
        save(ts_paramfile,'dates');
    end

end


