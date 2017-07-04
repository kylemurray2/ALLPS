set_params                                                                                                                           
load(ts_paramfile);                                                                                                                  
ndates=length(dates);                                                                                                                
                                                                                                                                     
dn=[dates.dn];                                                                                                                       
bp=[dates.bp];                                                                                                                       
deltadn=repmat(dn,ndates,1)-repmat(dn',1,ndates);                                                                                    
deltabp=repmat(bp,ndates,1)-repmat(bp',1,ndates);                                                                                    
                                                                                                                                     
                                                                                                                                     
%Change doppler and baseline thresholds depending on satellite.                                                                      
switch sat                                                                                                                           
    case 'ENVI'                                                                                                                      
        dn_thresh = 300;                                                                                                             
        bp_thresh = 200;                                                                                                             
        [i1,i2]=find(and(and(deltadn>0,deltadn<dn_thresh),abs(deltabp)<bp_thresh));                                                  
                                                                                                                                     
    case 'ALOS'                                                                                                                      
        dn_thresh = 500;                                                                                                             
        bp_thresh = 1000;                                                                                                            
        [i1,i2]=find(and(and(deltadn>0,deltadn<dn_thresh),abs(deltabp)<bp_thresh));                                                  
end                                                                                                                                  
                                                                                                                                     
%add others here                                                                                                                     
if(~isempty(addpairs))                                                                                                               
    i1=[i1;addpairs(:,1)];                                                                                                           
    i2=[i2;addpairs(:,2)];                                                                                                           
end                                                                                                                                  
%remove pairs (by date index)                                                                                                        
if(~isempty(removepairs))                                                                                                            
    badid=ismember([i1 i2],removepairs,'rows');
    i1=i1(~badid);
    i2=i2(~badid);
end
%sort so that first int has master date
tmpid=find(i1==id);
if(~isempty(tmpid))
    i1=i1([tmpid(1) 1:tmpid(1)-1 tmpid(1)+1:end]);
    i2=i2([tmpid(1) 1:tmpid(1)-1 tmpid(1)+1:end]);
else
    disp('need an interferogram that starts with the master date')
end

if(plotflag)
    dnpair=[dates(i1).dn;dates(i2).dn];
    bppair=[dates(i1).bp;dates(i2).bp];
    
    figure
    plot(dnpair,bppair); hold on
    text(dn,bp,num2str([1:ndates]'))
    grid on
    datetick
 
end

%save int structure and params, build Gint for later inversion
clear ints
nints=length(i1);

for i=1:nints
    ints(i).i1=i1(i);
    ints(i).i2=i2(i);
    ints(i).dt=dates(i2(i)).dn-dates(i1(i)).dn;
    ints(i).name=[dates(i1(i)).name '-' dates(i2(i)).name];
    ints(i).int=[intdir ints(i).name '.int'];
    ints(i).flat=[intdir 'flat_' ints(i).name '.int'];
    for j=1:length(rlooks)
        ints(i).flatrlk{j}=[rlkdir{j} 'flat_' ints(i).name '_'  num2str(rlooks(j)) 'rlks.int'];
        ints(i).unwrlk{j}=[rlkdir{j} 'flat_' ints(i).name '_'  num2str(rlooks(j)) 'rlks.unw'];
        ints(i).unwmsk{j}=[rlkdir{j} 'ramp_' ints(i).name '_' num2str(rlooks(j)) 'rlks.unw'];
    end
    for j=1:7
        ints(i).bvec(j)=dates(i2(i)).bvec(j)-dates(i1(i)).bvec(j);
    end
    ints(i).bp=ints(i).bvec(7); %for convenience
end
save(ts_paramfile,'dates','ints');
[G,Gg,R,N]=build_Gint;

