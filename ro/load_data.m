function load_data(sat,searchresults,dn,sortdn)
set_params
load(ts_paramfile)

switch sat
    case 'ENVI'
        uname = 'rlohman';
        passw = 'starfish';
    case 'ALOS'
        %make cookies file
        %EOSDIS password info
        uname = 'rlohman';
        passw = 'Rolohman1';
        
        command=['wget --save-cookies cookies.txt --post-data=''user_name=' uname '&user_password=' passw ''' --no-check-certificate https://ursa.asfdaac.alaska.edu/cgi-bin/login -o /dev/null -O /dev/null'];
        system(command);
end

for i=1:length(searchresults)
    datei=find(sortdn==dn(i));
    downloadpath=searchresults(i).downloadUrl;
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
        disp(['already downloaded ' filename])
    end
end
