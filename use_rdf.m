function [output]=use_rdf(filename,type,input)
switch type
    case 'read'
fid=fopen(filename,'r');
        content=textscan(fid,'%s%s%s','delimiter','=');
        a=upper(content{1});%names
        b=content{2};%values
        bid=regexp(b,'!');
        for i=1:length(b)
if(length(bid{i})>0)
            tmp=b{i};
            tmp=tmp(1:bid{i}-1);
            b{i}=tmp;
end
        end
        c=content{3};%comments/units
        
        for j=1:length(input)
            string=input(j).name;
            string=upper(string);
            m=regexp(a,string);
            id=find(cellfun(@length,m));
            if(length(id)==1)
                output(j).name=input(j).name;
                output(j).val=b{id};
            else
                disp('Variable not found or found more than once');
            end
        end
        fclose(fid);
    case 'write'
        for j=1:length(input)
            fid1=fopen(filename,'r');
            fid2=fopen('tmp','w');
            found=0;
            while 1
                tline = fgetl(fid1);
                if ~ischar(tline)
                    break
                else
                    if(regexp(tline,input(j).name))
                        found=1;
                        fprintf(fid2,'%s (-) = %s !\n',input(j).name,input(j).val);
                    else
                        fprintf(fid2,'%s\n',tline);
                        
                    end
                end
            end
            if(found)
            else
                fprintf(fid2,'%s (-) = %s !\n',input(j).name,input(j).val);
            end
            fclose(fid1);
            fclose(fid2);
            movefile('tmp',filename);
        end
        
end

