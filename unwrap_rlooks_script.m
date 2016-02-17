set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);
[nx,ny] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx   = floor(nx./rlooks)
newny   = floor(ny./alooks);
fid=fopen('run_snaphu.txt','w');

for l=1:length(rlooks)
    for k=1:nints     
        if(~exist(ints(k).unwrlk{l},'file'))
            command=['snaphu -s ' ints(k).flatrlk{l} ' ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{l} ' -c ' rlkdir{l} 'mask.cor  --tile 6 6 100 100'];
            fprintf(fid,command);
fprintf(fid,'\n');
        end
    end
end
fclose(fid);

