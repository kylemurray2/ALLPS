set_params
load(ts_paramfile)
ndates=length(dates);

dates(id).bvec = zeros(1,7);
dates(id).bp   = 0;
dates(id).azoff=0;
dates(id).rgoff=0;


for i=[1:id-1 id+1:ndates]
    basefile=[masterdir 'intbase/' dates(id).name '_' dates(i).name '_baseline.rsc'];
    [hb,hbr,hba,vb,vbr,vba,bpt]=load_rscs(basefile,'H_BASELINE_TOP_HDR','H_BASELINE_RATE_HDR','H_BASELINE_ACC_HDR','V_BASELINE_TOP_HDR','V_BASELINE_RATE_HDR','V_BASELINE_ACC_HDR','P_BASELINE_TOP_HDR');
    dates(i).bvec=[hb hbr hba vb vbr vba bpt];
    dates(i).bp=bpt;
    dates(i).azoff=load_rscs(basefile,'ORB_SLC_AZ_OFFSET_HDR');
    dates(i).rgoff=load_rscs(basefile,'ORB_SLC_R_OFFSET_HDR');
end


%cull out points from list in "badbase" (in set_params.m)
goodidbase=true(size(dates));
for i=1:length(badbase)
    tmp=regexp({dates.name},badbase{i});
    tid=find(cellfun(@length,tmp));
    if(length(tid)>0)
        goodidbase(tid)=0;
        disp(['found ' badbase{i} ' in ' dates(tid).name])
    end
end

goodid   = goodidbase;
badid    = find(~goodid);

if(plotflag)
    maxd=max([dates.dn]);
    mind=min([dates.dn]);
    figure
    c=colormap;
    
    plot([dates.dn],[dates.bp],'.')
    hold on
    plot(dates(id).dn,dates(id).bp,'ko')
    datetick
    grid on
    ylabel('bp')
end   
 

if(sum(goodid)<ndates)
    disp('Throwing out following dates!')
    for i=1:length(badid)
        disp(dates(badid(i)).name)
    end
     reply = input('Okay to delete? Y/n [Y]: ', 's');
    if(isempty(reply))
        reply='Y';
    end
    switch reply
        case 'Y'
            disp('Moving dates to baddate dir, editing date struct')
        case 'N'
            disp('not changing anything: Run_all.m should now fail?')
    return
    end

    olddates = dates;
    baddates = dates(badid);
    dates    = dates(goodid);
    newid    = find(strcmp({dates.name},olddates(id).name));%new id for master date if others thrown out(change in set_params or run_all.m)
    for i=1:length(baddates)
        disp(['moving date ' baddates(i).name]);
        movefile(baddates(i).name,baddatedir);
    end
    disp(['change master date id in set_params to: ' num2str(newid)])
    disp('run fom setup_init if changing master date');
    disp('Otherwise just rerun read_dopbase');
    
    save(ts_paramfile,'dates');
    
else
    disp('using all dates')
    save(ts_paramfile,'dates');
   end


