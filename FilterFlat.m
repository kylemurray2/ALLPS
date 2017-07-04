set_params
load(ts_paramfile);

ndates   = length(dates);
nints    = length(ints);
[nx,ny]  = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

im           = sqrt(-1);
rx           = 5; %should perhaps be set in set_params instead
ry           = rx*pixel_ratio;


for i=1:nints
    if(exist([ints(i).flat '_filt']))
        disp(['skipping ' ints(i).name]);
    else
        tmp=dir(ints(i).flat); %is output from diffnsim with phase+amp, we just want phase.
        if(tmp.bytes==nx*ny*4)
            disp([ints(i).flat ' already split to one band'])
        elseif(tmp.bytes==nx*ny*8)
            disp(['splitting ' ints(i).flat ' into just phs'])
            command=['cpx2mag_phs ' ints(i).flat ' mag phs ' num2str(nx)];
            mysys(command);
            command=['mv phs ' ints(i).flat];
            mysys(command);
        else
            disp([ints(i).flat ' wrong size?'])
            return
        end
        
        filter_diff(ints(i).flat,[ints(i).flat '_filt'],[ints(i).flat '_diff'], nx,ny,rx,ry);       
    end
end

