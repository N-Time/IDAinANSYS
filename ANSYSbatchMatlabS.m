fclose('all'); % 清理已内存文件

% load LA4_IDA_Sa2PGA % load the increment of LA40 IDA
% 开始提示
time_total_start = datetime('now');
disp(['======',' START TIME ','======']);
disp(time_total_start);
% 输入
record_folder = 'D:\Wen\Research\MAS\PEER\la01-40\PlusFV';  % 地震动文件夹
working_main_path = 'E:\ANSYS\test';  % ANSYS主工作目录，不同地震动工况将单独创建文件夹
mac_path = 'D:\ansys\Eq_Subgrade_S-S_HSRB\MAS_Eq_Subgrade_HSRB_NLTHA_5.0\mac';  % 原.mac文件目录，
% 计算时将自动复制到新创建的工况工作目录内，再根据工况修改.mac
scalar = 0.5; % 调幅系数，1为不调幅

%%% 地震动记录列表
record_list = getFolderList(record_folder); % get all records list
record_dir = {};   % get all records direction list
for rd = 1: size(record_list,1)
    record_dir{rd, 1} = record_list{rd}(end-6:end-4);
    record_name{rd, 1} = record_list{rd}(1:end-4);
end

% %%% Parallel computing: rc_par = 141.191970; s for = 144.957438 s
% if isempty(gcp('nocreate'))
%     parpool;
% end

%%% RECORDS
% 循环执行列表中的地震动工况

for rc = 1:1:2 % 试算前2条
    % re = 1:1:size(record_list,1) % 文件夹中所有地震动
    
    %%% SAMPLING property of records 地震动性质
    [~, dt, npts, ~] = getAmpDtPEER(record_folder, record_list{rc});
    
    %%% SCALAR 循环执行所有调幅
    for sc = 1: 1: size(scalar,2)
        scalar_start_time = datetime('now');
        %%% CALL ANSYS 调用ANSYS
        errorInfo = ANSYSbatch(working_main_path,mac_path,...  % ANSYS主目录，原.mac文件目录
            record_folder,record_name{rc},record_dir{rc},scalar(sc),dt,npts,'retrieved');
        % 地震动目录，地震动名（根据记录列表导入），地震动方向（仅作为所选取地震动方向的标记，并非作用方向，作用方向默认顺桥向）
        % 调幅系数，dt地震动采样间隔，npts采样数（这两项在上面已自动抓取），
        % 保存标记save_label =
        % 'retrieved'表示仅提取ANSYS输出的计算结果，不保留ANSYS原始模型及时程数据，以节约储存空间
        
        % Output Error info, if it exists  % 输出可能的错误
        if ~isempty(errorInfo)
            disp(errorInfo);
        end
        
        %%% ALERT of finishing  单一工况结束提醒音
        load chirp   % Sound chirp after ansys finished
        sound(y,Fs)
        % 单一工况结束提示
        scalar_end_time = datetime('now');
        disp(['------',' Current time is:']);
        disp(scalar_end_time);
        disp('------ Cost time of this step is:');
        disp(scalar_end_time - scalar_start_time);
        
        %%% SUSPEND as the occurrence of non-convergence
        %if ~isempty(error_info)
            %break                % break the loop of scalars when errors occur
        %end
    end
end
% 所有工况结束提示
disp(['====== ',num2str(rc),' scalars ground motions is FINISHED !']);

time_total_end = datetime('now');
disp(['======',' END TIME ','======']);
disp(time_total_end);
disp(['======',' TOTAL COST ','======']);
disp(time_total_end - time_total_start);