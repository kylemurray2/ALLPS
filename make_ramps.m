set_params
load(ts_paramfile);
ndates    = length(dates);
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];
diff_file = [oldintdir 'diffnsim_flat_HDR_'  dates(ints(intid).i1).name '-' dates(ints(intid).i2).name '.int.in'];

[nx,ny]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
mysys(['ln -s ' oldintdir dates(ints(intid).i1).name '-' dates(ints(intid).i2).name '.int ' intdir dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '.int']);
mysys(['ln -s ' oldintdir dates(ints(intid).i1).name '-' dates(ints(intid).i2).name '.int.rsc ' intdir dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '.int.rsc']);

for i=[1:id-1 id+1:ndates]
    rampname=[intdir 'ramp_' dates(i).name '.unw'];
    newdiff=[intdir 'diffnsim_' dates(i).name '.in'];
    if(~exist(newdiff,'file'))
        for j=1:7
            bvec(j)=dates(i).bvec(j)-dates(id).bvec(j);
        end
        copyfile(diff_file,newdiff);
        input(1).name='Ramped input interferogram';
        input(1).val=ints(intid).int;
        input(2).name='Differential output interferogram';
        input(2).val='jnk';
        input(3).name='DEM in radar coordinates';
        input(3).val=[oldintdir 'radar.hgt'];
        input(4).name='Simulated output DEM interferogram';
        input(4).val=rampname;
        input(5).name='Cross Track Baseline, Rate & Acceleration';
        input(5).val=num2str(bvec(1:3),10);
        input(6).name='Vertical Baseline, Rate, & Acceleration';
        input(6).val=num2str(bvec(4:6),10);
        input(7).name='Platform Altitude, Rate, & Acceleration';
        input(7).val=num2str(dates(id).hgtvec,10);
        input(8).name='Platform Velocity';
        input(8).val=num2str(dates(id).vel,10);
        input(9).name='Number of pixels down, across';
        input(9).val=[num2str(ny) ' ' num2str(nx)];
        input(10).name='Starting Range for SLCs';
        input(10).val=[num2str(dates(id).startrange,10) ' ' num2str(dates(i).startrange,10)];
        use_rdf(newdiff,'write',input);
    end
end

for i=[1:id-1 id+1:ndates]
    newdiff=[intdir 'diffnsim_' dates(i).name '.in'];   
    rampname=[intdir 'ramp_' dates(i).name '.unw'];
    if(~exist(rampname,'file'))
        command=['$INT_BIN/diffnsim ' newdiff];
        mysys(command);
    else
        disp([rampname ' already made'])
    end
end

