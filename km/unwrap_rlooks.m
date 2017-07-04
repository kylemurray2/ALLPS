set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);

if strcmp(sat,'S1A')
    nx=ints(id).width;
    ny=ints(id).length;
else
    [nx,ny]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

end
     newnx   = floor(nx./rlooks)
     newny   = floor(ny./alooks);
     
% %mask using mask.cor
% fid=fopen([rlkdir{1} 'flat_' ints(id).name '_8rlks.rect.cor' ],'r');
% msk=fread(fid,[newnx,newny*2],'real*4');
% 
% msk=msk';
% msk=msk(1:2:newny,:);
% fclose(fid)
% 
% for l=1:length(rlooks)
%         for i=1:1
%             fid=fopen([ints(i).flatrlk{l}],'r');
%             tmp         = fread(fid,[newnx,newny],'real*4');
%             tmp(find(msk<.5))=0;
%             fidout=fopen([ints(i).flatrlk{l} '_new'],'w','native');
%             fwrite(fidout,tmp,'real*4')
%         end
% end



for l=1:length(rlooks)
    for k=1:nints     
        if(~exist([ints(k).unwrlk{1} '_b'],'file'))
            command=['snaphu -s ' ints(k).flatrlk{1} '_bell ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{1} ' -c ' rlkdir{l} 'mask.cor  --tile 5 5 150 150'];
            mysys(command);
        end
    end
end

!rm -r TS/looks4/snaphu*