function filtflat0(ii,nx,ny,rx,ry)
getstuff
    tmp=dir(ints(ii).flat); %is output from diffnsim with phase+amp, we just want phase.
    if(tmp.bytes==nx*ny*4)
        disp([ints(ii).flat ' already split to one band'])
    elseif(tmp.bytes==nx*ny*8)
        disp(['splitting ' ints(ii).flat ' into just phs'])
        command=['cpx2mag_phs ' ints(ii).flat ' mag phs ' num2str(nx)];
        mysys(command);
        command=['mv phs ' ints(ii).flat];
        mysys(command);
    else
        disp([ints(ii).flat ' wrong size?'])
        return 
    end
%         filter_diff(ints(ii).flat,[ints(ii).flat '_filtrate'],[ints(ii).flat '_filt'],[ints(ii).flat '_diff'],[ints(ii).flat 'raterem'], nx,ny,rx,ry);
 filter_diff(ints(ii).flat,[ints(ii).flat '_filt'],[ints(ii).flat '_diff'], nx,ny,rx,ry);