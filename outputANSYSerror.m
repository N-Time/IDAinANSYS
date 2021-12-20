% Output the error information from an ANSYS result
% 
% Input
% FileFolder = the working path of ansys
% FileName = the job name at ansys or the error file without .err
% 
% e.g.
% FileFolder = 'E:\ANSYS\MAS_IDA\FV_RSN1111_KOBE_NIS000\Results\1';
% FileName = 'SC_1_FV_RSN1111_KOBE_NIS000';


function PrintStr = outputANSYSerror(FileFolder,FileName)
    fid = fopen([FileFolder,'\',FileName,'.err'], 'r');
    string_data = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);

    NumError = 0;
    for i = 1:1:size(string_data{1},1)       % Read each line at error file
        if ~isempty(string_data{1,1}{i,1})   % Read the non-empty line
            if strcmp(string_data{1,1}{i,1}(1:13), '*** ERROR ***')    % Decide the error line
                NumError = NumError + 1;     % Count the number of errors
                for j = NumError:1:NumError+3      % Write the error information after ERROR 3 lines
                    PrintStr{j,1} = string_data{1,1}{i+j-1,1};
                end
            end
        end
    end
    
    if NumError == 0        % If there is not any errors, the result is an empty cell
        PrintStr = {};
    end
        
end