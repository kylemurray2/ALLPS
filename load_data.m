set_params
load(ts_paramfile)

switch sat
    case {'ENVI','ERS'}
        uname = 'rlohman';
        passw = 'starfish';
    case {'ALOS' , 'S1A'}
        %make cookies file
        %EOSDIS password info
        uname = 'rlohman';
        passw = 'Rolohman1';

end
parfor ii=1:length(dn)
    tic
%     if ~exist(dates(i).raw,'file')
        parraw(ii,sat,searchresults,dn,sortdn,uname,passw)
%     else
%         disp(['already raw'])
%     end
toc
end
  clear badid c  
c=[1];
badid=[];
for ii=1:length(dates)
    if ~exist(dates(ii).raw)
        badid(c)=ii
        c=c+1;
    end
end

if(badid)
    for i=1:length(badid)
        disp(dates(badid(i)).name)
    end

reply = input(['Could not make .raw files for above dates. They probably do not have orbit files available. Remove them from dates struct? y/n [y] '],'s')
        if(isempty(reply))
           reply='Y';
        end
    switch reply
        case {'Y','Yes','y','YES'}
            disp('Moving dates to baddate dir, editing date struct')
       olddates = dates;
        baddates = dates(badid);
        dates(badid)=[];
            newid    = find(strcmp({dates.name},olddates(id).name));%new id for master date if others thrown out(change in set_params or run_all.m) 
    for i=1:length(baddates)
        disp(['moving date ' baddates(i).name]);
        movefile(baddates(i).name,baddatedir);
    end
          disp(['change master date id in set_params to: ' num2str(newid)])
    disp('run fom setup_init if changing master date');
    disp('Otherwise just rerun read_dopbase');

    save(ts_paramfile,'dates');      
            
        case {'No','n','NO','N'}
            disp('not changing anything.')
          return
    end
end
    