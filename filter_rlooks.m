function filter_rlooks(filter_strength)

% filter int
% unwrap filtered int
% subtract unwrapped from filtered int - this should give you just near-integers *2pi (it won't be exact, though)
% add 2pi*n field to unfiltered int.

set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);

if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
    [nx,ny,lambda]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

end
     newnx   = floor(nx./rlooks)
     newny   = floor(ny./alooks);

if strcmp(sat,'ALOS')
    mysys(['cp /data/kdm95/ALOS_T211_650/TS/looks4/4rlks.rsc ' rlkdir{1}])
end

%make a 4 rlks rsc file
    file=[rlkdir{1} '4rlks.rsc'];
    fid=fopen(file,'w');
    fprintf(fid,[ 'WAVELENGTH    '   num2str(lambda)  ' \n' ]);
    fprintf(fid,[ 'XMIN           '  num2str(0)       ' \n' ]);                     
    fprintf(fid,[ 'XMAX           '  num2str(newnx)   ' \n' ]);                     
    fprintf(fid,[ 'WIDTH          '  num2str(newnx)   ' \n' ]);                        
    fprintf(fid,[ 'YMIN           '  num2str(0)       ' \n' ]);       
    fprintf(fid,[ 'YMAX           '  num2str(newny)   ' \n' ]);                     

for i=1:length(ints)
    ints(i).filtrlk= [rlkdir{1} 'filt_flat_' ints(i).name '_' num2str(rlooks) 'rlks.int'];
    ints(i).filtunwrlk= [rlkdir{1} 'filt_flat_' ints(i).name '_' num2str(rlooks) 'rlks.unw'];

    in=ints(i).flatrlk{1};
    mysys(['cp ' rlkdir{1} '4rlks.rsc ' in '.rsc'])
    mysys(['cp ' in ' orig_' in])
    out=[ints(i).filtrlk];
    command=['filter.pl ' in(1:end-4) ' ' num2str(filter_strength) ' psfilt ' out(1:end-4)];
    mysys(command); 
end

save(ts_paramfile,'ints','dates')


%Now unwrap the filtered ints
for l=1:1%length(rlooks)
    for k=1:nints     
%         if(~exist(ints(k).unwrlk{1},'file'))
            command=['snaphu -s ' ints(k).filtrlk ' ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{1} ' -c ' rlkdir{l} 'mask.cor  --tile 6 6 100 100'];
            mysys(command);
%         end
    end
end

%now load in the filtered int and the filtered unwrapped int and difference
%them to get 2pi*integer
