set_params
load(ts_paramfile);

ndates   = length(dates);
nints    = length(ints);
[nx,ny]  = load_rscs(ints(id).flat,'WIDTH','FILE_LENGTH');

im           = sqrt(-1);
rx           = 20; %should perhaps be set in set_params instead
ry           = rx*pixel_ratio;


for i=1:length(ints)
    if(exist([ints(i).flat '_filt']))
        disp(['skipping ' ints(i).name]);
    else
        tmp=dir(ints(i).flat); %is output from diffnsim with phase+amp, we just want phase.

            disp(['splitting ' ints(i).flat ' into just phs'])
            command=['rmg2mag_phs ' ints(i).flat ' mag phs ' num2str(nx)];
            mysys(command);
            command=['mv phs ' ints(i).flat];
            mysys(command);

        iter=0; %KM edit: changed it from 1
        if(iter)
            filter_diff_iter(ints(i).flat,[ints(i).flat '_filt'],[ints(i).flat '_diff'], nx,ny,rx,ry,gammafile,1.5);
        else
            filter_diff(ints(i).flat,[ints(i).flat '_filt'],[ints(i).flat '_diff'], nx,ny,rx,ry);
        end
    end
end
