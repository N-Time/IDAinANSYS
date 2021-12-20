fclose('all'); % �������ڴ��ļ�

% load LA4_IDA_Sa2PGA % load the increment of LA40 IDA
% ��ʼ��ʾ
time_total_start = datetime('now');
disp(['======',' START TIME ','======']);
disp(time_total_start);
% ����
record_folder = 'D:\Wen\Research\MAS\PEER\la01-40\PlusFV';  % �����ļ���
working_main_path = 'E:\ANSYS\test';  % ANSYS������Ŀ¼����ͬ���𶯹��������������ļ���
mac_path = 'D:\ansys\Eq_Subgrade_S-S_HSRB\MAS_Eq_Subgrade_HSRB_NLTHA_5.0\mac';  % ԭ.mac�ļ�Ŀ¼��
% ����ʱ���Զ����Ƶ��´����Ĺ�������Ŀ¼�ڣ��ٸ��ݹ����޸�.mac
scalar = 0.5; % ����ϵ����1Ϊ������

%%% ���𶯼�¼�б�
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
% ѭ��ִ���б��еĵ��𶯹���

for rc = 1:1:2 % ����ǰ2��
    % re = 1:1:size(record_list,1) % �ļ��������е���
    
    %%% SAMPLING property of records ��������
    [~, dt, npts, ~] = getAmpDtPEER(record_folder, record_list{rc});
    
    %%% SCALAR ѭ��ִ�����е���
    for sc = 1: 1: size(scalar,2)
        scalar_start_time = datetime('now');
        %%% CALL ANSYS ����ANSYS
        errorInfo = ANSYSbatch(working_main_path,mac_path,...  % ANSYS��Ŀ¼��ԭ.mac�ļ�Ŀ¼
            record_folder,record_name{rc},record_dir{rc},scalar(sc),dt,npts,'retrieved');
        % ����Ŀ¼�������������ݼ�¼�б��룩�����𶯷��򣨽���Ϊ��ѡȡ���𶯷���ı�ǣ��������÷������÷���Ĭ��˳����
        % ����ϵ����dt���𶯲��������npts�����������������������Զ�ץȡ����
        % ������save_label =
        % 'retrieved'��ʾ����ȡANSYS����ļ�������������ANSYSԭʼģ�ͼ�ʱ�����ݣ��Խ�Լ����ռ�
        
        % Output Error info, if it exists  % ������ܵĴ���
        if ~isempty(errorInfo)
            disp(errorInfo);
        end
        
        %%% ALERT of finishing  ��һ��������������
        load chirp   % Sound chirp after ansys finished
        sound(y,Fs)
        % ��һ����������ʾ
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
% ���й���������ʾ
disp(['====== ',num2str(rc),' scalars ground motions is FINISHED !']);

time_total_end = datetime('now');
disp(['======',' END TIME ','======']);
disp(time_total_end);
disp(['======',' TOTAL COST ','======']);
disp(time_total_end - time_total_start);