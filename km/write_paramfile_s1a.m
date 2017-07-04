function write_paramfile_s1a(sat,masterdir,id,plotflag,pixel_ratio)

file=[masterdir 'set_params.m'];

    disp('')
    reply = input('overwrite existing set_params file? Y/N [Y]: ', 's');
    if(isempty(reply))
        reply='Y';
    end
    switch reply
        case {'Y','Yes','y','YES'}
            disp('overwriting')
            fid=fopen(file,'w');

fprintf(fid,'setenv(''GFORTRAN_STDIN_UNIT'',''5'')\n');
fprintf(fid,'setenv(''GFORTRAN_STDOUT_UNIT'',''6'')\n');
fprintf(fid,'setenv(''GFORTRAN_STDERR_UNIT'',''0'')\n\n');

fprintf(fid,['masterdir    = ''' masterdir    ''';\n']);

baddatedir   = [masterdir 'baddates/'];
TSdir        = [masterdir 'TS/'];
rectdir      = [TSdir 'rect/'];
DEMdir       = [masterdir 'DEM/'];
intdir       = [TSdir 'int/'];
ts_paramfile = [TSdir 'ts_params.mat'];

fprintf(fid,['sat          = ''' sat          ''';\n']);
fprintf(fid,['baddatedir   = ''' baddatedir   ''';\n']);
fprintf(fid,['TSdir        = ''' TSdir        ''';\n']);
fprintf(fid,['rectdir      = ''' rectdir      ''';\n']);
fprintf(fid,['DEMdir       = ''' DEMdir       ''';\n']);
fprintf(fid,['intdir       = ''' intdir       ''';\n']);

ts_paramfile = [masterdir 'ts_params.mat'];
fprintf(fid,['ts_paramfile = ''' ts_paramfile ''';\n\n']);


fprintf(fid,'\n');
fprintf(fid,['id=' num2str(id) '; %%Master date id\n']);
fprintf(fid,'intid=1; %%Master int id\n');
fprintf(fid,'noff=100; %%number of offsets in ampcor in x and y\n');
fprintf(fid,'offwin=64; %%ampcor offset window size\n');
fprintf(fid,'searchwin = 64; %%ampcor search window size\n\n');
fprintf(fid,['lambda = 0.05546576; %%0.05546576 for S1A \n']);

fprintf(fid,'rlooks      = [4]; %%can be larger vector\n');
fprintf(fid,['pixel_ratio = ' num2str(pixel_ratio) ';\n']);
fprintf(fid,'alooks      = rlooks*pixel_ratio;\n');

fprintf(fid,['plotflag=' num2str(plotflag) ';%%0 suppresses plots\n\n']);

fprintf(fid,['if exist(ts_paramfile,''file'')\n']);
fprintf(fid,['    load(ts_paramfile);\n']);
fprintf(fid,['    ndates         = length(dates);\n']);
fprintf(fid,['    nints          = length(ints);\n']);
fprintf(fid,['end\n']);

fprintf(fid,'for i=1:length(rlooks)\n');
fprintf(fid,'rlkdir{i}     = [TSdir ''looks'' num2str(rlooks(i)) ''/''];\n');
fprintf(fid,'maskfilerlk{i}= [rlkdir{i} ''mask_'' num2str(rlooks(i)) ''rlks.r4''];\n');
fprintf(fid,'end\n\n');

fprintf(fid,'avgslcfile = [TSdir ''avgslc.r4''];\n');
fprintf(fid,'gammafile  = [TSdir ''gamma0.r4''];\n');
fprintf(fid,'maskfile   = [TSdir ''mask.i1''];\n\n');


fprintf(fid,['    newnx = 3708;\n']);
fprintf(fid,['    newny = 3096; \n']);


fclose(fid);
        case {'No','No','n','NO'}
            disp('not overwriting')
            return
    end


    
    


