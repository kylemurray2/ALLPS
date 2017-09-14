% Unwrap_rlooks
%<^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^
%   Kyle Murray; July 2017
%   Takes *bell ints and outputs r4 .unw files.  Uses parallel
%   processing and tiles
%<^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^><^

clear all;close all
set_params

% Specify snaphu options
ntilerow=30;
ntilecol=30;
nproc=38;


% Write snaphu configuration files
write_snaphu_conf(ntilerow,ntilecol,nproc); % Uses parallel processing and tiles

% Saves originals
for k=1:nints
    if(~exist([ints(k).unwrlk '_orig'],'file'))
        if(exist([ints(k).unwrlk],'file'))
            copyfile([ints(k).unwrlk],[ints(k).unwrlk '_orig'])
            disp(['moving ' ints(k).unwrlk ' to ' ints(k).unwrlk '_orig']);
        end
    end
end

% Run snaphu
for k=1:nints
    if(~exist([ints(k).unwrlk],'file'))
        disp(['unwrapping ' ints(k).flatrlk]);

        system(['snaphu -f ' ints(k).unwrlk '_snaphu.conf >> tmp_log']);
    else
        disp('unw files already exist. Unwrapping ints and writing over it. Modify write_snaphu_conf() to reunwrap .unw files.')
        disp(['unwrapping ' ints(k).flatrlk]);
        system(['snaphu -f ' ints(k).unwrlk '_snaphu.conf']);

    end
end





% Uncomment and run to copy originals back to the .unw name.
% for k=1:nints
%     if(exist([ints(k).unwrlk '_orig'],'file'))
%         if(exist([ints(k).unwrlk],'file'))
%             copyfile([ints(k).unwrlk '_orig'],[ints(k).unwrlk])
%             disp(['moving ' ints(k).unwrlk '_orig to ' ints(k).unwrlk]);
%         end
%     else
%         disp([ints(k).unwrlk '_orig does not exist'])
%     end
% end
