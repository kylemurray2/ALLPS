function filtflat2(i,nx,ny,rx,ry)
%called by FilterFlat.m
getstuff
% if(exist([ints(i).flat '_raterem'],'var'))
%     disp(['skipping ' ints(i).name]);
% else
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
        filter_diff_remove_restore(ints(i).flat,'rate_phs',[ints(i).flat '_filt'],[ints(i).flat '_diff'],[ints(i).flat '_raterem'], nx,ny,rx,ry,ints(i).dt,lambda);
% end