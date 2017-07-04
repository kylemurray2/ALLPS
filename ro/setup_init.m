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
        command=('process_2pass.pl tmp.proc raw orbbase');
        [status(i), result]=mysys(command); 
    end
end
delete('tmp.proc');



