function ps_interp_par(ii,gamma,alpha,R,im,msk)
getstuff
display(['filtering ' ints(ii).name])
%load int phase and correlation
    intfile=[ints(ii).flatrlk{1}];
    fid=fopen(intfile,'r','native');
      [rmg,count] = fread(fid,[newnx*2,newny],'real*4');
      status      = fclose(fid);
      real        = flipud((rmg(1:2:newnx*2,1:newny))');
      imag        = flipud((rmg(2:2:newnx*2,1:newny))');
%       cor         = abs(real+im*imag);
      phs1        = angle(real+im*imag);
      
     corfile=[ints(ii).flatrlk{1} '_cor'];
    fid=fopen(corfile,'r','native');
      [rmg,count] = fread(fid,[newnx,newny*2],'real*4');
      status      = fclose(fid);
      cor         = flipud((rmg(1:newnx,1:2:newny*2))');

%mask int to leave PS
     mask=msk>gamma | cor>alpha;     %high values are good

real(~mask)=0;
imag(~mask)=0;
      
% Do the interpolation

win_dimension=R*2+1;
win=ones(win_dimension);%make an odd window of ones
weight=zeros(size(win));
for i=1:win_dimension
    for j=1:win_dimension
        r(i,j)=sqrt(((R+1)-i)^2+((R+1)-j)^2); %distance from center of window
        weight(i,j)=exp((-r(i,j)^2)/(2*R)); %distance weighting
    end
end

weight=weight/sum(weight(:));
% % 
rea_f=zeros(size(mask));
ima_f=zeros(size(mask));

for j=1:newny-win_dimension
rea_f(j:j+win_dimension-1,:)=conv2(real(j:j+win_dimension-1,:),weight,'same');
ima_f(j:j+win_dimension-1,:)=conv2(imag(j:j+win_dimension-1,:),weight,'same');
end


real_final=rea_f+real;
imag_final=ima_f+imag;

phs = angle(real_final+im*imag_final);

display([num2str(100*(sum(mask(:))/(newnx*newny))) '% of points left after masking'])
fid=fopen('phs','w');
fwrite(fid,flipud(phs)','real*4');
fclose(fid);
system(['mag_phs2cpx ' maskfilerlk{1} ' phs ' ints(ii).flatrlk{1} '_interp ' num2str(newnx)]);