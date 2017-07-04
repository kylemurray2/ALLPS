%plot the ALLPS unwrapped ints to compare with StaMPS

getstuff

% allps_u=zeros(n_ps,nints);
for ii=1:nints
    fid=fopen([ints(ii).unwrlk{1}],'r');
    unw=fread(fid,[newnx, newny*2],'real*4');
    phs         = fliplr((unw(1:newnx,2:2:end))');
%    allps_u(:,ii)=phs(msk);
   fclose(fid);
end

% save('allps_u','allps_u');
