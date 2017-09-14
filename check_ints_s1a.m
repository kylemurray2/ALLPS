%checks the ints struct to make sure we have int dirs for all of them
clear all;close all

set_params
badids=[];
for i=1:nints
if(~exist(ints(i).flat))
   disp([ints(i).flat 'does not exist (number ' num2str(i) ')'])
   badids= [badids;i];
end
end

if(exist('badids'))
 disp('')
    reply = input('Remove these from ints struct? Y/N [Y]: ', 's');
    if(isempty(reply))
        reply='Y';
    end
    switch reply
        case {'Y','Yes','y','YES'}
            disp('Deleting missing pairs from structure!')
            disp('Process more ints to bridge the gap.')

            ints([badids])=[];
        case {'No','n','N','NO'}
            disp('Process missing ints before continuing!')
            return
    end
    save(ts_paramfile,'dates','ints')
else
    disp('No missing pairs :)')
end