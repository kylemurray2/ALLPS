function make_dates_struct(dn,results)
set_params

if(isempty(dn))
    output = dir;
    for i=1:length(output)
        name=output(i).name;
        test=regexp(name,'^\d{8}$'); %name made up of just 8 digits, nothing else
        if(test)
            dn(end+1)=datenum(name,'yyyymmdd');
        else
        end
    end
end
for i=1:length(dn)
    
    dates(i).name    = datestr(dn(i),'yyyymmdd');
    dates(i).dn      = dn(i);
    dates(i).dir     = [masterdir dates(i).name '/'];
    dates(i).slc     = [dates(i).dir dates(i).name '.slc'];
    dates(i).raw     = [dates(i).dir dates(i).name '.raw'];
    dates(i).rectslc = [rectdir 'rect_' dates(i).name '.slc'];
    for j=1:length(rlooks)
        dates(i).unwrlk{j} = [rlkdir{j} dates(i).name '_' num2str(rlooks(j)) 'rlks.r4'];
    end
    if(~exist(dates(i).dir,'dir'))
        mkdir(dates(i).dir);
    end

    if(isstruct(results))
        dates(i).searchresults = results(i);
        fp  = dates(i).searchresults.stringFootprint;
        fp  = regexp(fp,'(-|\.|\d)+','match'); %pull out ##s
        dates(i).lon=str2num(char(fp{1:2:end}));
        dates(i).lat=str2num(char(fp{2:2:end}));
        
    end
end
save(ts_paramfile,'dates');


