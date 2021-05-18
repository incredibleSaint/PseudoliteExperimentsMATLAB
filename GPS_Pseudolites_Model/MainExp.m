% clc;
% clear;
% close all;
function Res = MainExp(FName, sv_id)
%% УСТАНОВКА ЧАСТО ИЗМЕНЯЕМЫХ ПАРАМЕТРОВ
    % Номер процедуры, с которой надо начать выполнение Main
        StartProcNum = 1; %  1 <= StartProcNum <= length(FuncNames)

    % Номер процедуры, на которой надо закончить выполнение Main
        StopProcNum = 2; %  1 <= StopProcNum <= length(FuncNames) и
            % StartProcNum <= StopProcNum

	% Выбор  типа обработки - устанавливается для StartProcNum = 1, чтобы
	%   не быть случайно изменённым в дальнейшем
    % 'Coh'/'NonCoh' - когерентная обработка / некогерентная обработка
        if StartProcNum == 1
            ProcessType = 'Coh'; % 'NonCoh'
        end

    % Флаг необходимости прорисовки результатов
        isDraw =1; % 0 - не рисовать; 1 - рисовать; 2 - рисовать и
            % сохранять; 3 - рисовать, сохранять и закрывать

    % Выбор имени файла-записи
        Case = 4;
        % Директория с файлами-записями
        
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
%         % Имя файла-записи
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
 
        % Полное имя файла-записи        
%             [FName, DirName] = uigetfile({'*.dat'},'Select Record File');
%             FName = [DirName, FName];

            Dir = [cd '\Records\'];
            
            Name = '2021_5_12_19_21_11_CN0_80_int16_SamplFreq_4_Sv_2ByteShiftToFindSat100%_24396372_0  0  0.dat';
%             FName = [Name];

    % Имя файла для загрузки результатов
    % Если StartProcNum = 1, то не надо ничего загружать
        if StartProcNum >= 1
            LoadFileName = 'LoadName';
        end


    % Имя файла для сохранения результатов
        SaveFileName = 'SaveName';

%% УСТАНОВКА РЕДКО ИЗМЕНЯЕМЫХ ПАРАМЕТРОВ
    if StartProcNum == 1
        % Определим структуру файла-записи - описание полей см. в
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

    % Имена функций, выполняющих обработку сигнала и/или полученных из
    % сигнала данных
        AllFuncNames = { ...
            { ... % Имена функций для когерентной обработки
                'P10_CohSearchSats', ...
                'P20_CohTrackSatsAndBitSync', ...
                'P30_CohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            }, ...
            { ... % Имена функций для некогерентной обработки
                'P10_NonCohSearchSats', ...
                'P20_NonCohTrackSatsAndBitSync', ...
                'P30_NonCohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            } ...
        };

%% ПОДГОТОВИТЕЛЬНАЯ ЧАСТЬ
    % Расчёт некоторых полей File
        if StartProcNum == 1
            % Определим длину файла-записи в отсчётах
                [~, File] = ReadSignalFromFile(File, 0, 0);

            % Определим коэффициент передискретизации по отношению к
            % символьной скорости GPS
                File.R = round(File.Fs / (1.023*10^6));
        end

    % Инициализируем или загрузим структуру-результат
        if StartProcNum == 1 % Инициализация
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
        else % Загрузка
            load(LoadFileName, 'Res');
            Res.LoadFileName = LoadFileName;
        end

    % Проверка совпадения имени файла, указанного в Main (выше) и
    % загруженного вместе с результатами
        if StartProcNum > 1
            if ~isequal(Res.File.Name, FName)
                Btn = questdlg(['Указанное при запуске имя файла не ', ...
                    'совпадает с именем, сохранённым в загруженных ', ...
                    'результатах! Использовать новое имя можно ', ...
                    'только, если произошло переименование файла ', ...
                    'и/или перемещение его в другую директорию.'], ...
                    'Внимание!', 'Использовать сохранённое имя', ...
                    'Использовать новое имя', 'Отмена выполнения', ...
                    'Отмена выполнения');
                if isequal(Btn, 'Использовать сохранённое имя')
                    % ничего не надо делать!
                elseif isequal(Btn, 'Использовать новое имя')
                    Res.File.Name = FName;
                elseif isequal(Btn, 'Отмена выполнения')
                    return
                end
            end
        end

    % Имена функций, выполняющих обработку сигнала и/или полученных из
    % сигнала данных
        if isequal(Res.ProcessType, 'Coh')
            FuncNames = AllFuncNames{1};
        else
            FuncNames = AllFuncNames{2};
        end
        
        Params = struct(...
                        'sv_id', sv_id);
%% ПРОВЕРКИ ЗНАЧЕНИЙ ПАРАМЕТРОВ
    if ~((StartProcNum >= 1) && (StartProcNum <= length(FuncNames)))
        fprintf(['Должно выполняться двойное неравенство ', ...
            '1 <= StartProcNum <= length(FuncNames)!\nРабота Main ', ...
            'прекращена.\n'])
        return
    end

    if ~((StopProcNum >= 1) && (StopProcNum <= length(FuncNames)))
        fprintf(['Должно выполняться двойное неравенство ', ...
            '1 <= StopProcNum <= length(FuncNames)!\nРабота Main ', ...
            'прекращена.\n'])
        return
    end

    if ~(StartProcNum <= StopProcNum)
        fprintf(['Должно выполняться неравенство ', ...
            'StartProcNum <= StopProcNum!\nРабота Main прекращена.\n'])
        return
    end
    
    if ~(isequal(isDraw, 0) || isequal(isDraw, 1) || ...
            isequal(isDraw, 2) || isequal(isDraw, 3))
        fprintf(['Значение isDraw должно быть одним из ', ...
            '(0, 1, 2)!\nРабота Main прекращена.\n'])
        return
    end
    
    if ~(isequal(Res.ProcessType, 'Coh') || ...
            isequal(Res.ProcessType, 'NonCoh'))
        fprintf(['Значение ProcessType должно быть одним из ', ...
            '(Coh, NonCoh)!\nРабота Main прекращена.\n'])
        return
    end

%% ОСНОВНАЯ ЧАСТЬ
    % По очереди выполним все необходимые процедуры
        for k = StartProcNum : StopProcNum
            % Создадим указатель на нужную функцию
                Fun = str2func(FuncNames{k});
            % Выполним функцию и перезапишем Res
                Res = Fun(Res, isDraw, Params);
            % Сохраним текущие результаты
            % В вычислительно сложных функциях (P10_, P20_) рекомендуется
            % делать дополнительные сохранения для отладки
                save(SaveFileName, 'Res');
                save(LoadFileName, 'Res');
        end