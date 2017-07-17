getstuff
l=1;k=1;


if(exist([ints(k).unwrlk{l} '_flat'],'file'))
    reply = input('*.unw_flat already exist.  Want to use them to make new .unw files? ', 's')
    if(isempty(reply))
        reply='Y';
    end
    switch reply
        case {'Y','yes','Yes','y','YES','yep'}
            disp('Overwriting *unw files, using *unw_flat.  Using tiles')
            flag=1;
        case {'No','no','N','n','NO','nope'}
            disp('Doing nothing..')
            flag=0;
            return
    end
else
    disp('*.unw_flat do not exist yet. Tagging .unw with _flat, and reunwrapping the _flat files.')
    flag=1;
end


if(flag==1)
    for l=1:length(rlooks)
        for k=1%:nints
            if(~exist([ints(k).unwrlk{l} '_flat'],'file'))
                movefile([ints(k).unwrlk{l}],[ints(k).unwrlk{l} '_flat']); %save original version
            end
            command=['snaphu -s ' ints(k).unwrlk{l} '_flat -u ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{l} ' -c ' rlkdir{l} 'mask.cor --mcf --tile 7 7 150 150'];
            mysys(command);
            
        end
    end
end


% l=1
%     for k=1:nints
%                  if(exist([ints(k).unwrlk{l} '_flat'],'file'))
%
%              movefile([ints(k).unwrlk{l} '_flat'],[ints(k).unwrlk{l}]); %save original version
%                  end
%     end





%command=['snaphu -s ' ints(k).unwrlk{l} '_flat -u ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{l} ' -c ' rlkdir{l} 'mask.cor --tile 7 7 150 150'];
%