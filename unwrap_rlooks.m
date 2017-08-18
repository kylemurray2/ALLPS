% Unwrap_rlooks
%<^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^
%   Kyle Murray; July 2017
%   Takes *bell ints and outputs r4 .unw files.  Uses parallel
%   processing and tiles
%<^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^

clear all;close all
getstuff

% Specify snaphu options
ntilerow=20;
ntilecol=19;
nproc=8;


% Write snaphu configuration files
write_snaphu_conf(ntilerow,ntilecol,nproc); % Uses parallel processing and tiles

% Saves originals
for k=1:nints
    if(~exist([ints(k).unwrlk{1} '_orig'],'file'))
        if(exist([ints(k).unwrlk{1}],'file'))
            copyfile([ints(k).unwrlk{1}],[ints(k).unwrlk{1} '_orig'])
            disp(['moving ' ints(k).unwrlk{1} ' to ' ints(k).unwrlk{1} '_orig']);
        end
    end
end

% Run snaphu
for k=1:nints
    if(~exist([ints(k).unwrlk{1}],'file'))
        disp(['unwrapping ' ints(k).flatrlk{1}]);

        system(['snaphu -f ' ints(k).unwrlk{1} '_snaphu.conf >> tmp_log']);
    else
        disp('unw files already exist. Unwrapping ints and writing over it. Modify write_snaphu_conf() to reunwrap .unw files.')
        disp(['unwrapping ' ints(k).flatrlk{1}]);
        system(['snaphu -f ' ints(k).unwrlk{1} '_snaphu.conf']);

    end
end





% Uncomment and run to copy originals back to the .unw name.
% for k=1:nints
%     if(exist([ints(k).unwrlk{1} '_orig'],'file'))
%         if(exist([ints(k).unwrlk{1}],'file'))
%             copyfile([ints(k).unwrlk{1} '_orig'],[ints(k).unwrlk{1}])
%             disp(['moving ' ints(k).unwrlk{1} '_orig to ' ints(k).unwrlk{1}]);
%         end
%     else
%         disp([ints(k).unwrlk{1} '_orig does not exist'])
%     end
% end
