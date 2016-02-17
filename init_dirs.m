function init_dirs
if(exist('set_params.m','file')) % for some reason need this since init_dirs is not recognizing new set_params.m files.
end

set_params

if(~exist(baddatedir,'dir'))
    mkdir(baddatedir);
end
if(~exist(TSdir,'dir'))
    mkdir(TSdir);
end
if(~exist(rectdir,'dir'))
    mkdir(rectdir);
end
if(~exist([rectdir 'rectfiles/'],'dir'))
    mkdir([rectdir 'rectfiles/']);
end
if(~exist(intdir,'dir'))
    mkdir(intdir); 
end

if(~exist(DEMdir,'dir'))
    mkdir(DEMdir);
end

for i=1:length(rlooks)
    if(~exist(rlkdir{i},'dir'))
        mkdir(rlkdir{i});
    end
end


