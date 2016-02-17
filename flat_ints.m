set_params
load(ts_paramfile);
ndates=length(dates);
nints=length(ints);
[nx,ny]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
%buffer=1000;
%nbuff=ceil(ny/buffer);
im=sqrt(-1);

for i=1:nints
    if(~exist(ints(i).flat,'file'))
        disp(['making ' ints(i).flat]);
        fidint = fopen(ints(i).int,'r');
        fidr1  = fopen([intdir 'ramp_' dates(ints(i).i1).name '.unw'],'r');
        fidr2  = fopen([intdir 'ramp_' dates(ints(i).i2).name '.unw'],'r');
        fido   = fopen(ints(i).flat,'w');
        for j=1:ny
            tmp=fread(fidint,nx*2,'real*4');
            phs=atan2(tmp(2:2:end),tmp(1:2:end));
            
            if(fidr1>0)
               tmp = fread(fidr1,nx*2,'real*4');
               r1  = tmp(nx+[1:nx]);
            else
	       %disp(['no ramp for ' dates(ints(i).i1).name])
		 r1=zeros(nx,1);
            end
            if(fidr2>0)
               tmp = fread(fidr2,nx*2,'real*4');
               r2  = tmp(nx+[1:nx]);
            else
	       %disp(['no ramp for ' dates(ints(i).i2).name])   
		 r2=zeros(nx,1);
            end
            phs = exp(im*phs);
            dr=r2-r1;
            dr=exp(im*dr);
            newint=phs.*conj(dr);
           
            newint=angle(newint);

            fwrite(fido,newint,'real*4');
        end
        fclose('all');
    else
        disp([ints(i).flat ' already made']);
    end
end


