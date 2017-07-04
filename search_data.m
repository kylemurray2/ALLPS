 function [dn,footprints,searchresults,sortresults,sortdn,apiCall]=search_data(track,frame,sat,plotflag,intersect_point)
%   track=166;
%   sat='S1A';
%   plotflag=1;
%   inter
% % intersect_point= [-117.861 33.765];% lon lat
%   frame=[480] ;
switch sat
    case 'ENVI'
         beam          = 'S2'; %most common for ENVI.
        satellite     = 'ENV1'; %unavco requires ENV1, ERS1,ERS2
        apiRoot       = 'http://www.unavco.org/SarArchive/SarScene?';
        apiCall       = [apiRoot 'status=archived&satellite=' satellite '&beamMode=IM &beamSwath=S2' '&track='  num2str(track) '&frame=' ];
          for i=1:length(frame)
            apiCall=[apiCall num2str(frame(i)) ',']; %api doesn't care about , at end.
          end
        
    case 'ERS'
        beam          = 'STD'; %most common for ENVI.
        satellite     = 'ERS1'; %unavco requires ENV1, ERS1,ERS2
        apiRoot       = 'http://www.unavco.org/SarArchive/SarScene?';
        if exist('intersect_point')
        
           apiCall='http://www.unavco.org/SarArchive/SarScene?status=archived&format=CEOS,ENVISAT,GEOTIFF,HDF5,COSAR,UNSPECIFIED&firstResult=0&track=170&frame=2925&end=2000-01-01&maxResults=1000&intersectsWith=POINT(-117.88230895996523%2033.74232189197713)&beamSwath=STD&satellite=ERS1,ERS2' 
            %apiCall       = [apiRoot 'sceneSize=frame&status=archived&satellite=' satellite '&relativeOrbit=' num2str(track) '&intersectsWith=Point(' num2str(intersect_point) ')'  '&beamSwath=' beam '&frame='];
        else
         apiCall       = [apiRoot 'sceneSize=frame&status=archived&satellite=ERS1,ERS2&relativeOrbit=' num2str(track)  ' &beamSwath=' beam '&frame='];
        end
          for i=1:length(frame)
            apiCall=[apiCall num2str(frame(i)) ',']; %api doesn't care about , at end.
        end

    case 'ALOS'        
        swath         = 7; % 7=lookangle 34.3, 10=look angle 41.        
        apiRoot       = 'http://web-services.unavco.org/brokered/ssara/api/sar/search?';
        apiCall       = [apiRoot 'processingLevel=L1.0&satellite=' sat '&beamSwath=' num2str(swath) '&beamMode=FBD,FBS&relativeOrbit=' num2str(track) '&frame='];
        for i=1:length(frame)
            apiCall=[apiCall num2str(frame(i)) ',']; %api doesn't care about , at end.
        end
    case 'S1A'
        apiRoot       = 'http://www.unavco.org/SarArchive/SarScene?status=archived';
        apiCall       = [apiRoot '&satellite=' sat   ')' ];
        for i=1:length(frame)
            apiCall=[apiCall num2str(frame(i)) '-0,']; %api doesn't care about , at end.
        end
end

%%%Run api command and load output- note that following fails if java not running.
output        = urlread(apiCall);
json          = loadjson(output);

if(json.count==0)
    disp(['no results returned:' json.message])
    disp('This is usually ASF or UNAVCOs fault.  Look at apiCall, paste into browser to debug. Or just run again.');
    return
end
searchresults = json.resultList;
searchresults = [searchresults{:}];

%%% Now sort.  Figure out how many unique dates, and (for now) ensure
%%% that all frames have all dates.
switch sat
    case {'ENVI','ERS','S1A'} %prefer WInSAR, then Earthscope, can't get supersites.
        alldate       = {searchresults.sceneDateString};
        alldn         = datenum(alldate);
        udn           = unique(alldn);
        collections   = {searchresults.collectionName};
        esvals        = strcmp(collections,'EarthScope ESA');
        winsvals      = strcmp(collections,'WInSAR ESA'); %for now, just use WInSAR.  But check against ESA collections
        searchresults = searchresults(or(esvals,winsvals));
        %repeat to use below
        collections   = {searchresults.collectionName};
        esvals        = strcmp(collections,'EarthScope ESA');
        winsvals      = strcmp(collections,'WInSAR ESA'); %for now, just use WInSAR.  But check against ESA collections
    end


%all footprints, for plotting:
fp  = {searchresults.stringFootprint};
fp  = regexp(fp,'(-|\.|\d)+','match'); %pull out ##s
for i=1:length(searchresults)
    tmp=str2num(char(fp{i}));
    alllon(i,:)=tmp(1:2:end)';
    alllat(i,:)=tmp(2:2:end)';
end

%%% Now sort.  Figure out how many unique dates, and (for now) ensure
%%% that all frames have all dates.  Different APIS have different text,
%%% unfortunately.
switch sat
    case {'ENVI','ERS','S1A'}
        dates         = {searchresults.sceneDateString};
        dn            = floor(datenum(dates));
        fms           = [searchresults.firstFrame]';     %frames
    case 'ALOS'
        dates         = {searchresults.sceneDate};
        dn            = floor(datenum(dates));          %datenum format
        fms           = {searchresults.frameNumber};    %frames
        fms           = str2num(char(fms));             %turn into vector
end
[dn0,ia]      = unique(dn);                             %unique dates

%painful loop figuring which dates are found for both frames, picking id to
%use if more than one is available (common for WInSAR).
if strcmp(sat,'S1A')==0
for j=1:length(dn0)
    for i=1:length(frame)        
        id=find(and(dn==dn0(j),fms==frame(i)));
        ntest(i,j)=length(id); %how many copies of this frame/date are there?
        if(ntest(i,j)==0) %none?  Uh oh.
            useid(i,j)=0;
        elseif(ntest(i,j)>1) %more than one?  
            test1=find(winsvals(id)); %first use WinSAR copy
            if(length(test1)>0)
                useids(i,j)=id(test1(1));
            else
                test2=find(esvals(id)); %then try using the first of the Earthscope copies.
                if(length(test2)>0)
                    useids(i,j)=id(test2(1));
                else
                    useids(i,j)=NaN;
                end
            end
        else
            useids(i,j)=id;
        end
    end
end
notallframe=sum(ntest==0,1);
if(sum(notallframe)>0)
   baddate=dn0(notallframe==1);
    disp('some dates not found in all frames: '); 
    datestr(baddate)
    
    goodid=~ismember(dn0,baddate);
    useids=useids(:,goodid);
end
else useids=1:length(dn0);
end
%finally sort out just the good ones
searchresults  = searchresults(useids(:));
dn             = dn(useids(:));
fms            = fms(useids(:));
[dn0,ia]       = unique(dn);
n              = length(searchresults);
ndates         = length(dn0);
for i=1:length(frame)
    frameid=[find(fms==frame(i))];
    
    footprints(i).lon = mean(alllon(useids(frameid),:),1);
    footprints(i).lat = mean(alllat(useids(frameid),:),1);
end

%sort dates, pull out "searchresults" string for first frame each date
firstids         = find(fms==frame(1));
[sortdn,sortid]  = sort(dn(firstids));
firstids         = firstids(sortid);
sortresults      = searchresults(firstids); %one "result" for each date, sorted ascending in time
if strcmp(sat,'S1A')
 sortresults      = searchresults
 [sortdn,sortid]  = sort(dn);
 end
if(plotflag) 
    %here is a spot to debug any footprint issues
    chosenlat=alllat(useids(:),:);
    chosenlon=alllon(useids(:),:);
    figure
    plot(alllon',alllat','k','linewidth',2)
    hold on
    plot(chosenlon',chosenlat','r')
    plot([footprints.lon]',[footprints.lat]','g')
    axis image
    legend('all','chosen','meanframe')
    print('-depsc','figs/footprint.eps');
%  sortresults(10).baselinePerp=10
    %%pull out estimated baselines for status plot
       if(strcmp(sat,'ERS') || strcmp(sat,'S1A'))
        bp=zeros(length(firstids),1);
   
        else
    for i=1:length(firstids)
        switch sat
            case 'ENVI'
                try
                    bp(i)=sortresults(i).baselinePerp;
                catch ME
                        bp(i)=0;%sortresults(i).baselinePerp;
                end
            case 'ALOS'
                bp(i) = str2num(sortresults(i).baselinePerp);
            
        end
    end
       end
    
if strcmp(sat,'S1A')
bp=zeros(length(dn),1);
 end
    
    %%make figure to check initial master id
    figure
    plot(sortdn,bp,'r.'),hold on
    text(sortdn,bp,num2str([1:length(sortdn)]'))
    datetick,grid on,box on
    ylabel('perp baseline, meters')
%     print('-depsc','baseline.eps');
end

