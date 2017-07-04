%makes a frame to be used in gmt
set_params
frame_gmt=[[frames.lon]' [frames.lat]'; [frames.lon(1)] [frames.lat(1)] ];
dlmwrite([sat '_T' num2str(track) '_' num2str(frame) '.gmtframe'],frame_gmt,'delimiter',' ','precision','%.6f')
