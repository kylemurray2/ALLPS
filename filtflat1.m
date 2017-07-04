function filtflat1(i,nx,ny,rx,ry)
getstuff
    system(['rm ' ints(i).flat '_filt ' ints(i).flat '_diff']);
    filter_diff_iter(ints(i).flat,[ints(i).flat '_filt'],[ints(i).flat '_diff'], nx,ny,rx,ry,gammafile,1.5);
    snapnow;