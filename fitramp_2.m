set_params
load(ts_paramfile);

ndates    = length(dates);
nints     = length(ints);
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

[nx,ny]   = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');
newnx     = floor(nx./rlooks)
newny     = floor(ny./alooks);

for l=1:length(rlooks)

    [X,Y]=meshgrid(1:newnx(l),1:newny(l));
    
    
    fidmask = fopen(newmaskfile,'r');
    tmp     = fread(fidmask,[newnx(l),newny(l)],'real*4');
    fclose(fidmask);
mask=(tmp==1)';

    %check first int, throw away pts==0
    
      %nvert for ramp with remaining points
    Xg = X(mask);
    Yg = Y(mask);
    G  = [ones(size(Xg)) Xg Yg Xg.*Yg Xg.^2 Yg.^2];
    Gg = inv(G'*G)*G';
    
    
    for i=1:nints
        fid = fopen(ints(i).unwrlk{l},'r');
        tmp = fread(fid,[newnx(l),newny(l)],'real*4');
        fclose(fid);
        
        phs   = tmp';
     
        mod   = Gg*phs(mask);
        %synth = mod(1)+mod(2)*X+mod(3)*Y+mod(4)*X.*Y+mod(5)*X.^2+mod(6)*Y.^2+mod(7)*dem;
        %res   = phs-synth;
        %res(~mask)=0;
        
        %write flatenned unw file to output.
        %movefile(ints(i).unwrlk{l},[ints(i).unwrlk{l} '_old']);
        %fid=fopen(ints(i).unwrlk{l},'w');
        %fwrite(fid,tmp,'real*4');
        %fclose(fid);
allmods(i,:)=mod;

    end
end


	[G,Gg2]=build_Gint;
mod1=Gg2*[allmods;zeros(1,6)];


for i=2:ndates
  fid = fopen(dates(i).unwrlk{l},'r');
        tmp = fread(fid,[newnx(l),newny(l)],'real*4');
        fclose(fid);
        
        phs   = tmp';
     m2=phs==0;
 mod=mod1(i,:);
        synth = mod(1)+mod(2)*X+mod(3)*Y+mod(4)*X.*Y+mod(5)*X.^2+mod(6)*Y.^2;
        res   = phs-synth;
       
res(m2)=0;
        
        %write flatenned unw file to output.
        movefile(dates(i).unwrlk{l},[dates(i).unwrlk{l} '_old']);
        fid=fopen(dates(i).unwrlk{l},'w');
fid2=fopen([dates(i).unwrlk{l} '_ramp'],'w');

        fwrite(fid,res','real*4');
        fclose(fid);
fwrite(fid2,synth','real*4');
fclose(fid2);
%save(ts_paramfile,'dates','ints');
end
