function make_all_raw
set_params
load(ts_paramfile);
ndates=length(dates);

for i=1:ndates
    chdir(dates(i).dir)
    if(~exist(dates(i).raw))
        switch sat
            
            case 'ERS'
                %!gunzip *.gz
                !tar -xzvf *.gz
                !mv DAT_01.001 IMAGERY
                !ln -s LEA_01.001 SARLEADER
                command=['make_raw.pl PRC SARLEADER ' dates(i).name];
                mysys(command);               
            case 'ENVI'
                command=['make_raw_envi.pl ASA* DOR ' dates(i).name];
                mysys(command);
            case 'ALOS'
                
                types=dir('IMG*HV*'); %Check to see if this is FBD or FBS
                if(isempty(types))
                    command=['make_raw_alos.pl IMG ' dates(i).name];
                else
                    command=['make_raw_alos.pl IMG ' dates(i).name ' FBD2FBS'];
                end
                [status,result]=mysys(command);
        end
    else
        disp([dates(i).raw ' already exists'])
    end
end
chdir(masterdir);
