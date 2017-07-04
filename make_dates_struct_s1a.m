function make_dates_struct_s1a(dn,results)
% set_params
!mkdir r4_files
if(isempty(dn)) %assumes you've already downloaded dates
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
    dates(i).bp      = 0; 

        dates(i).unwrlk = ['r4_files/' dates(i).name '_rlks.r4'];
    
    
    if(isstruct(results))
        dates(i).searchresults = results(i);
    end
end
save('ts_paramfile','dates');


