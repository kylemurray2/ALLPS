set_params
load(ts_paramfile);
ndates  = length(dates);
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '_' dates(ints(intid).i2).name '/'];

%run master_int to get starting line of any offsets.
resamp_file   = [oldintdir dates(ints(intid).i1).name '-' dates(ints(intid).i2).name '_resamp.in'];
input(1).name ='Starting Line, Number of Lines, and First Line Offset';
info          = use_rdf(resamp_file,'read',input);
info          = str2num(info.val);
startline     = info(1);
ny            = info(2);

 
%initoff = 50; %this was used in read_dopbase to shift the master date backwards 
lambda  = load_rscs(dates(id).raw,'WAVELENGTH');
%[dop0,dop1,dop2,dop3,azres,squint]=load_rscs('all.dop.rsc','DOPPLER_RANGE0','DOPPLER_RANGE1','DOPPLER_RANGE2','DOPPLER_RANGE3','AZIMUTH_RESOLUTION','SQUINT');
[nx1,ny1]=load_rscs(dates(id).slc,'WIDTH','FILE_LENGTH');

%crop master date if necessary
if(startline>1)      
    rectin=[rectdir 'rectfiles/rect_' dates(i).name '.in'];
    fid=fopen(rectin,'w');
    fprintf(fid,'Input Image File Name  (-) = %s        ! dimension of file to be rectified\n',dates(id).slc);
    fprintf(fid,'Output Image File Name (-) = %s       ! dimension of output\n',dates(id).rectslc);
    fprintf(fid,'Input Dimensions       (-) = %d %d ! across, down\n',nx1,ny1);
    fprintf(fid,'Output Dimensions      (-) = %d %d! across, down\n',nx1,ny);
    fprintf(fid,'Affine Matrix Row 1    (-) = 1 0     ! a b\n');
    fprintf(fid,'Affine Matrix Row 2    (-) = 0 1    ! c d\n');
    fprintf(fid,'Affine Offset Vector   (-) = 0 %d       ! e f\n',startline);
    fprintf(fid,'File Type              (-) = COMPLEX       ! [RMG, COMPLEX]\n');
    fprintf(fid,'Interpolation Method   (-) = Bilinear        ! [NN, Bilinear, Sinc]\n');
    fclose(fid);
    
    command=['rect ' rectin];
    mysys(command);
    command=['$INT_SCR/use_rsc.pl ' dates(id).slc ' write FILE_LENGTH ' num2str(ny)];
    mysys(command);
    copyfile([dates(id).slc '.rsc'],[dates(id).rectslc '.rsc']);
    command=['$INT_SCR/use_rsc.pl ' dates(id).rectslc ' write WIDTH ' num2str(nx1)];
    mysys(command);
    command=['$INT_SCR/use_rsc.pl ' dates(id).rectslc ' write FILE_LENGTH ' num2str(ny)];
    mysys(command);

else
    copyfile([dates(id).slc],[dates(id).rectslc]);
    copyfile([dates(id).slc '.rsc'],[dates(id).rectslc '.rsc']);
end
dates(id).aff=[1 0 1 0 0 0];

for i=[1:id-1 id+1:ndates]
    [nx2,ny2]=load_rscs(dates(i).slc,'WIDTH','FILE_LENGTH');
    
    offname=[rectdir 'rectfiles/' dates(i).name];
    if(~exist([offname '_fitoff.out']))
        command=['$INT_SCR/offset.pl ' dates(id).slc ' ' dates(i).slc ' ' offname ' 2 cpx ' num2str([dates(i).rgoff dates(i).azoff noff noff offwin searchwin])];
        mysys(command);
        command=['$MY_BIN/fitoff_quad ' offname '.off ' offname '_cull.off 1.5 0.2 100 > ' offname '_fitoff.out'];
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
end

%Run rect
for i=[1:id-1 id+1:ndates]
    if(~exist(dates(i).rectslc))
        command=['grep WARNING ' offname '_fitoff.out'];
        [status,result]=mysys(command);
        offname=[rectdir 'rectfiles/' dates(i).name];
        
        
        if(status)
            command=['$OUR_SCR/find_affine_quad.pl ' offname '_fitoff.out'];
            [junk,aff]=mysys(command);
            aff=str2num(aff);
            [dop0,dop1,dop2,dop3,azres,squint]=load_rscs(dates(i).slc,'DOPPLER_RANGE0','DOPPLER_RANGE1','DOPPLER_RANGE2','DOPPLER_RANGE3','AZIMUTH_RESOLUTION','SQUINT');
            rangepx = load_rscs(dates(i).raw,'RANGE_PIXEL_SIZE');

            resampin=[rectdir 'rectfiles/resamp_' dates(i).name '.in'];
            fid=fopen(resampin,'w');
            fprintf(fid,'Image Offset File Name                      (-)     = %s\n',[offname '_cull.off']);
            fprintf(fid,'Display Fit Statistics to Screen                        (-)     = No Fit Stats\n');
            fprintf(fid,'Number of Fit Coefficients                              (-)     = 6\n');
            fprintf(fid,'SLC Image File 1                                        (-)     = %s\n',dates(id).slc);
            fprintf(fid,'Number of Range Samples Image 1                         (-)     = %d\n',nx1);
            fprintf(fid,'SLC Image File 2                                        (-)     = %s\n',dates(i).slc);
            fprintf(fid,'Number of Range Samples Image 2                         (-)     = %d\n',nx2);
            fprintf(fid,'Starting Line, Number of Lines, and First Line Offset   (-)     = %d %d 1\n',startline,ny);
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
            command=['$INT_SCR/use_rsc.pl ' dates(i).rectslc ' write FILE_LENGTH ' num2str(ny)];
            mysys(command);
            dates(i).aff=aff;
        else
            disp(result)
        end
    end
end






if(exist('ints','var'))
    save(ts_paramfile,'dates','ints');
else
    save(ts_paramfile,'dates');
end
