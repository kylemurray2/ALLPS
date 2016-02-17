set_params
load(ts_paramfile);

ndates         = length(dates);
nints          = length(ints);
[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

newnx = floor(nx./rlooks)
newny = floor(ny./alooks); 

for l=1:length(rlooks)
    fidr = fopen(['rates_' num2str(rlooks(l))],'r');
    for i=1:nints
        fidi(i)   = fopen(ints(i).unwrlk{l},'r');
        intrms(i) = 0;
    end
    
    for j=1:newny(l)
        rate = fread(fidr,newnx(l),'real*4')/lambda*(4*pi)/1000/365;%conver rate back to radians/day
        for i=1:nints
            jnk       = fread(fidi(i),newnx(l),'real*4');
            unw       = fread(fidi(i),newnx(l),'real*4');
            res       = unw-ints(i).dt*rate;
            intrms(i) = intrms(i) + sum(res.^2);
        end
    end
    for i=1:nints
        ints(i).rms=intrms(i)/newnx(l)/newny(l);
    end
end

intrms = [ints.rms];
badid  = find(intrms==max(intrms))
disp(['worst interferogram is ' num2str(badid)]);

save(ts_paramfile,'dates','ints');
fclose('all')

