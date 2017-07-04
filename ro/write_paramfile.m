function write_paramfile(sat,masterdir,id,footprints,plotflag)

file=[masterdir 'set_params.m'];
if(exist(file,'file'))
    disp('')
    reply = input('overwrite existing set_params file? Y/N [Y]: ', 's');
    if(isempty(reply))
        reply='Y';
    end
    switch reply
        case 'Y'
            disp('overwriting')
        case 'N'
            disp('not overwriting')
    end
end

fid=fopen(file,'w');

fprintf(fid,'setenv(''GFORTRAN_STDIN_UNIT'',''5'')\n');
fprintf(fid,'setenv(''GFORTRAN_STDOUT_UNIT'',''6'')\n');
fprintf(fid,'setenv(''GFORTRAN_STDERR_UNIT'',''0'')\n\n');

baddatedir   = [masterdir 'baddates/'];
TSdir        = [masterdir 'TS/'];
rectdir      = [TSdir 'rect/'];
DEMdir       = [masterdir 'DEM/'];
intdir       = [TSdir 'int/'];
ts_paramfile = [TSdir 'ts_params.mat'];

fprintf(fid,['sat          = ''' sat          ''';\n']);
fprintf(fid,['masterdir    = ''' masterdir    ''';\n']);
fprintf(fid,['baddatedir   = ''' baddatedir   ''';\n']);
fprintf(fid,['TSdir        = ''' TSdir        ''';\n']);
fprintf(fid,['rectdir      = ''' rectdir      ''';\n']);
fprintf(fid,['DEMdir       = ''' DEMdir       ''';\n']);
fprintf(fid,['intdir       = ''' intdir       ''';\n']);
fprintf(fid,['ts_paramfile = ''' ts_paramfile ''';\n\n']);

if(isstruct(footprints))
    for j=1:length(footprints)
        fprintf(fid,['frames(' num2str(j) ').lat=[']);
        for i=1:4
            fprintf(fid,[num2str(footprints(j).lat(i)) ' ']);
        end
        fprintf(fid,'];\n');
        fprintf(fid,['frames(' num2str(j) ').lon=[']);
        for i=1:4
            fprintf(fid,[num2str(footprints(j).lon(i)) ' ']);
        end
        fprintf(fid,'];\n');
   end
else
    fprintf(fid,'frames(1).lat=[0 0 0 0];\n');
    fprintf(fid,'frames(1).lon=[0 0 0 0];\n');
end
fprintf(fid,'\n');
fprintf(fid,['id=' num2str(id) '; %%Master date id\n']);
fprintf(fid,'intid=1; %%Master int id\n');
fprintf(fid,'noff=100; %%number of offsets in ampcor in x and y\n');
fprintf(fid,'offwin=32; %%ampcor offset window size\n');
fprintf(fid,'searchwin = 64; %%ampcor search window size\n\n');

fprintf(fid,'dopcutoff=400;\n');
fprintf(fid,'azcutoff=500;\n\n');

fprintf(fid,'rlooks      = [4]; %%can be larger vector\n');
fprintf(fid,'pixel_ratio = 4;\n');
fprintf(fid,'alooks      = rlooks*pixel_ratio;\n');

fprintf(fid,['plotflag=' num2str(plotflag) ';%%0 suppresses plots\n\n']);

fprintf(fid,'for i=1:length(rlooks)\n');
fprintf(fid,'rlkdir{i}     = [TSdir ''looks'' num2str(rlooks(i)) ''/''];\n');
fprintf(fid,'maskfilerlk{i}= [rlkdir{i} ''mask_'' num2str(rlooks(i)) ''rlks.r4''];\n');
fprintf(fid,'end\n\n');

fprintf(fid,'avgslcfile = [TSdir ''avgslc.r4''];\n');
fprintf(fid,'gammafile  = [TSdir ''gamma0.r4''];\n');
fprintf(fid,'maskfile   = [TSdir ''mask.i1''];\n\n');

fprintf(fid,'badbase={};\n');
fprintf(fid,'addpairs=[]; %%rows of i1,i2\n');
fprintf(fid,'removepairs=[]; %%rows of i1,i2\n\n');
fclose(fid);

