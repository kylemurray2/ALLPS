function [status, result]=mysys(command);
disp(command)
system(['echo ''' datestr(now) ': ' command ''' >>matlog']);
[status, result]=system(command);