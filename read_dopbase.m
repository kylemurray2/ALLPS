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
medaz=median([dates.azoff]);

for i=1:ndates
    if(~regexp(sat,'TSX'))
        %check if raw exists
        dopfile=dir([dates(i).name '/dop.mod']);
        if(isempty(dopfile))
            disp([dates(i).name ' dop.mod not found']);
        else
            alldop(i).dop=load([dates(i).name '/dop.mod']);
        end
    else
        alldop(i).dop=zeros(1,4);
        dates(i).dopres=0;
    end
end

if(~regexp(sat,'TSX'))
    allx=[];
    ally=[];
    for i=1:ndates
        allx=[allx;alldop(i).dop(:,1)];
        ally=[ally;alldop(i).dop(:,2)];
    end
    
    sf=fit(allx,ally,'poly2');
    dop=coeffvalues(sf);
    for i=1:ndates
        synth=feval(sf,alldop(i).dop(:,1));
        dates(i).dopres=sqrt(sum(synth-alldop(i).dop(:,2)).^2);
    end
end
%cull out points with bad dopplers and az offsets
goodiddop=[dates.dopres]<dopcutoff;
goodidaz = abs([dates.azoff]-medaz)<azcutoff;

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

goodid   = and(and(goodiddop,goodidbase),goodidaz);
badid    = find(~goodid);

if(plotflag)
    maxd=max([dates.dn]);
    mind=min([dates.dn]);
    figure
    c=colormap;
    
    subplot(2,2,1)
    scatter([dates.dn],[dates.bp],36,[dates.squint],'.')
    hold on
    plot(dates(id).dn,dates(id).bp,'ko')
    plot([dates(goodid).dn],[dates(goodid).bp],'k.','markersize',2)
    colorbar
    datetick
    grid on
    ylabel('bp')
    title('squint in color')
    
    subplot(2,2,2)
    plot([dates.dn],[dates.dopres],'.','markersize',18)
    hold on
    plot([mind,maxd],[dopcutoff dopcutoff],'r')
    plot([dates(goodid).dn],[dates(goodid).dopres],'ko')
    datetick
    ylabel('doppler res from quadratic fit')
    
    subplot(2,2,3)
    scatter([dates.dn],[dates.azoff],36,[dates.rgoff],'filled')
    hold on
    plot([dates(goodid).dn],[dates(goodid).azoff],'k.','markersize',2)
    plot([mind maxd],medaz*[1 1],'r:')
    plot([mind,maxd],medaz+azcutoff*[1 1],'r')
    plot([mind,maxd],medaz+azcutoff*[-1 -1],'r')
    datetick
    colorbar
    ylabel('az offs')
    title('color: range offs')
    
    if(~regexp(sat,'TSX'))
        axh(4)=subplot(2,2,4);
        hold on
        for i=1:ndates
            deltad=floor((dates(i).dn-mind)/(maxd-mind)*63)+1;
            plot(alldop(i).dop(:,1),alldop(i).dop(:,4),'-','Color',c(deltad,:))
        end
        c=colorbar;
        
        axis tight
        a=plot(sf);
        set(a,'linewidth',3,'color','k');
        y=datevec([dates.dn]);
        y=y(:,1);
        ys=min(y):max(y);
        set(c,'ytick',linspace(1,64,length(ys)))
        set(c,'yticklabel',num2str(ys'))
        xlabel('distance')
        ylabel('doppler model')
    end
    print('-depsc','figs/dopbase.eps');
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
        case {'Y','Yes','y','YES'}
            disp('Moving dates to baddate dir, editing date struct')
        case {'No','No','n','NO'}
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
    minaz = min([dates.azoff])
    save(ts_paramfile,'dates');
    
    if(~regexp(sat,'TSX'))
        
        system(['use_rsc.pl all.dop.rsc write DOPPLER_RANGE0 ' num2str(dop(3))]);
        system(['use_rsc.pl all.dop.rsc write DOPPLER_RANGE1 ' num2str(dop(2))]);
        system(['use_rsc.pl all.dop.rsc write DOPPLER_RANGE2 ' num2str(dop(1))]);
        system(['use_rsc.pl all.dop.rsc write DOPPLER_RANGE3 0']);
        system(['use_rsc.pl all.dop.rsc write AZIMUTH_RESOLUTION ' num2str(mean([dates.sl_az_res]))]);
        system(['use_rsc.pl all.dop.rsc write SQUINT ' num2str(mean([dates.squint]))]);
        
        for i=1:ndates
            [nx,ny] = load_rscs(dates(i).slc,'WIDTH','FILE_LENGTH');
            
            system(['use_rsc.pl ' dates(i).slc ' write DOPPLER_RANGE0 ' num2str(dop(3))]);
            system(['use_rsc.pl ' dates(i).slc ' write DOPPLER_RANGE1 ' num2str(dop(2))]);
            system(['use_rsc.pl ' dates(i).slc ' write DOPPLER_RANGE2 ' num2str(dop(1))]);
            system(['use_rsc.pl ' dates(i).slc ' write DOPPLER_RANGE3 0']);
            system(['use_rsc.pl ' dates(i).slc ' write SQUINT ' num2str(mean([dates.squint]))]);
            clear input
            roifile       = [dates(i).dir dates(i).name '_roi.in'];
            input(1).name = 'First line to read';
            tmp           = use_rdf(roifile,'read',input);
            oldstart      = str2num(tmp.val);
            if(i~=id)
                input(1).val = num2str(round(oldstart));
                system(['use_rsc.pl ' dates(i).slc ' write FILE_LENGTH ' num2str(ny+round(dates(i).azoff+minaz))]);
            else
                input(1).val = num2str(round(oldstart)-50);
                system(['use_rsc.pl ' dates(i).slc ' write FILE_LENGTH ' num2str(ny+round(minaz)-50)]);
                
            end
            input(2).name = 'Master file Doppler centroid coefs';
            input(2).val  = num2str([dop(3) dop(2) dop(1) 0],6);
            input(3).name = 'Second file Doppler centroid coefs';
            input(3).val  = num2str([dop(3) dop(2) dop(1) 0],6);
            input(4).name = 'Azimuth resolution';
            input(4).val  = num2str(mean([dates.sl_az_res]));
            
            use_rdf(roifile,'write',input);
        end
    end
end


