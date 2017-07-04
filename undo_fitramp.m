set_params
load(ts_paramfile);

nints=length(ints);

for l=1:length(rlooks)
    for i=1:nints
        
  movefile([ints(i).unwrlk{l} '_old'],ints(i).unwrlk{l});
        
    end
end
