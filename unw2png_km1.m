function unw2png_km1(wraprate,scale)
getstuff
chdir(['TS/looks' num2str(rlooks) '/'])
    !mkdir png_files
    for k=1:nints
        command=['mdx ' ints(k).unwrlk{1} ' -r4 -cmap cmy  -wrap ' num2str(wraprate) ' -ponly ' num2str(newnx)];
        mysys(command);
        
        command = ['convert out.ppm -resize ' num2str(scale) '%' ' -transparent cyan ' ints(k).name '.png'];
        system(command);
        !mv *.png png_files/
    end

    chdir(masterdir)

