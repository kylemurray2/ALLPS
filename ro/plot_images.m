function Mov=plot_images(flag,xr,yr)
%%% case 1 - plot all unwrapped ints
%%% case 2 - plot all unwrapped ints, in order of rate residual
%%% case 3 - plot inferred dates

set_params
load(ts_paramfile);

ndates         = length(dates);
nints          = length(ints);
[nx,ny,lambda] = load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH','WAVELENGTH');

newnx = floor(nx./rlooks);
newny = floor(ny./alooks);
if(isempty(xr))
xr=[1 newnx];
end
if(isempty(yr))
yr=[1 newny];
end

l=1;%for now, just use first rlooks value (usually 4)
%fid=fopen(maskfilerlk{l},'r');
%mask=fread(fid,[newnx(l),newny(l)],'real*4');
%mask=mask';
%badid=find(mask==0);
%fclose(fid);
badid=[];
figure

switch flag
    case 1 %plot all unwrapped ints
        for i=1:nints
            fid=fopen([ints(i).unwrlk{l} '_fixheight'],'r');
            unw=fread(fid,[newnx(l),newny(l)],'real*4');
            %unw(:,end:newny(l)*2)=NaN;
            %unw=unw(:,2:2:end)';
            unw(badid)=NaN;
            unw=unw';
            unw=unw(yr(1):yr(2),xr(1):xr(2));
            imagesc(unw)
            caxis([-5 5])
            title(ints(i).name)
            %caxis([-pi pi])
            pause
            
            Mov(i)=getframe;
            fclose(fid);
        end
        
    case 2 %plot all ints, sorted by rate residual (must have run calc_rate_residual.m)
        if(isfield(ints,'rms'))
            [jnk,sortid]=sort([ints.rms]);
            for i=sortid
                fid=fopen(ints(i).unwrlk{l},'r');
                unw=fread(fid,[newnx(l),newny(l)*2],'real*4');
                unw=unw(:,2:2:end)';
                unw(badid)=NaN;
                imagesc(unw)
                title(ints(i).name)
                Mov(i)=getframe;
                fclose(fid);
            end
        else
            disp('must run calc_rate_residual first')
        end
        
    case 3  %plot inferred time series, by date
        for i=1:ndates
            fid=fopen([dates(i).unwrlk{l} '_filtdiff'],'r');
            def=fread(fid,[newnx(l),newny(l)*2],'real*4');
            def=def';
            def(badid)=NaN;
            imagesc(def)
caxis([-5 5])
            title(dates(i).name)
            Mov(i)=getframe;
            fclose(fid);
        end
end
