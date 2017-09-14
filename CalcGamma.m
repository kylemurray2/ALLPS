set_params
load(ts_paramfile)

for i=1:nints
    filename    = [ints(i).flat '_diff'];
    fid(i)      = fopen(filename,'r','native');
end
    
im = sqrt(-1);

% if(exist(gammafile))
%     disp([gammafile 'already made'])
% else
    fidout = fopen(gammafile,'w','native');
    
    for j=1:ny
        tic
        tmpcpx = complex(zeros(nints,nx),zeros(nints,nx)); %a chunk nints by nx
        nonz   = zeros(1,nx); %a row of zeros
        for i=1:nints            
            [dat,count]       = fread(fid(i),nx,'real*4');
            tmpcpx(i,1:count) = exp(im*dat); %diff complex number
            goodid            = dat~=0;
            nonz(goodid)      = nonz(goodid)+1; %adds a one for every int that has a nonzero 
        end
        %phsvar=-2*log(abs(sum(tmpcpx,1)./nonz));
        phsvar=abs(sum(tmpcpx,1)./nonz); %like coherence
        phsvar(nonz<nints)=0; %if there is one or more nonzeros, make it 0. (0 pixels are set in filter_diff_iter.m)
        fwrite(fidout,phsvar,'real*4');
    end     
    fclose(fidout);
% end

    fclose('all');



