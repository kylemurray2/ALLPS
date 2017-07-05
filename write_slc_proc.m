shifts=50;
set_params
load(ts_paramfile)
ndates=length(dates);


for i=1:ndates
    dateprocfile = [dates(i).dir dates(i).name '.proc']; %used by roi_prep to crop
    azoff=round(dates(i).azoff);
    rgoff=round(dates(i).rgoff);
    
    if(~exist(dateprocfile,'file'))
        %first round
        dates(i).rgoff_orig = azoff;
        dates(i).azoff_orig = rgoff;
        %orig values
        [wavel,startrange,prf,samp_frq,pulse,AntennaLen,velocity,xmin,xmax]=load_rscs(dates(i).raw,'WAVELENGTH','STARTING_RANGE','PRF','RANGE_SAMPLING_FREQUENCY','PULSE_LENGTH','ANTENNA_LENGTH','VELOCITY','XMIN','XMAX');
        speed_of_light = 299792458;
        
        rg_frac=0.4;
        az_frac=0.8;
        chirp_samps=ceil(samp_frq*pulse);
        near_rng_ext=ceil(chirp_samps*rg_frac);
        far_rng_ext=near_rng_ext;
        
        rng_pixel_size=speed_of_light/samp_frq/2;
        out_pixel=ceil(xmax/2-xmin/2-chirp_samps+near_rng_ext+far_rng_ext);
        slc_far_range=startrange+out_pixel*rng_pixel_size;
        synth_apert_samps = ceil(wavel*slc_far_range*prf/AntennaLen/velocity);
        before_z_ext=ceil(az_frac*synth_apert_samps);
        after_z_ext=before_z_ext;

        dates(i).before_z=before_z_ext;
        dates(i).after_z=after_z_ext;
        dates(i).near_r=near_rng_ext;
        dates(i).far_r=far_rng_ext;
        
        
        fid=fopen([dates(i).dir dates(i).name '.proc'],'w');
        if(i==id) %master date - > if this is zero, process_2pass sets it to the default values, + half aperture
            fprintf(fid,'before_z_ext = %d\n',before_z_ext);
            fprintf(fid,'after_z_ext = %d\n',after_z_ext);
            fprintf(fid,'near_rng_ext = %d\n',near_rng_ext);
            fprintf(fid,'far_rng_ext = %d\n',far_rng_ext);
            %fprintf(fid,'number_of_patches = 2\n');
        else
            fprintf(fid,'before_z_ext = %d\n',before_z_ext-azoff+shifts);
            fprintf(fid,'after_z_ext = %d\n',after_z_ext+azoff+shifts);
            fprintf(fid,'near_rng_ext = %d\n',near_rng_ext-rgoff+shifts);
            fprintf(fid,'far_rng_ext = %d\n',far_rng_ext+rgoff+shifts);
            %fprintf(fid,'number_of_patches = 2\n');
        end
        fclose(fid);
        
    else
        disp([dateprocfile ' already made, not changing.  Shifts = ' num2str(rgoff) ' ' num2str(azoff)]);
    end
end

 save(ts_paramfile,'dates');