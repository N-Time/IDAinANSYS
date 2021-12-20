% Call the ANSYS batch via .mac for analysis in batch

% Input
% working_main_path = ansys working path
% mac_path = path of the main .mac file
% record_path = path of records
% record_name = ground motion records name at the coresponding path at my_read_wave.mac
% record_dir = record direction
% scalar = scaling factor
% DT = sampling time iteration of the record
% NPTS = the total of sampling poiont
% save_label = the result-save way: 'retrieved' - only retrieved time
% history at TimeHistory folder; default - save all output files from ANSYS

% e.g.
% record_folder = 'D:\Wen\Research\MAS\PEER\FEMA_p695\Far-Field_Record\Normalized';
% working_main_path = 'E:\ANSYS\MAS_IDA';
% mac_path = 'D:\ansys\Eq_Subgrade_SimpleSuppport_HSRB\MAS_Eq_Subgrade_HSRB_NLTHA_5.0\mac';
% record_path = 'D:\Wen\Research\MAS\PEER\FEMA_p695\Far-Field_Record\PlusFV';
% record_name = 'RSN68_SFERN_PEL090';
% record_dir = '090';
% scalar = 0.01;
% DT = 0.01;
% NPTS = 1991;
% save_label = 'retrieved'


function error_info = ANSYSbatch(working_main_path,mac_path,...
    record_path,record_name,record_dir,scalar,DT,NPTS,save_label)
    % Build a working folder for the record
    record_rsn = record_name;
    record_rsn_dir = record_dir;
    working_path = [working_main_path, '\', record_rsn, '\', num2str(scalar)];
    folderCheck(working_path);   % Check the fold, if it does not exist, built it.
    folderCheck([working_path, '\', 'TimeHistory']);   % Build the time history output folder

    %%% COPY .mac to the record working folder
    mac_list = getFolderList(mac_path);
    for i = 1: 1: size(mac_list,1)
        mac_file = [mac_path, '\', mac_list{i}];
        copyfile(mac_file,working_path);
    end
    
    %%% CHNAGE the record path for my_read_wave.mac
    origin_record_path = 'D:\Wen\Research\MAS\PEER\FEMA_p695\Far-Field_Record\Normalized';
    path_line = [6;12;15;21;24;27];
    for i = 1:1:size(path_line,1)
        editTextInLine(working_path,'my_read_wave.mac',path_line(i),origin_record_path,record_path);
    end
    
    %%% CHANGE the record name, direction and scalar at the input_gm_0.mac
    % record name at the 4th line of input_gm_0.mac
    editTextInLine(working_path,'input_gm_0.mac',4,'gm',record_rsn);

    % record direction at the 5th line of input_gm_0.mac
    editTextInLine(working_path,'input_gm_0.mac',5,'dirc',record_rsn_dir);

    % scalar at the 10th line of input_gm_0.mac
    editTextInLine(working_path,'input_gm_0.mac',10,'0.05',num2str(scalar));   % sc
    editTextInLine(working_path,'input_gm_0.mac',11,'0.05',num2str(scalar));   % scalar
    
    % dt and npts at the 14th and 15nd line of input_gm_0.mac
    editTextInLine(working_path,'input_gm_0.mac',14,'0.01',num2str(DT));   % dt
    editTextInLine(working_path,'input_gm_0.mac',15,'1991',num2str(NPTS));   % npts   
    
    %%% CHANGE the main path of .mac files
    originMainPath = 'E:\ANSYS\MAS_IDA';
    % Retrieve_Beam_THD.mac
    renameMac = 'Retrieve_Beam_THD.mac';
    path_line = [33;59;85;111];
    for i = 1:1:size(path_line,1)
        editTextInLine(working_path,renameMac,path_line(i),originMainPath,working_main_path);
    end
    % Retrieve_Node_Number.mac
    renameMac = 'Retrieve_Node_Number.mac';
    path_line = (18:5:63)';
    for i = 1:1:size(path_line,1)
        editTextInLine(working_path,renameMac,path_line(i),originMainPath,working_main_path);
    end
    % Retrieve_Pier_THD.mac
    renameMac = 'Retrieve_Pier_THD.mac';
    path_line = [41];
    for i = 1:1:size(path_line,1)
        editTextInLine(working_path,renameMac,path_line(i),originMainPath,working_main_path);
    end
    % Retrieve_Support_THD.mac
    renameMac = 'Retrieve_Support_THD.mac';
    path_line = [32;62];
    for i = 1:1:size(path_line,1)
        editTextInLine(working_path,renameMac,path_line(i),originMainPath,working_main_path);
    end
    % my_read_node.mac
    renameMac = 'my_read_node.mac';
    path_line = [(14:2:20)';23;25];
    for i = 1:1:size(path_line,1)
        editTextInLine(working_path,renameMac,path_line(i),originMainPath,working_main_path);
    end
    
    %%% ANSYS batch
    % "C:\Program Files\ANSYS Inc\v192\ansys\bin\winx64\MAPDL.exe"...
    %     -p ansys...
    %     -np 24....
    %     -lch...
    %     -dir "E:\ANSYS\MAS_IDA\SC_100_v2_R_R_S_228_318"...
    %     -j "SC_100_v2_R_R_S_228_318" -s read -l en-us -b...
    %     -i "E:\ANSYS\MAS_IDA\SC_100_v2_R_R_S_228_318\file.dat"...
    %     -o "E:\ANSYS\MAS_IDA\SC_100_v2_R_R_S_228_318\file.out"

    % "C:\Program Files\ANSYS Inc\v192\ansys\bin\winx64\MAPDL.exe"  -p ansys -np 24 -lch -dir "E:\ANSYS\MAS_IDA\test" -j "test" -s read -l en-us -b -i "E:\ANSYS\MAS_IDA\test\file.dat" -o "E:\ANSYS\MAS_IDA\test\file.out"


    % ansys exe, if there is any blank spaces, "" are needed.
    ansys_path = strcat('C:\Program Files\ANSYS Inc\v192\ansys\bin\winx64\MAPDL.exe');
    % cpu core
    np = '24';
    % jobname without suffix
    jobname = strcat('SC_', num2str(scalar), '_', record_rsn);
    % Change the job name at the resume line
    editTextInLine(working_path,'analysis_aftershock.mac',9,'sc',jobname);
    % analysis_MAS.mac for directly running at ansys
    input_mac = strcat(working_path, '\', 'analysis_MAS.mac');
    % output file with suffix .out, including running information.
    output_file = strcat(working_path, '\', 'ans.out');
    
    disp(['===>>> The current analysis is ',record_rsn,' - ',num2str(scalar),' ......']);
    % string of the call ansys, 32 = a blank space in ASCII
    sys_char = strcat('SET KMP_STACKSIZE=2048k &',32,'"',ansys_path,'"',32,...
        '-p ansys',32, '-np ',32, np, 32,'-lch',32,...
        '-dir',32,'"',working_path,'"',32,...
        '-j',32,'"',jobname,'"',32,'-s read  -m 5000 -db 1000 -l en-us -b',32,...
        '-i',32,'"',input_mac,'"',32,...
        '-o',32,'"',output_file,'"');

    % call ANSYS
    analysis = system(sys_char);
    
    %%% Output the error information
    error_info = outputANSYSerror(working_path,jobname);    % Get error information at the error file
    
    %%% Copy the output result files and Delet other files
    if  strcmp(save_label, 'retrieved')
        copy_to_path = [working_main_path, '\', record_rsn, '\Results\', num2str(scalar)];
        copy_file_ext = {'.out'; '.err'; '.log'; '.txt'; '.mac'};   % the suffix of the files want to copy
        for i = 1:size(copy_file_ext,1)
            copyFolderFileType(working_path,copy_to_path,copy_file_ext{i});
        end
        time_history_result = [working_path, '\TimeHistory'];    % copy the time history result folder
        copyfile(time_history_result,[copy_to_path, '\TimeHistory']);
        if exist(working_path) ~= 0    % Delet other files, especially the .rst which takes up lots of space
            rmdir(working_path,'s');
        end
    end
    
    %%% SHOW the finishing reminder
    disp(['===||| ',record_rsn,' with scalar = ',num2str(scalar),' is finished.']);
    
end