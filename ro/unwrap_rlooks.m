set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);

for l=1:length(rlooks)
    for k=1:nints
        if(~exist(ints(k).unwrlk{l},'file'))
            if(exist('snaphu.in','file'))
                delete('snaphu.in');
            end
            if(exist('snaphu.corr.in','file'))
                delete('snaphu.corr.in');
            end
            system(['ln -s ' ints(k).flatrlk{l} '  snaphu.in']);
            system(['ln -s ' ints(k).flatrlk{l} '.cor snaphu.corr.in']);
            command=['snaphu -f ' rlkdir{l} 'snaphu.conf'];
            
            mysys(command);
            movefile('snaphu.out',ints(k).unwrlk{l});
        else
            disp([ints(k).unwrlk{l} ' already exists']);
        end
    end
end


