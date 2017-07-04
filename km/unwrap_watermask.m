function unwrap_watermask(waterheight)
waterheight=-5;
        if(isempty(waterheight))
            waterheight=-3000;
        end

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


%__________________________________________________________________________
%mask out ocean
if ~strcmp(sat,'S1A')   
    oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];
            lookheightfile=[oldintdir 'radar_' num2str(rlooks(1)) 'rlks.hgt'];

                if(~exist(lookheightfile))
                    %----------------------------------------------------------
                    %KM Edit: There is no rsc file for the look.pl command (looking for
                    %radar.hgt.rsc)
                    command1=['cp ' oldintdir 'reference.hgt.rsc ' oldintdir 'radar.hgt.rsc'];
                    mysys(command1);
                    %----------------------------------------------------------
                    command=['look.pl ' fullresheightfile ' ' num2str(rlooks(l)) ' ' num2str(rlooks(l)*pixel_ratio)];
                    mysys(command);
                end

        fiddem  = fopen(lookheightfile,'r');
        tmp     = fread(fiddem,[newnx,newny*2],'real*4');
        dem     = tmp(:,2:2:end);
        fclose(fiddem);
         watermask = dem;  
    watermask(watermask<waterheight)=NaN;
    mask = isfinite(watermask);
    
else
         
        %looks.py [-h] -i INFILE [-o OUTFILE] [-r RGLOOKS] [-a AZLOOKS]
%         mysys(['looks.py -i ' [masterdir 'int_' ints(id).name '/merged/z.rdr'] ' -o ' [masterdir 'int_' ints(id).name '/merged/z_' num2str(rlooks) 'lks.rdr'] ' -r ' num2str(rlooks)  ' -a ' num2str(rlooks*pixel_ratio)])
%       fiddem = fopen([masterdir 'int_' ints(id).name '/merged/z_' num2str(rlooks) 'lks.rdr'],'r');
    fiddem = fopen([masterdir 'int_' ints(id).name '/merged/z.rdr'],'r');
    tmp     = fread(fiddem,[nx,ny],'real*8');
%         tmp     = fread(fiddem,[newnx,newny],'real*8');
    dem=tmp; 
    %DOWNSAMPLE by factor of 4
    dem=downsample(dem,4);
    dem=downsample(dem',4)';
    dem(:,2054)=[];
    fclose(fiddem);
    watermask = dem;  
    watermask(watermask<waterheight)=NaN;
    mask = isfinite(watermask);
end
    figure;subplot(1,3,1);imagesc(mask);title('mask')
%__________________________________________________________________________  


%create cpx files from the rmg files in TS/int/ if you don't run
%smart_rlooks
% for i=1:nints
%     mysys(['rmg2mag_phs ' ints(i).flat ' mag phs ' num2str(newnx)]);
% %     mysys(['cp ' intdir 'mag ' rlkdir{1}])
%     mysys(['mag_phs2cpx mag phs ' ints(i).flatrlk{1} ' ' num2str(newnx)]);
% end

%Load the CPX int and apply mask
    for i=1:nints
        fid         = fopen(ints(i).flatrlk{1},'r','native');
        [rmg,count] = fread(fid,[newnx*2,newny],'real*4');
         fclose(fid);
        real        = ((rmg(1:2:newnx*2,1:newny)));
        imag        = ((rmg(2:2:newnx*2,1:newny)));  
%         figure;imagesc(imag);caxis([-.1 .1])
    %Apply water mask
        imag(mask==0)=0;    
        real(mask==0)=0;
%         figure;imagesc(imag);caxis([-.1 .1])
    %write out masked file
        rmg=zeros(size(rmg));
        rmg(1:2:newnx*2,1:newny) = real;
        rmg(2:2:newnx*2,1:newny) = imag;  
        ints(i).flatmaskrlk{1}=[rlkdir{1} 'masked_flat_' ints(i).name '_' num2str(rlooks) 'rlks.int'];
        ints(i).unwmaskrlk{1}=[rlkdir{1} 'masked_flat_' ints(i).name '_' num2str(rlooks) 'rlks.unw'];

        fid  = fopen(ints(i).flatmaskrlk{1},'w');
        fwrite(fid,rmg,'real*4');
         fclose(fid)
    end
%__________________________________________________________________________   
%UNWRAP THE MASKED INTS            
for k=1:nints             
        if(~exist(ints(k).unwmaskrlk{1},'file'))
            command=['snaphu -s ' ints(k).flatmaskrlk{1} ' ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{1} ' -c ' rlkdir{1} 'mask.cor --mcf --tile 6 6 100 100'];
            mysys(command); 
        else
            disp(['skipping ' ints(k).name])
        end
end
save(ts_paramfile,'ints','dates')
watermask=mask;
save('watermask','watermask')

%%
%%Now subtract unw from filtered, * 2pi, then add 2pi*n to unfiltered int
%         for i=1:1
%             if exist(ints(i).unwrlk)
%                 if(~exist([ints(i).unwrlk '_old']))
%                     movefile([ints(i).unwrlk],[ints(i).unwrlk '_old']
%                 end
%             end
% 
%             fid          = fopen([ints(i).unwfiltrlk{l}],'r');
%                 unwfilt  = fread(fid,[newnx,newny],'real*4');
%             fclose(fid)
%             
%             fid         = fopen([ints(i).filtrlk{l}],'r');
%                 filt     = fread(fid2,[newnx,newny],'real*4');
%             fclose(fid)
%             
%             tmp         = filt-unwfilt;
%             clear filt unwfilt
%             fid         = fopen([ints(i).flatrlk{l}],'r');
%                 nonfilt     = fread(fid,[newnx,newny],'real*4');
%             fclose(fid)
%             
%             tmp         = nonfilt+ tmp;
%             
%             fid         = fopen([ints(i).unwrlk],'w');
%             fwrite(tmp,[newnx,newny],'real*4');
%             fclose(all)       
%         end
