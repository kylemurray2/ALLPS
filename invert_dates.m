function invert_dates(topoflag)
% topoflag=0;
%0 looks for unwrlk{l}, 1 adds _topo.unw to name.
set_params

[G,Gg,R,N]=build_Gint;
[m,n]=size(Gg);

for l=1:length(rlooks)
    for i=1:nints
        if(topoflag)
            infile=[ints(i).unwrlk '_topo.unw'];
        else
            infile=[ints(i).unwrlk];
        end
        if(~exist(infile))
            disp([infile ' does not exist'])
            return
        end
        %  mysys(['rmg2mag_phs ' infile ' mag phs ' num2str(newnx)])
        fidi(i)=fopen(infile,'r');
%         !rm phs
        % fidi(i)=fopen(infile,'r');
    end
    for i=1:ndates
        
        fido(i)=fopen([rlkdir dates(i).name '_' num2str(rlooks) 'rlks.r4'],'w');
    end
    fido2=fopen(['res_' num2str(rlooks(l))],'w');
    
    
    
    for j=1:newny(l)
        tmpdat=zeros(n,newnx(l)); %data for n-nints = zeros
        for i=1:nints
            jnk = fread(fidi(i),newnx(l),'real*4');
            tmpdat(i,1:length(jnk))=jnk;
        end
        
        mod    = Gg * tmpdat;
        synth  = G  * mod;
        res    = tmpdat-synth;
        resstd = std(res,1);
        fwrite(fido2,resstd,'real*4');
        for i=1:ndates
            fwrite(fido(i),mod(i,:),'real*4');
        end
    end
    fclose('all');
end

%This script writes a file called res_# in addition to the inverted dates.
%Each pixel is the standard deviation of the stack of residuals.  The
%residual is the difference between the phase of each unw int and the phase
%predicted by the model (the model is the inverted date). So the std will
%be high in places where the model isn't doing a good job predicting the
%deformation.  This will happen if there is a lot of noise in a particular
%int (like atm delays), decorrelated areas, areas with unwrapping errors
%or areas with aliased deformation signals.