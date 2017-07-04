function makeGamma(iter)
%iter=0 first iteration 
%iter=1 next iteration
%iter=2 remove restore rate map
%iter=3 remove restore next iteration

% set_params
% load(ts_paramfile);
getstuff
ndates   = length(dates);
nints    = length(ints);
[nx,ny]  = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

im           = sqrt(-1);
rx           = 3; %should perhaps be set in set_params instead
ry           = rx*pixel_ratio;

switch iter
    case 0
        display('Doing first iteration')
        tic
        parfor ii=1:nints
%                     tmp=dir(ints(ii).flat); %is output from diffnsim with phase+amp, we just want phase.
%             if(tmp.bytes==nx*ny*4)
%                 disp([ints(ii).flat ' already split to one band'])
%             elseif(tmp.bytes==nx*ny*8)
%                 disp(['splitting ' ints(ii).flat ' into just phs'])
%                 command=['cpx2mag_phs ' ints(ii).flat ' mag phs ' num2str(nx)];
%                 mysys(command);
%                 command=['mv phs ' ints(ii).flat];
%                 mysys(command);
%             else
%                     disp([ints(ii).flat ' wrong size?'])
%                     return 
%             end
%             filter_diff(ints(ii).flat,[ints(ii).flat '_filt'],[ints(ii).flat '_diff'], nx,ny,rx,ry);
        filtflat0(ii,nx,ny,rx,ry)
        end
        toc
        display('Making gamm0.r4')
        CalcGamma
    
    case 1
        display('Using TS/gamma0.r4 file for a subsequent iteration')
        tic
        for i=1:nints
%             filtflat1(i,nx,ny,rx,ry)
            system(['rm ' ints(i).flat '_filt ' ints(i).flat '_diff']);
            filter_diff_iter(ints(i).flat,[ints(i).flat '_filt'],[ints(i).flat '_diff'], nx,ny,rx,ry,gammafile,.2);
        end
        toc
        if ~exist('TS/gamma0_orig.r4','file')
        !mv TS/gamma0.r4 TS/gamma0_orig.r4
        end
        display('Making next iteration of gamma0.r4')
        CalcGamma
    case 2
        if ~exist('rates.unw','file')
        make_filtrate
        end
        tic
        for i=1:nints
        %             filtflat2(i,nx,ny,rx,ry)
            tmp=dir(ints(i).flat); %is output from diffnsim with phase+amp, we just want phase.
            if(tmp.bytes==nx*ny*4)
                    disp([ints(i).flat ' already split to one band'])
                elseif(tmp.bytes==nx*ny*8)
                    disp(['splitting ' ints(i).flat ' into just phs'])
                    command=['cpx2mag_phs ' ints(i).flat ' mag phs ' num2str(nx)];
                    mysys(command);
                    command=['mv phs ' ints(i).flat];
                    mysys(command);
                else
                    disp([ints(i).flat ' wrong size?'])
                    return 
            end
         filter_diff_remove_restore2(ints(i).flat,'rate_phs',[ints(i).flat '_filt'],[ints(i).flat '_diff'],[ints(i).flat '_raterem'], nx,ny,rx,ry,ints(i).dt,lambda);
        end
        toc
        display('Making gamm0.r4_raterem')
         CalcGamma_raterem
    case 3
        display('Using TS/gamma0.r4 file for a subsequent iteration')
        tic
        parfor i=1:nints
             filtflat3(i,nx,ny,rx,ry)  
        end   
        toc
        !mv TS/gamma0.r4_raterem TS/gamma0_orig.r4_raterem
        display('Making next iteration of gamm0.r4_raterem')
        CalcGamma_raterem
end