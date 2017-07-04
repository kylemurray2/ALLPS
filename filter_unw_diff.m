function filter_unw_diff(filter_strength)
% filter_strength = 2;
% filter int
% unwrap filtered int
% subtract unwrapped from filtered int - this should give you just near-integers *2pi (it won't be exact, though)
% add 2pi*n field to unfiltered int.

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
% 
% if strcmp(sat,'ALOS')
%     mysys(['cp /data/kdm95/ALOS_T211_650/TS/looks4/4rlks.rsc ' rlkdir{1}])
% end

   %write the .rsc file
   out=[rlkdir{1} '4rlks.rsc'];
   fid = fopen(out,'wt+');
   fprintf(fid,'WIDTH %s\n',num2str(newnx));
   fprintf(fid,'FILE_LENGTH %s\n',num2str(newny));
   fprintf(fid,'XMIN %s\n',num2str(0));
   fprintf(fid,'XMAX %s\n',num2str(newnx));
   fprintf(fid,'YMIN %s\n',num2str(0));
   fprintf(fid,'YMAX %s\n',num2str(newny));  
   fclose(fid)


for i=1:length(ints)
    ints(i).filtrlk= [rlkdir{1} 'filt_flat_' ints(i).name '_' num2str(rlooks) 'rlks.int'];
    ints(i).filtunwrlk= [rlkdir{1} 'filt_flat_' ints(i).name '_' num2str(rlooks) 'rlks.unw'];

    in=ints(i).flatrlk{1};
    mysys(['cp ' rlkdir{1} '4rlks.rsc ' in '.rsc'])
    mysys(['cp ' in ' orig_' in])
    out=[ints(i).filtrlk];
    command=['filter.pl ' in(1:end-4) ' ' num2str(filter_strength) ' psfilt ' out(1:end-4)];
    mysys(command); 
end

save(ts_paramfile,'ints','dates')


%Now unwrap the filtered ints
for l=1:length(rlooks)
    for k=1:nints     
%         if(~exist(ints(k).unwrlk{1},'file'))
            command=['snaphu -s ' ints(k).filtrlk ' ' num2str(newnx(l)) ' -o ' ints(k).filtunwrlk ' -c ' rlkdir{l} 'mask.cor  --tile 6 6 100 100'];
            mysys(command);
%         end
    end
end

%now load in the filtered int and the filtered unwrapped int and difference
%them to get 2pi*integer
for k=1:nints
    un_filt=ints(k).flatrlk{1};
    filt_int=ints(k).filtrlk;
    filt_unw=ints(k).filtunwrlk;
    %split into just phs
        mysys(['cpx2mag_phs ' un_filt  ' mag0 phs0 ' num2str(newnx)])
        mysys(['cpx2mag_phs ' filt_int ' mag1 phs1 ' num2str(newnx)])
        mysys(['rmg2mag_phs ' filt_unw ' mag2 phs2 ' num2str(newnx)])
    fid0=fopen('phs0','r','native');
    fid1=fopen('phs1','r','native');
    fid2=fopen('phs2','r','native');
        if ~exist([ints(k).unwrlk{1} '_orig'])
            command=['mv ' ints(k).unwrlk{1} ' ' ints(k).unwrlk{1} '_orig'];
            mysys(command)
            command=['rm ' ints(k).unwrlk{1}];
            mysys(command)
        end
    fid3=fopen('phs','w');
    
    f0=fread(fid0,[newnx,newny/2],'real*4');
    f1=fread(fid1,[newnx,newny/2],'real*4');
    f2=fread(fid2,[newnx,newny/2],'real*4');
    f3=f2-f1;
    f3(find(f3<1))=0;
    f4=f0+f3;
    fwrite(fid3,f4,'real*4')
    mysys(['mag_phs2rmg mag0 phs ' ints(k).unwrlk{1} ' ' num2str(newnx)])
    fclose('all')
    !rm mag* phs*
end
%plot the last one as example
figure
subplot(2,2,1);imagesc(f0);axis image;title('unfiltered interferogram');colorbar
subplot(2,2,2);imagesc(f1);axis image;title('filtered interferogram');colorbar
subplot(2,2,3);imagesc(f2);axis image;title('unwrapped filtered interferogram');colorbar
subplot(2,2,4);imagesc(f3);axis image;title('difference');colorbar
figure
imagesc(f4);axis image;title('unfiltered interferogram + 2pi*n values');colorbar