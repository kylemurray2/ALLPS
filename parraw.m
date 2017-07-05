function parraw(ii,sat,searchresults,dn,sortdn,uname,passw)
set_params
load(ts_paramfile)

    datei=find(sortdn==dn(ii));
    downloadpath=searchresults(ii).downloadUrl;
    filename=regexprep(downloadpath,'.*/','');
    if(~exist(dates(datei).dir,'dir'));
        mkdir(dates(datei).dir);
    end
    test=dir([dates(datei).dir filename]);
    if(isempty(test))
        test(1).bytes=0;
    end
    if(test.bytes<1e12) %some large number
        tmp     = regexp(downloadpath,'/');
        name    = downloadpath(tmp(end)+1:end); %ALPSPR....
        
        switch sat
            case 'ENVI'
                command=['wget -r -nv -c --http-passwd=' passw ' --http-user=' uname ' --directory-prefix=' dates(datei).dir ' -nd ' downloadpath];
                mysys(command);
            case 'ALOS'
                command = ['wget -c --no-check-certificate --load-cookies=cookies.txt --directory-prefix=' dates(datei).dir ' -nd ' downloadpath];                
                mysys(command);
                
                %try to unzip - this is common fail point.
                chdir(dates(datei).dir)
                command=['unzip ' name];
                system(command);
                
                command=['mv ' name(1:end-4) '/* .'];
                system(command);
                chdir(masterdir);
        end
            else
        disp(['already downloaded' filename])
      
    end
    
    
  chdir(dates(datei).dir)
%     if(~exist(dates(datei).raw))
        switch sat
            
            case 'ERS'
                %!gunzip *.gz
                !tar -xzvf *.gz
                !mv DAT_01.001 IMAGERY
                !ln -s LEA_01.001 SARLEADER
                command=['make_raw.pl PRC SARLEADER ' dates(datei).name];
                mysys(command);               
            case 'ENVI'
                command=['make_raw_envi.pl ASA* DOR ' dates(datei).name];
                mysys(command);
            case 'ALOS'
                
                types=dir('IMG*HV*'); %Check to see if this is FBD or FBS
                if(isempty(types))
                    command=['make_raw_alos.pl IMG ' dates(datei).name];
                else
                    command=['make_raw_alos.pl IMG ' dates(datei).name ' FBD2FBS'];
                end
                [status,result]=mysys(command);
        end
%     else
%         disp([dates(datei).raw ' already exists'])
%     end
chdir(masterdir);
        


