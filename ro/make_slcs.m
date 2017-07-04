home=pwd;
set_params
load(ts_paramfile)
ndates=length(dates);

for i=1:ndates
    if(~exist(dates(i).slc,'file'))
        chdir(dates(i).dir);
        
        command=['roi '  dates(i).name '_roi.in > '  dates(i).name '_roi.out'];
        [status,result]=mysys(command);
        chdir(home);
    end
    
end




