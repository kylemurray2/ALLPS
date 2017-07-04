set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
    [nx,ny]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

end
newnx=floor(nx./rlooks)
newny=floor(ny./alooks);

for l=1:length(rlooks)
    for k=1:nints
        if(~exist(ints(k).unwrlk{l},'file'))
%             movefile(ints(k).unwrlk{l},[ints(k).unwrlk{l} '_flat']); %save original version
            command=['snaphu -s ' ints(k).unwrlk{l} '_flat -u ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{l} ' --tile 4 4 150 150'];
            mysys(command);
        end
    end
end



