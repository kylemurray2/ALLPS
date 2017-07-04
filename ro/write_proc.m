load mystuff

n=length(dates);
for i=1:n-1
    %prep
    s1a=dir(['raw/s1a-iw*-slc-vv*' dates{i} '*.tiff']);
    s1b=dir(['raw/s1a-iw*-slc-vv*' dates{i+1} '*.tiff']);
    if(~and(length(s1a)==3,length(s1b)==3))
        disp(['not enough files found for dates ' dates{i} ' ' dates{i+1}]);
    else
        infile=[dates{i} '-' dates{i+1} 'proc.txt'];
        if(~exist(infile))
            fid=fopen(infile,'w');
            fprintf(fid,'cd raw\n');
            
            fprintf(fid,['align_tops.csh ' s1a(1).name(1:end-5) ' ' orbits{i} ' ' s1b(1).name(1:end-5) ' ' orbits{i+1} ' dem.grd\n']);
            fprintf(fid,['align_tops.csh ' s1a(2).name(1:end-5) ' ' orbits{i} ' ' s1b(2).name(1:end-5) ' ' orbits{i+1} ' dem.grd\n']);
            fprintf(fid,['align_tops.csh ' s1a(3).name(1:end-5) ' ' orbits{i} ' ' s1b(3).name(1:end-5) ' ' orbits{i+1} ' dem.grd\n']);
            
            fprintf(fid,'cd ..\n');
            for j=1:3
                
                fprintf(fid,['rm -r F' num2str(j) '/raw\n']);
                fprintf(fid,['cd F' num2str(j) '\n']);
                fprintf(fid,'mkdir raw\n');
                fprintf(fid,'cd raw\n');
                fprintf(fid,['ln -s ../../raw/*' dates{i} '*F' num2str(j) '* .\n']);
                fprintf(fid,['ln -s ../../raw/*' dates{i+1} '*F' num2str(j) '* .\n']);
                fprintf(fid,'cd ..\n');
                fprintf(fid,'mkdir topo\n');
                fprintf(fid,'cd topo\n');
                fprintf(fid,'ln -s ../../topo/dem.grd\n');
                fprintf(fid,'cd ../..\n ');
            end
            
            for j=1:3
                fprintf(fid,['cd F' num2str(j) '\n']);
                fprintf(fid,['p2p_S1A_TOPS.csh S1A' dates{i} '_F' num2str(j) ' S1A' dates{i+1} '_F' num2str(j) ' config.s1a.txt >& log \n']);
                fprintf(fid,'cd ..\n');
            end
            fclose(fid);
        end
    end
end
