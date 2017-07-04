clear all;close all

set_params
load(ts_paramfile);
ndates  = length(dates);


%master int must have been run first, to determine any starting line offset.
resampname=[masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/' ints(intid).name '_resamp.in'];
if(~exist(resampname))
    disp(['need to run master int first: ' resampname]);
    return
end

input(1).name='Starting Line, Number of Lines, and First Line Offset';
tmp=use_rdf(resampname,'read',input);
tmp=str2num(tmp.val);
startline=tmp(1);
disp(['starting line is: ' num2str(startline) ': may need to be 1'])

rangepx = load_rscs(dates(id).raw,'RANGE_PIXEL_SIZE');
lambda  = load_rscs(dates(id).raw,'WAVELENGTH');
if(regexp(sat,'TSX'))
    initoff = 0;
    dop0    = 0;
    dop1    = 0;
    dop2    = 0;
    dop3    = 0;
    squint  = 0;
    azres=load_rscs(dates(1).raw,'AZIMUTH_PIXEL_SIZE');
else
    [dop0,dop1,dop2,dop3,azres,squint]=load_rscs('all.dop.rsc','DOPPLER_RANGE0','DOPPLER_RANGE1','DOPPLER_RANGE2','DOPPLER_RANGE3','AZIMUTH_RESOLUTION','SQUINT');
end
copyfile([dates(id).slc '.rsc'],[dates(id).rectslc '.rsc']);
dates(id).aff=[1 0 1 0 0 0];

[nx1,ny1]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

for i=[1:id-1 id+1:ndates]
%  for i=1   
    [nx2,ny2]=load_rscs(dates(i).slc,'WIDTH','FILE_LENGTH'); %number of lines
    offname=[rectdir 'rectfiles/' dates(i).name]; %Save the date name as offname
    
    if(~exist([offname '_fitoff.out']))
        command=['$INT_SCR/offset.pl ' dates(id).slc ' ' dates(i).slc ' ' offname ' 2 cpx ' num2str([dates(i).rgoff dates(i).azoff noff noff offwin searchwin])]
        mysys(command);
        command=['$MY_BIN/fitoff_quad ' offname '.off ' offname '_cull.off 1.5 0.5 50 > ' offname '_fitoff.out']
        mysys(command);
    end
end

if(plotflag)
    %check offsets
    f1 = figure('Name','X Offsets');
    f2 = figure('Name','Y Offsets');
    a  = floor(sqrt(ndates));
    b  = ceil(ndates/a);
    ax = [1 nx1 1 ny1];
 for i=[1:id-1 id+1:ndates]
%  for i=1  
        tmp=load([rectdir 'rectfiles/' dates(i).name '_cull.off']);
        
        figure(f1);
        subplot(a,b,i)
        scatter(tmp(:,1),tmp(:,3),12,tmp(:,2),'filled');
        axis(ax);
        colorbar('h')
        title(dates(i).name)
        
        figure(f2);
        subplot(a,b,i)
        scatter(tmp(:,1),tmp(:,3),12,tmp(:,4),'filled');
        axis(ax);
        colorbar('h')
        title(dates(i).name)
    end
   title(masterdir)
%    kylestyle
   
%     figure(f1)
%     print('-depsc',['figs/Xoff.eps ' masterdir]);
%     figure(f2)
%     print('-depsc',['figs/Yoff.eps ' masterdir]);
    
end

%Run rect
 for i=[1:id-1 id+1:ndates]
%  for i=1  
    if(~exist(dates(i).rectslc))
        command=['grep WARNING ' offname '_fitoff.out'];
        [status,result]=mysys(command);
        offname=[rectdir 'rectfiles/' dates(i).name];
        
        
        if(status)
            command=['$OUR_SCR/find_affine_quad.pl ' offname '_fitoff.out'];
            [junk,aff]=mysys(command);
            aff=str2num(aff);
            
            resampin=[rectdir 'rectfiles/resamp_' dates(i).name '.in'];
            fid=fopen(resampin,'w');
            fprintf(fid,'Image Offset File Name                      (-)     = %s\n',[offname '_cull.off']);
            fprintf(fid,'Display Fit Statistics to Screen                        (-)     = No Fit Stats\n');
            fprintf(fid,'Number of Fit Coefficients                              (-)     = 6\n');
            fprintf(fid,'SLC Image File 1                                        (-)     = %s\n',dates(id).slc);
            fprintf(fid,'Number of Range Samples Image 1                         (-)     = %d\n',nx1);
            fprintf(fid,'SLC Image File 2                                        (-)     = %s\n',dates(i).slc);
            fprintf(fid,'Number of Range Samples Image 2                         (-)     = %d\n',nx2);
            fprintf(fid,'Starting Line, Number of Lines, and First Line Offset   (-)     = %d %d 1\n',startline,ny1);
            fprintf(fid,'Doppler Cubic Fit Coefficients - PRF Units              (-)     = %12.8g %12.8g %12.8g 0\n',dop0,dop1,dop2);
            fprintf(fid,'Radar Wavelength                                        (m)     = %12.8g\n',lambda);
            fprintf(fid,'Slant Range Pixel Spacing                               (m)     = %12.8g\n',rangepx);
            fprintf(fid,'Number of Range and Azimuth Looks                       (-)     = 1 1\n');
            fprintf(fid,'Flatten with offset fit?                                (-)     = No \n');
            fprintf(fid,'Resampled SLC 1 File                                    (-)     = %s\n',dates(id).rectslc);
            fprintf(fid,'Resampled SLC 2 File                                    (-)     = %s\n',dates(i).rectslc);
            fprintf(fid,'Output Interferogram File                               (-)     = jnkint\n');
            fprintf(fid,'Multi-look Amplitude File                               (-)     = jnkamp\n');
            fprintf(fid,'END\n');
            fclose(fid);
            
            command=['$MY_BIN/resamp_roi_nofilter ' resampin];
            mysys(command);
            copyfile([dates(i).slc '.rsc'],[dates(i).rectslc '.rsc']);
            command=['$INT_SCR/use_rsc.pl ' dates(i).rectslc ' write WIDTH ' num2str(nx1)];
            mysys(command);
            command=['$INT_SCR/use_rsc.pl ' dates(i).rectslc ' write FILE_LENGTH ' num2str(ny1)];
            mysys(command);
            dates(i).aff=aff;
        else
            disp(result)
        end
    end
end
% %************************************************************************
%Make sure the rect file is not 0 size.  If it is, then this will delete
%all associated files.
%             for i=[1:id-1 id+1:ndates]
%                 s=dir([rectdir 'rect_' dates(i).name '.slc']);
%                 if size(s)==[0 1]
%                     s(1).bytes=1;
%                 end
%                 filesize=s.bytes;
%                 if filesize < 1e9 %if less than 1Gb
%                     system(['rm ' rectdir '*' dates(i).name '*']);
%                     system(['rm ' rectdir 'rectfiles/*' dates(i).name '*']);
%                     removed(i)=dates(i).name;
%                     display([dates(i).name ' was bad and deleted.Find offsets manually and/or increase window size. Then rerun this script'])
%                 end
%             end
% %************************************************************************
% 

if(exist('ints','var'))
    save(ts_paramfile,'dates','ints');
else
    save(ts_paramfile,'dates');
end
