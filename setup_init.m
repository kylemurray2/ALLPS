set_params
load(ts_paramfile);
ndates=length(dates);

roifile       = [dates(1).dir dates(1).name '_roi.in'];
if(exist(roifile,'file'))
    delete(roifile);
end
for i=[1:id-1 id+1:ndates] %make all relative to date "id"
    %check if raw exists
    infile=[dates(i).name '/' dates(i).name '.raw'];
    if(~exist(infile,'file'))
        disp([infile ' not found']);
    else
        roifile       = [dates(i).dir dates(i).name '_roi.in'];
        if(exist(roifile,'file'))
            delete(roifile);
        end
        fid=fopen('tmp.proc','w');
        
        fprintf(fid,['SarDir1=' masterdir dates(id).name '\n']);
        fprintf(fid,['SarDir2=' masterdir dates(i).name '\n']);
        fprintf(fid,['IntDir=intbase\n']);
        fprintf(fid,['OrbitType=HDR\n']);
        fprintf(fid,['pixel_ratio=1\n']);
        fprintf(fid,'\n');
        
        fclose(fid);
        switch sat
            case 'TSX'
                command=('process_2pass.pl tmp.proc roi_prep orbbase');
            otherwise
                command=('process_2pass.pl tmp.proc raw orbbase');
        end
        [status(i), result]=mysys(command);
    end
end

delete('tmp.proc');

for i=1:ndates
    [height,height_ds,height_dds] = load_rscs(dates(i).slc,'HEIGHT','HEIGHT_DS','HEIGHT_DDS');
    dates(i).sl_az_res            = load_rscs([dates(i).dir '/roi.dop'],'SL_AZIMUT_RESOL');
    dates(i).vel                  = load_rscs(dates(i).slc,'VELOCITY');
    dates(i).squint               = load_rscs(dates(i).raw,'SQUINT');
    if(ischar(dates(i).squint))
        dates(i).squint=str2num(dates(i).squint);
    end
    
    dates(i).hgtvec               = [height,height_ds,height_dds];
    dates(i).startrange           = load_rscs(dates(i).slc,'STARTING_RANGE');
end

save(ts_paramfile,'dates');


