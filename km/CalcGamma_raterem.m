getstuff

for i=1:nints
    filename    = [ints(i).flat '_diff'];
    fid(i)      = fopen(filename,'r','native');
end
    
im = sqrt(-1);

if(exist([gammafile 'raterem']))
    disp([gammafile 'already made'])
else
    fidout = fopen([gammafile '_raterem'],'w','native');
    
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
        %phsvar=-2*log(abs(sum(tmpcpx,1)./nonz));
phsvar=abs(sum(tmpcpx,1)./nonz);
phsvar(nonz<nints)=0;
        fwrite(fidout,phsvar,'real*4');
    end
       
    fclose(fidout);
end
for i=1:nints
    fclose(fid(i));
end


