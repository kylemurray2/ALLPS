for ii=1:nints
    
    conf =[ints(ii).unwrlk{1} '_snaphu.conf'];
    fid=fopen(conf,'w');
    
    fprintf(fid,['# Input                                                         \n']);
    fprintf(fid,['INFILE ' [ints(ii).flatrlk{1} '_bell']                          '\n']);
%     fprintf(fid,['UNWRAPPED_IN TRUE                                               \n']);
    fprintf(fid,['# Input file line length                                        \n']);
    fprintf(fid,['LINELENGTH '    num2str(newnx)                                 '\n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['# Output file name                                              \n']);
    fprintf(fid,['OUTFILE ' [ints(ii).unwrlk{1}]                                  '\n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['# Correlation file name                                         \n']);
    fprintf(fid,['CORRFILE  '      maskfilerlk{1}                                '\n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['# Statistical-cost mode (TOPO, DEFO, SMOOTH, or NOSTATCOSTS)    \n']);
    fprintf(fid,['STATCOSTMODE    SMOOTH                                          \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['INFILEFORMAT            FLOAT_DATA                              \n']);
    fprintf(fid,['UNWRAPPEDINFILEFORMAT   FLOAT_DATA                              \n']);
    fprintf(fid,['OUTFILEFORMAT           FLOAT_DATA                              \n']);
    fprintf(fid,['CORRFILEFORMAT          FLOAT_DATA                              \n']);
    fprintf(fid,['                                                                \n']);
    fprintf(fid,['NTILEROW 20                                                      \n']);
    fprintf(fid,['NTILECOL 14                                                     \n']);
    fprintf(fid,['# Maximum number of child processes to start for parallel tile  \n']);
    fprintf(fid,['# unwrapping.                                                   \n']);
    fprintf(fid,['NPROC                 35                                      \n']);
    fprintf(fid,['ROWOVRLP 100                                                    \n']);
    fprintf(fid,['COLOVRLP 100                                                    \n']);
    fprintf(fid,['RMTMPTILE TRUE                                                  \n']);
    fclose(fid);
    
    
end

disp('unwrapping on 35 cores, with 20x14 tiles')