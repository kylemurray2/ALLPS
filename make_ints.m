set_params
load(ts_paramfile);
ndates=length(dates);
nints=length(ints);

[nx,ny]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

for i=1% %now only need to make one?  Perhaps not that in future
    if(~exist([ints(i).int '.rsc'],'file'))
        disp(['making ' ints(i).int])
        fid1=fopen(dates(ints(i).i1).rectslc,'r');
        fid2=fopen(dates(ints(i).i2).rectslc,'r');
        fidout=fopen(ints(i).int,'w');
        for j=1:ny
            tmp=fread(fid1,nx*2,'real*4');
            slc1=complex(tmp(1:2:end),tmp(2:2:end));
            tmp=fread(fid2,nx*2,'real*4');
            slc2=complex(tmp(1:2:end),tmp(2:2:end));
            int=slc1.*conj(slc2);
            tmp(1:2:end)=real(int);
            tmp(2:2:end)=imag(int);
            fwrite(fidout,tmp,'real*4');
        end
        fclose(fidout);
        fclose(fid1);
        fclose(fid2);
    end
    copyfile([dates(ints(i).i1).rectslc '.rsc'],[ints(i).int '.rsc']);
end

