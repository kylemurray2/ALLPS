% Unwrap_rlooks
%<^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^
%   Kyle Murray; July 2017
%   Takes *bell ints and outputs r4 .unw files.  Uses 35 core parallel
%   processing and 20x14 tiles
%<^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^

clear all;close all
getstuff

write_snaphu_conf(15,10,15); %(ntilerow,ntilecol,nproc) \\ uses parallel processing and tiles

for k=1:nints
    if(~exist([ints(k).unwrlk{1} '_orig'],'file'))
        if(exist([ints(k).unwrlk{1}],'file'))
            movefile([ints(k).unwrlk{1}],[ints(k).unwrlk{1} '_orig'])
            disp(['moving ' ints(k).unwrlk{1} ' to ' ints(k).unwrlk{1} '_orig']);
        end
    end
end
    
for k=1:nints
    if(~exist([ints(k).unwrlk{1}],'file'))
        disp(['unwrapping ' ints(k).flatrlk{1}]);
        system(['snaphu -f ' ints(k).unwrlk{1} '_snaphu.conf --mcf']);
    end
end
