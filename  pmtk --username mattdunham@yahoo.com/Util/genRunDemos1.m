function genRunDemos
% This script automatically generates the runDemos.m file, which contains
% code to run selected BLT demos. It searches through every class method
% and includes those methods that meet the criteria specified in the
% subfunction include().

% Each included method is written to the runDemos file as in
%
%    methodName1(className1);
%    methodName2(className2);
% 
%    or, if static as
%
%   className1.methodName1();
%   className2.methodName2();
%
% and must therefore be capable of running as such. No checks are performed
% to ensure that this is the case. 
%
% If runDemos.m already exists, it is renamed runDemos.old. If there is
% already a runDemos.old file, it is overwritten. 
%
% This function will only work on windows systems. Run this script from the
% top level BLT directory.
%
% Version 2

filename = 'runDemos';    %The name of the generated m-file.
rootdir  = '.';           %Start searching from the current directory.


function bool = include(method,classname)
%Include methods satisfying these criteria. method is a structure
%holding info about the underlying method; classname is a string.
    bool =  strncmpi(method.Name,'demo',4) &&...                %method name begins with 'demo'                 
            method.Static                  &&...                %method is static        
            strcmpi(method.Access,'public')&&...                %Make sure its public
           ~method.Abstract                &&...                %Make sure its implemented
            strcmp(method.DefiningClass.Name,classname);        %Don't grab superclass definitions
           %strcmpi('#demo',strtok(help([classname,'.',method.Name])));
                                   %first word of method comment is '#demo'
end


renameold(filename);
fid = openfile(filename);
classes = getclasses(rootdir);
writedemos(fid,classes);
closefile(fid);


   

function writedemos(fid,classes)
%Search through every class for methods satisfying the include statements
%and write calling syntax to the open file (fid).
    for i=1:numel(classes)
        try
            meta = eval(['?',classes{i}]);
            methods = meta.Methods;
            for m =1: numel(methods)
                method = methods{m};
                if(include(method,classes{i}))
                    if(method.Static)
                        fprintf(fid,[classes{i},'.',method.Name,'();\n']);  
                    else
                        fprintf(fid,[method.Name,'(',classes{i},');\n']);
                    end
                end
            end
        catch ME
            warning('CLASSTREE:discoveryWarning',['Could not discover information about class ',classes{i}]);
            continue; %Keep going, even if there's an error. 
        end
    end
end

    
function classes = getclasses(directory)
%Return the names of all of the classes in the specified directory and all
%of its subdirectories. 
    info = dirinfo(directory);
    classes = vertcat(info.classes); 
    function info = dirinfo(directory)
        info = what(directory);
        flist = dir(directory);
        dlist =  {flist([flist.isdir]).name};
        for i=1:numel(dlist)
            dirname = dlist{i};
            if(~strcmp(dirname,'.') && ~strcmp(dirname,'..'))
                info = [info, dirinfo([directory,'\',dirname])]; 
            end
        end
    end
end

function fid = openfile(filename)
    fid = fopen([filename,'.m'],'w');
    fprintf(fid,'%%Code automatically generated by genRunDemos.\n%%Run BLT demos.\n');
end

function closefile(fid)
    fprintf(fid,'\n');
    fclose(fid);
end

function renameold(filename)
%Rename existing output file, if any to filename.old
    flist = dir;
    files = {flist.name};
    if(ismember([filename,'.m'],files))
        fprintf(['\nrenaming ',filename,'.m as ',filename,'.old ...\n']);
        if(ismember([filename,'.old'],files))
            eval(['!del ',filename,'.old']);
        end
        eval(['!rename ',filename,'.m ',filename,'.old']);
    end
end

end