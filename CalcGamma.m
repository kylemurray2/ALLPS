set_params
load(ts_paramfile);

ndates      = length(dates);
nints       = length(ints);
[nx,ny]     = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
im          = sqrt(-1);


for i=1:nints
    filename     = [ints(i).flat '_diff'];
    fid(i)         = fopen(filename,'r','native');
end


if(exist(gammafile))
    disp([gammafile 'already made'])
else
    fidout = fopen(gammafile,'w','native');
    
    for j=1:ny
        tic
        tmpcpx = complex(zeros(nints,nx),zeros(nints,nx));
        nonz   = zeros(1,nx);
        for i=1:nints            
            [dat,count]       = fread(fid(i),nx,'real*4');
            tmpcpx(i,1:count) = exp(im*dat);
            goodid            = dat~=0;
            nonz(goodid)      = nonz(goodid)+1;
        end
        phsvar=-2*log(abs(sum(tmpcpx,1)./nonz));
        fwrite(fidout,phsvar,'real*4');
    end
       
    fclose(fidout);
end
for i=1:nints
    fclose(fid(i));
end


