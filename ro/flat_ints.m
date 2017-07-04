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
        %fidint = fopen(ints(i).int,'r'); %need to also remove this
        %definition from proc file
        
        fid1   = fopen(dates(ints(i).i1).rectslc,'r');
        fid2   = fopen(dates(ints(i).i2).rectslc,'r');
        fidr1  = fopen([intdir 'ramp_' dates(ints(i).i1).name '.unw'],'r');
        fidr2  = fopen([intdir 'ramp_' dates(ints(i).i2).name '.unw'],'r');
        fido   = fopen(ints(i).flat,'w');
        
        for j=1:ny
            %read slcs
            tmp  = fread(fid1,nx*2,'real*4');
            slc1 = complex(tmp(1:2:end),tmp(2:2:end));
            tmp  = fread(fid2,nx*2,'real*4');
            slc2 = complex(tmp(1:2:end),tmp(2:2:end));
            int  = slc1.*conj(slc2);
            mint = abs(int)==0; %true where amplitude=0
            
            if(fidr1>0)
                tmp = fread(fidr1,nx*2,'real*4');
                a1  = tmp(1:nx);
                r1  = tmp(nx+[1:nx]);
                mr1 = a1==0; %mask out areas where ramp 1 is 0
            else %no ramp file (i.e., is master date)
                r1  = zeros(nx,1);
                mr1 = false(size(r1));
            end
            if(fidr2>0)
                tmp = fread(fidr2,nx*2,'real*4');
                a2  = tmp(1:nx); 
                r2  = tmp(nx+[1:nx]);
                mr2 = a2==0;
            else %no ramp file (i.e., is master date)
                r2  = zeros(nx,1);
                mr2 = false(size(r2));
            end
            mask   = (mint | mr1 | mr2); %should be true where masked
   
            dr     = r2-r1;
            dr     = exp(im*dr);
            newint = int.*conj(dr);
           
            newint = angle(newint);
            newint(mask)=0;
            
            fwrite(fido,newint,'real*4');
        end
        fclose('all');
    
    else
        disp([ints(i).flat ' already made']);
    end
end


