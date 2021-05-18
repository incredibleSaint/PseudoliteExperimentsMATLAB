% clc;
% clear;
% close all;
function Res = MainExp(FName, sv_id)
%% ��������� ����� ���������� ����������
    % ����� ���������, � ������� ���� ������ ���������� Main
        StartProcNum = 1; %  1 <= StartProcNum <= length(FuncNames)

    % ����� ���������, �� ������� ���� ��������� ���������� Main
        StopProcNum = 2; %  1 <= StopProcNum <= length(FuncNames) �
            % StartProcNum <= StopProcNum

	% �����  ���� ��������� - ��������������� ��� StartProcNum = 1, �����
	%   �� ���� �������� ��������� � ����������
    % 'Coh'/'NonCoh' - ����������� ��������� / ������������� ���������
        if StartProcNum == 1
            ProcessType = 'Coh'; % 'NonCoh'
        end

    % ���� ������������� ���������� �����������
        isDraw =1; % 0 - �� ��������; 1 - ��������; 2 - �������� �
            % ���������; 3 - ��������, ��������� � ���������

    % ����� ����� �����-������
        Case = 4;
        % ���������� � �������-��������
        
%             switch Case
%                 case 1
%                     DirName = 'D:\Signals\Signals\';
%                 case 2
%                     DirName = 'C:\SIGNALS\Nav\';
%                 case 3
%                     DirName = 'D:\Signals\Signals\DifRates_31082018\';
%                 case 4
%                     DirName = 'E:\GIT\SpatialProcessing\'; % _Records\6-chan 17-04\';
%             end
%         % ��� �����-������
%             switch Case
%                 case 1
%                     FName = 'FarFazenda_18_27.dat';
%                 case 2
%                     FName = 'FarFazenda__2MHz__18_27.dat';
%                 case 3
%                     FName = '30_08_2018__19_38_33_x02_1ch_16b_15pos_90000ms.dat';
%                     
%                 case 4
%                     FName = 'Rec_31_05_2019_t11-44-07.dat'; %'17_04_2019__14_13_55_x02_6ch_16b_15pos_2000ms.dat';
%             end
 
        % ������ ��� �����-������        
%             [FName, DirName] = uigetfile({'*.dat'},'Select Record File');
%             FName = [DirName, FName];

            Dir = [cd '\Records\'];
            
            Name = '2021_5_12_19_21_11_CN0_80_int16_SamplFreq_4_Sv_2ByteShiftToFindSat100%_24396372_0  0  0.dat';
%             FName = [Name];

    % ��� ����� ��� �������� �����������
    % ���� StartProcNum = 1, �� �� ���� ������ ���������
        if StartProcNum >= 1
            LoadFileName = 'LoadName';
        end


    % ��� ����� ��� ���������� �����������
        SaveFileName = 'SaveName';

%% ��������� ����� ���������� ����������
    if StartProcNum == 1
        % ��������� ��������� �����-������ - �������� ����� ��. �
        % ReadSignalFromFile
            File = struct( ...
                'Name',           FName, ...
                'HeadLenInBytes', 0, ... %
                'NumOfChannels',  1, ... %1
                'ChanNum',        0, ... %0
                'DataType',       'int16', ...
                'Fs0',            2.046*10^6, ...
                'dF',             0, ...
                'FsDown',         1, ...
                'FsUp',           1 ...
            );
    end

    % ����� �������, ����������� ��������� ������� �/��� ���������� ��
    % ������� ������
        AllFuncNames = { ...
            { ... % ����� ������� ��� ����������� ���������
                'P10_CohSearchSats', ...
                'P20_CohTrackSatsAndBitSync', ...
                'P30_CohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            }, ...
            { ... % ����� ������� ��� ������������� ���������
                'P10_NonCohSearchSats', ...
                'P20_NonCohTrackSatsAndBitSync', ...
                'P30_NonCohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            } ...
        };

%% ���������������� �����
    % ������ ��������� ����� File
        if StartProcNum == 1
            % ��������� ����� �����-������ � ��������
                [~, File] = ReadSignalFromFile(File, 0, 0);

            % ��������� ����������� ����������������� �� ��������� �
            % ���������� �������� GPS
                File.R = round(File.Fs / (1.023*10^6));
        end

    % �������������� ��� �������� ���������-���������
        if StartProcNum == 1 % �������������
            Res = struct( ...
                'ProcessType',  ProcessType, ...
                'File',         File, ...
                'LoadFileName', 'none', ...
                'SaveFileName', SaveFileName, ...
                'Search',       [], ...
                'Track',        [], ...
                'BitSync',      [], ...
                'Demod',        [], ...
                'SubFrames',    [], ...
                'SatsData',     [], ...
                'Ephemeris',    [], ...
                'Positioning',  [] ...
            );
        else % ��������
            load(LoadFileName, 'Res');
            Res.LoadFileName = LoadFileName;
        end

    % �������� ���������� ����� �����, ���������� � Main (����) �
    % ������������ ������ � ������������
        if StartProcNum > 1
            if ~isequal(Res.File.Name, FName)
                Btn = questdlg(['��������� ��� ������� ��� ����� �� ', ...
                    '��������� � ������, ���������� � ����������� ', ...
                    '�����������! ������������ ����� ��� ����� ', ...
                    '������, ���� ��������� �������������� ����� ', ...
                    '�/��� ����������� ��� � ������ ����������.'], ...
                    '��������!', '������������ ���������� ���', ...
                    '������������ ����� ���', '������ ����������', ...
                    '������ ����������');
                if isequal(Btn, '������������ ���������� ���')
                    % ������ �� ���� ������!
                elseif isequal(Btn, '������������ ����� ���')
                    Res.File.Name = FName;
                elseif isequal(Btn, '������ ����������')
                    return
                end
            end
        end

    % ����� �������, ����������� ��������� ������� �/��� ���������� ��
    % ������� ������
        if isequal(Res.ProcessType, 'Coh')
            FuncNames = AllFuncNames{1};
        else
            FuncNames = AllFuncNames{2};
        end
        
        Params = struct(...
                        'sv_id', sv_id);
%% �������� �������� ����������
    if ~((StartProcNum >= 1) && (StartProcNum <= length(FuncNames)))
        fprintf(['������ ����������� ������� ����������� ', ...
            '1 <= StartProcNum <= length(FuncNames)!\n������ Main ', ...
            '����������.\n'])
        return
    end

    if ~((StopProcNum >= 1) && (StopProcNum <= length(FuncNames)))
        fprintf(['������ ����������� ������� ����������� ', ...
            '1 <= StopProcNum <= length(FuncNames)!\n������ Main ', ...
            '����������.\n'])
        return
    end

    if ~(StartProcNum <= StopProcNum)
        fprintf(['������ ����������� ����������� ', ...
            'StartProcNum <= StopProcNum!\n������ Main ����������.\n'])
        return
    end
    
    if ~(isequal(isDraw, 0) || isequal(isDraw, 1) || ...
            isequal(isDraw, 2) || isequal(isDraw, 3))
        fprintf(['�������� isDraw ������ ���� ����� �� ', ...
            '(0, 1, 2)!\n������ Main ����������.\n'])
        return
    end
    
    if ~(isequal(Res.ProcessType, 'Coh') || ...
            isequal(Res.ProcessType, 'NonCoh'))
        fprintf(['�������� ProcessType ������ ���� ����� �� ', ...
            '(Coh, NonCoh)!\n������ Main ����������.\n'])
        return
    end

%% �������� �����
    % �� ������� �������� ��� ����������� ���������
        for k = StartProcNum : StopProcNum
            % �������� ��������� �� ������ �������
                Fun = str2func(FuncNames{k});
            % �������� ������� � ����������� Res
                Res = Fun(Res, isDraw, Params);
            % �������� ������� ����������
            % � ������������� ������� �������� (P10_, P20_) �������������
            % ������ �������������� ���������� ��� �������
                save(SaveFileName, 'Res');
                save(LoadFileName, 'Res');
        end