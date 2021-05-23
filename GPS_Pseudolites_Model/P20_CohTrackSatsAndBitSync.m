function Res = P20_CohTrackSatsAndBitSync(inRes, isDraw, Params)
%
% Функция когерентного трекинга спутников и битовой синхронизации
%
% Входные переменные
%   inRes - структура с результатами модели, объявленная в Main;
%   isDraw - 0/1/2/3 флаг необходимости прорисовки результатов выполнения
%       данной функции.
%
% Выходные переменные
%   Res - структура, которая отличается от inRes добавлением нового поля,
%       описание которого дано ниже в коде.

% Пересохранение результатов
    Res = inRes;

%% ИНИЦИАЛИЗАЦИЯ РЕЗУЛЬТАТА
    Track = struct( ...
        'SamplesShifts',     {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',           {cell(Res.Search.NumSats, 1)}, ...
        'HardSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'FineSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'EPLCorVals',        {cell(Res.Search.NumSats, 1)}, ...
        'DLL',               {cell(Res.Search.NumSats, 1)}, ...
        'FPLL',              {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждая ячейка cell-массивов SamplesShifts, CorVals, HardSamplesShifts
    %   FineSamplesShifts является массивом 1xN, где N - количество
    %   периодов CA-кода соответствующего спутника, найденных в файле-
    %   записи (N может быть разным для разных спутников).
    % Каждый элемент массива SamplesShifts{k} - дробное количество
    %   отсчётов, которые надо пропустить в файле-записи до начала
    %   соответствующего периода CA-кода.
    % Каждый элемент массива CorVals{k} - комплексное значение корреляции
    %   части сигнала, содержащей соответствующий период CA-кода, с опорным
    %   сигналом.
    % Каждый элемент массивов HardSamplesShifts{k}, FineSamplesShifts{k} -
    %   соответственно дробная и целая части значений SamplesShifts{k}.
    % Каждая ячейка cell-массива EPLCorVals является массивом 3xN значений
    %   Early, Promt и Late корреляций. При этом: SamplesShifts{k} =
    %   EPLCorVals{k}(2, :).
    % DLL, FPLL - лог сопровождения фазы кода и частоты-фазы сигнала.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % Каждый элемент массива CAShifts - количество периодов CA-кода,
    %   которые надо пропустить до начала бита.
    % Каждая строка массива Cors - корреляции, по позиции минимума которых
    %   определяется битовая синхронизация.

%% УСТАНОВКА ПАРАМЕТРОВ
    % Порядок фильтров
        DLL.FilterOrder = 2;
        FPLL.FilterOrder = [2, 3];%[2, 3]; %[1, 2];   
        
    % И DLL и FPLL имеют несколько режимов работы для каждого из них нужно
    % определить
        % Полосы фильтров
%             DLL.FilterBands  = [0.05; 0.05; 0.05; 0.05];
%             FPLL.FilterBands = [ ...
%                 5, 5; ...
%                 2.5, 2.5; ...
%                 1, 1; ...
%                 0.2, 0.2];

%             DLL.FilterBands  = [0.05];
%             FPLL.FilterBands = [ ...
%                 5, 5; ...
%                 5, 5; ...
%                 5, 5; ...
%                 2, 2];
            DLL.FilterBands  = [0.05];
            FPLL.FilterBands = [ ...
                    5, 5; ...
                    5, 5; ...
                    5, 5; ...
                    2, 2];
            
        % Количество периодов накопления для фильтрации
            DLL.NumsIntCA  = [4, 10, 20, 20];
            FPLL.NumsIntCA = [4, 10, 20, 20];

	% Определим количество периодов CA-кода, учитываемых для проверки
	% необходимости перехода между состояниями DLL и FPLL. Проверка
	% работает по принципу integrate and dump
        DLL.NumsCA2CheckState  = [100, 100, 100, 100];
        FPLL.NumsCA2CheckState = [100, 100, 100, 100];
        
    % Граничные значения для перехода между состояниями
    % Если значение > HiTr, то переходим в следующее (более робастное)
    %   состояние
    % Если значение < LoTr, то переходим в предыдущее (более
    %   чувствительное)состояние
        DLL.HiTr = [0.5 0.5 0.5 0.5];
        DLL.LoTr = [0.1 0.1 0.1 0.1];
        
        FPLL.HiTr = [0.5 0.5 0.5 0.5];
        FPLL.LoTr = [0.1 0.1 0.1 0.1];
        
    % Граничные значения для перехода между состояниями
    % Если значение > HiTr, то переходим в следующее (более робастное)
    %   состояние
    % Если значение < LoTr, то переходим в предыдущее (более
    %   чувствительное)состояние
        DLL.HiTr = [0.5 0.5 0.5 0.5];
        DLL.LoTr = [0.1 0.1 0.1 0.1];
        
        FPLL.HiTr = [0.5 0.5 0.5 0.5];
        FPLL.LoTr = [0.1 0.1 0.1 0.1];

    % Период, с которым производится отображение числа обработанных
    % CA-кодов
        NumCA2Disp = 5*10^3;

    % Максимальное число обрабатываемых CA-кодов (inf - до конца файла!)
        MaxNumCA2Process = inf; % inf;

    % Количество бит, используемых для битовой синхронизации
        NBits4Sync = 100;

%% СОХРАНЕНИЕ ПАРАМЕТРОВ
    % Track.FPLL = FPLL; % не нужно, так как всё равно будет сделано в
    % Track.DLL = DLL;   % конце
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Длина CA-кода с учётом частоты дискретизации
        CALen = 1023 * Res.File.R;

    % Количество периодов CA-кода, приходящихся на один бит
        CAPerBit = 20;

    % Длительность CA-кода, мс
        TCA = 10^-3;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ТРЕКИНГ И БИТОВАЯ СИНХРОНИЗАЦИЯ
    % Строка состояния
        fprintf('%s Трекинг спутников и битовая синхронизация\n', ...
            datestr(now));
    for k = 1:Res.Search.NumSats
        % Строка состояния
            fprintf('%s     Для спутника №%02d (%d из %d) ...\n', ...
                datestr(now), Res.Search.SatNums(k), k, ...
                Res.Search.NumSats);

        % Сформируем CA-код
            CA = GenCACode(Res.Search.SatNums(k));

        % Выполним модуляцию
            CA = 2*CA-1;

        % Увеличим частоту дискретизации
            CA = reshape(repmat(CA, Res.File.R, 1), 1, CALen);

        % Вытащим значение синхронизации по времени
            HardSamplesShift = Res.Search.SamplesShifts(k);
            
        % Убедимся, что мы сможем получить Early
            if HardSamplesShift - 1 < 0
                HardSamplesShift = HardSamplesShift + CALen;
            end

        % Вытащим начальное значение синхронизации по частоте
            FreqShift = Res.Search.FreqShifts(k);

        % Определим максимальное число периодов CA-кода, для которых будет
        % осуществлён трекинг
            MaxNumCA = ceil((Res.File.SamplesLen - HardSamplesShift) / ...
                (CALen - 1));
            
        % Выделим память под результат обработки
            SamplesShifts     = zeros(1, MaxNumCA);
            CorVals           = zeros(1, MaxNumCA);
            HardSamplesShifts = zeros(1, MaxNumCA);
            FineSamplesShifts = zeros(1, MaxNumCA);
            EPLCorVals        = zeros(3, MaxNumCA);

        % Инициализация NCO и NCOStep
            DLL.NCO     = 0;
            DLL.NCOStep = 0;
            
            FPLL.NCO     = 1;
            FPLL.NCOStep = 2*pi*FreqShift/Res.File.Fs;
            
        % Инициализация состояния синхронизации DLL и FPLL
            DLL.isSync  = 0;
            FPLL.isSync = 0;

        % Инициализация номера состояния DLL и FPLL    
            DLL.State  = 1;
            FPLL.State = 1;

        % Определим текущие количества накоплений
            DLL.NumIntCA  = DLL.NumsIntCA(DLL.State);
            FPLL.NumIntCA = FPLL.NumsIntCA(FPLL.State);

        % Инициализация номеров CA, в которые произошла последня смена
        % состояния. Эти значения не актуальны до тех пор, пока не будет
        % выполнена битовая синхронизация.
            DLL.PosCAStateChanged = 0;
            FPLL.PosCAStateChanged = 0;
            
        % Подготовим фильтры
            DLLFilter = ClassFilter();
            DLLFilter.PrepareFilter(DLL.FilterOrder, DLL.FilterBands(...
                DLL.State, :), TCA*DLL.NumIntCA, 0, 0);

            FPLLFilter = ClassFilter();
            FPLLFilter.PrepareFilter(FPLL.FilterOrder, FPLL.FilterBands(...
                FPLL.State, :), TCA*FPLL.NumIntCA, -FreqShift*2*pi, 0);

        % Инициализация результатов работы фильтров
            DLL.Discrs    = zeros(1, MaxNumCA);
            DLL.Outputs   = zeros(1, MaxNumCA);
            DLL.VelocAccs = zeros(1, MaxNumCA);
            DLL.AccelAccs = zeros(1, MaxNumCA);
            DLL.NCOs      = zeros(1, MaxNumCA);
            DLL.NCOSteps  = zeros(1, MaxNumCA);
            DLL.States    = zeros(1, MaxNumCA);
            DLL.isSyncs   = zeros(1, MaxNumCA);
            
            FPLL.FLLDiscrs = zeros(1, MaxNumCA);
            FPLL.PLLDiscrs = zeros(1, MaxNumCA);
            FPLL.Outputs   = zeros(1, MaxNumCA);
            FPLL.VelocAccs = zeros(1, MaxNumCA);
            FPLL.AccelAccs = zeros(1, MaxNumCA);
            FPLL.NCOs      = zeros(1, MaxNumCA);
            FPLL.NCOSteps  = zeros(1, MaxNumCA);
            FPLL.States    = zeros(1, MaxNumCA);
            FPLL.isSyncs   = zeros(1, MaxNumCA);

        % Инициализируем счётчик обработанных периодов CA-кода
            CACounter = 0;

        % Инициализации для битовой синхронизации
            % Инициализация флага выполнения битовой синхронизации
                BitSync.isDone = 0;

            % Инициализация массива для накопления (сохранения) значений
            % корреляции с CA-кодами, по которым будет выполнена битовая
            % синхронизация
                BitSync.Ps = zeros(1, CAPerBit*NBits4Sync + 1);

            % Счётчик числа сохранённых в BitSync.Ps значений
                BitSync.Counter = 0;

            % Значение битовой синхронизации. Оно должно быть
            % инициализировано нулём, чтобы работали петли DLL и FPLL
                BitSync.CAShift = 0;
                
            % Инициализация массива корреляций для битовой синхронизации
                BitSync.Cor = zeros(1, CAPerBit);

        % Цикл трекинга
            while HardSamplesShift + CALen + 1 <= Res.File.SamplesLen
                % до тех пор, пока нам хватает данных для считывания
                % очередных E, P, L

                % Сохраним текущие значения NCO DLL и NCO FPDLL
                    DLL.NCOs(CACounter+1)      = DLL.NCO;
                    DLL.NCOSteps(CACounter+1)  = DLL.NCOStep;
                    FPLL.NCOs(CACounter+1)     = FPLL.NCO;
                    FPLL.NCOSteps(CACounter+1) = FPLL.NCOStep;

                % Сохраним текущие значения номера состояния и флаги
                % нахождения в синхронизме
                    DLL.States(CACounter+1)  = DLL.State;
                    DLL.isSyncs(CACounter+1) = DLL.isSync;
                    
                    FPLL.States(CACounter+1)  = FPLL.State;
                    FPLL.isSyncs(CACounter+1) = FPLL.isSync;

                % И синхронизацию по времени
                    SamplesShifts(CACounter+1)     = HardSamplesShift + ...
                        DLL.NCO;
                    HardSamplesShifts(CACounter+1) = HardSamplesShift;
                    FineSamplesShifts(CACounter+1) = DLL.NCO;

                % Считаем кусок файла, нужный для вычисления очередных E,
                % P, L
                    NumOfShiftedSamples = HardSamplesShift - 1;
                    NumOfNeededSamples  = CALen + 2;
                    [Signal, ~] = ReadSignalFromFile(Res.File, ...
                        NumOfShiftedSamples, NumOfNeededSamples);
                    
                % Выполним сдвиг по частоте
                % (Первый отсчёт P должен поворачиваться на FPLL.NCO!)
                    Signal = Signal * FPLL.NCO .* ...
                        exp(1i*FPLL.NCOStep*(-1:CALen));
                % Рассчитаем и сохраним E, P, L
                    Cors = conv(Signal, fliplr(conj(CA)), 'valid');
                    CorVals(CACounter+1)       = Cors(2);
                    EPLCorVals(:, CACounter+1) = Cors.';

                % Обновление значений для следующего CA
                    % Обновим NCO DLL с учётом FPLL
                        % Пересчёт FPLL.NCOStep в 
                            fd = FPLL.NCOStep*CALen/(2*pi*TCA);
                        % Пересчёт fd в Buf
                        % 1540 = 1575.42 / 1.023
                            Buf = fd * TCA * Res.File.R / 1540;
                        % Само обновление
                            DLL.NCO = DLL.NCO + DLL.NCOStep - Buf;
                        % Для работы без учёта FPLL.NCOStep:
                            % DLL.NCO = DLL.NCO + DLL.NCOStep;

                    % Определим, на сколько целых отсчётов нужно сдвинуться
                        HardShift = CALen + round(DLL.NCO);
                    % Вычислим значение синхронизации со следующим CA-кодом
                        HardSamplesShift = HardSamplesShift + HardShift;
                    % Оставим в NCO DLL только дробную часть
                        DLL.NCO = DLL.NCO - round(DLL.NCO);
                    % Обновим NCO FPDLL
                    % (Первый отсчёт P должен поворачиваться на FPLL.NCO!)
                        FPLL.NCO = FPLL.NCO *...
                            exp(1i*FPLL.NCOStep*HardShift);
                    
                % Битовая синхронизация - некогерентная (робастная, ранняя)
                    if ~BitSync.isDone
                        % Обновим счётчик накопленных P
                            BitSync.Counter = BitSync.Counter + 1;
                        % Добавим новое значение P
                            BitSync.Ps(BitSync.Counter) = Cors(2);
                        % Если накоплено необходимое количество значений P,
                        % то можно выполнить синхронизацию
                            if BitSync.Counter == length(BitSync.Ps)
                                % Находим разности фаз между соседними P
                                    Buf = BitSync.Ps(2:end) .* ...
                                        conj(BitSync.Ps(1:end-1));
                                % Расчёт корреляции
                                    BitSync.Cor = abs(sum(reshape(Buf, ...
                                        CAPerBit, NBits4Sync).'));
                                % Найдём минимум корреляции
                                    [~, Pos] = min(BitSync.Cor);
                                % Сохраним позицию синхронизации
                                    BitSync.CAShift = mod(Pos, CAPerBit);
                                % Изменим статус битовой синхронизации
                                    BitSync.isDone = 1;
                                % Сохраним текущее значение CA, как то, при
                                % котором произошла смена состояния
                                % фильтров
                                    DLL.PosCAStateChanged  = CACounter;
                                    FPLL.PosCAStateChanged = CACounter;
                                % Прорисовка при необходимости
                                    if isDraw > 0
                                        SatNum = Res.Search.SatNums(k);
                                        figure;
                                        plot(BitSync.Cor, '.-');
                                        title(sprintf(['Корреляция ', ...
                                            ' для определения битовой', ...
                                            '\nсинхронизации для ', ...
                                            'спутника №%d'], SatNum));
                                        drawnow;
                                        if isDraw > 1
                                            savefig(sprintf( ...
                                                'BitSyncCoh%02d', ...
                                                SatNum));
                                            if isDraw > 2
                                                close(gcf);
                                            end
                                        end
                                    end
                            end
                    end
                
                % Петля DLL
                    % if (mod(CACounter+1, DLL.NumIntCA) == 0)
                    if (mod(CACounter+1, DLL.NumIntCA) == ...
                            mod(BitSync.CAShift, DLL.NumIntCA))
                        % Позиции текущих NumIntCA отсчётов
                            PosesCurr = CACounter+1 + (-DLL.NumIntCA+1:0);
                            % disp('DLL');
                            % display(PosesCurr);
                        % Вычислим значение дискриминатора DLL
                            E = abs(sum(EPLCorVals(1, PosesCurr)));
                            L = abs(sum(EPLCorVals(3, PosesCurr)));
                            DLLDiscr = 0.5 * (E - L) / (E + L);
                        % Шаг работы фильтра
                            [Output, VelocAcc, AccelAcc] = ...
                                DLLFilter.Step(DLLDiscr);
                        % Определим новое значение шага NCO
                            DLL.NCOStep = -Output*TCA;
                        % Сохраним результаты
                            for n = PosesCurr
                                DLL.Discrs(n)     = DLLDiscr;
                                DLL.Outputs(n)    = Output;
                                DLL.VelocAccs(n)  = VelocAcc;
                                DLL.AccelAccs(n)  = AccelAcc;
                            end
                    end
                    
                % Петля FPLL
                    % if (mod(CACounter+1, FPLL.NumIntCA) == 0) && ...
                    %         (CACounter+1 > FPLL.NumIntCA)
                    if (mod(CACounter+1, FPLL.NumIntCA) == ...
                            mod(BitSync.CAShift, FPLL.NumIntCA)) && ...
                            (CACounter+1 > FPLL.NumIntCA)
                        % Позиции предыдущих и текущих NumIntCA отсчётов
                            PosesPrev = CACounter+1 - FPLL.NumIntCA + ...
                                (-FPLL.NumIntCA+1:0);
                            PosesCurr = CACounter+1                 + ...
                                (-FPLL.NumIntCA+1:0);
                            % disp('FPLL');
                            % display(PosesPrev);
                            % display(PosesCurr);
                        % Вычислим значение дискриминатора FLL
                            Buf =    sum(EPLCorVals(2, PosesCurr)) .* ...
                                conj(sum(EPLCorVals(2, PosesPrev)));
                            FLLDiscr = atan(imag(Buf)/real(Buf)) / (FPLL.NumIntCA*TCA);
                            % В терминах книги Kaplan
                            % real(Buf) - dot
                            % imag(Buf) - cross

                        % Дискриминатор для PLL
                            Buf = sum(EPLCorVals(2, PosesCurr));
                            PLLDiscr = atan(imag(Buf)/real(Buf));

                        % Шаг работы фильтра
                            [Output, VelocAcc, AccelAcc] = ...
                                FPLLFilter.Step(FLLDiscr, PLLDiscr);
                        % Определим новое значение шага NCO
                            FPLL.NCOStep = -Output*TCA;
                        % Пересчитаем его с учётом необходимости работы с
                        % отсчётами, идущими в CALen раз чаще, чем P
                            FPLL.NCOStep = FPLL.NCOStep / CALen;
                        % Сохраним результаты
                            for n = PosesCurr
                                FPLL.FLLDiscrs(n) = FLLDiscr;
                                FPLL.PLLDiscrs(n) = PLLDiscr;
                                FPLL.Outputs(n)   = Output;
                                FPLL.VelocAccs(n) = VelocAcc;
                                FPLL.AccelAccs(n) = AccelAcc;
                            end

                    end

                % Обработка перехода между состояниями FPLL
                    if BitSync.isDone
                        DLL.NumIntCA = 20;
                    end
                
                % Обработка перехода между состояниями FPLL
                    if BitSync.isDone
                        NumCA2CheckState = ...
                            FPLL.NumsCA2CheckState(FPLL.State);
                        if (mod(CACounter+1, NumCA2CheckState) == ...
                                mod(FPLL.PosCAStateChanged, ...
                                NumCA2CheckState)) && ...
                                (CACounter > FPLL.PosCAStateChanged)

                            % Возьмём значения фазового дискриминатора
                                Phases = FPLL.PLLDiscrs( ...
                                    CACounter+1 + ...
                                    (-NumCA2CheckState+1:0));
                            % Определим метрику
                                Val = sqrt(mean((Phases/pi).^2));
                            % Определим номер нового состояния
                                % По умолчанию оно остаётся без изменения
                                    NewState = FPLL.State;
                                if Val < FPLL.LoTr(FPLL.State)
                                    if FPLL.State < length(FPLL.LoTr)
                                        NewState = FPLL.State + 1;
                                    end
                                elseif Val > FPLL.HiTr(FPLL.State)
                                    if FPLL.State > 1
                                        NewState = FPLL.State - 1;
                                    end
                                end
                            % Если номер состояния изменился, то нужно
                            % изменить параметры фильтра
                                if NewState ~= FPLL.State
                                    FPLL.State = NewState;
                                    FPLL.NumIntCA = ...
                                        FPLL.NumsIntCA(NewState);
                                    FPLLFilter.ChangeParams( ...
                                        FPLL.FilterBands(NewState, :), ...
                                        TCA*FPLL.NumIntCA);
                                end
                            % Если мы значение метрики больше верхнего
                            % порога, то синхронизация временно потеряна
                                if Val < FPLL.HiTr(FPLL.State)
                                    FPLL.isSync = 1;
                                else
                                    FPLL.isSync = 0;
%                                     FPLL.State = 1;
                                end
                        end
                    end
                            
                % Обновим счётчик
                    CACounter = CACounter + 1;
                % Строка состояния
                    if mod(CACounter, NumCA2Disp) == 0
                        fprintf(['%s         обработано %d периодов ', ...
                            'CA-кода\n'], datestr(now), CACounter);
                    end
                    
                % Принудительное окончание!
                    if CACounter >= MaxNumCA2Process
                        break
                    end
            end

        % Отбрасываем неиспользованные элементы массивов-результатов
            SamplesShifts     = SamplesShifts(1:CACounter);
            CorVals           = CorVals(1:CACounter);
            HardSamplesShifts = HardSamplesShifts(1, 1:CACounter);
            FineSamplesShifts = FineSamplesShifts(1, 1:CACounter);
            EPLCorVals        = EPLCorVals(:, 1:CACounter);

            DLL.Discrs    = DLL.Discrs(1:CACounter);
            DLL.Outputs   = DLL.Outputs(1:CACounter);
            DLL.VelocAccs = DLL.VelocAccs(1:CACounter);
            DLL.AccelAccs = DLL.AccelAccs(1:CACounter);
            DLL.NCOs      = DLL.NCOs(1:CACounter);
            DLL.NCOSteps  = DLL.NCOSteps(1:CACounter);
            DLL.States    = DLL.States(1:CACounter);
            DLL.isSyncs   = DLL.isSyncs(1:CACounter);
            
            FPLL.FLLDiscrs = FPLL.FLLDiscrs(1:CACounter);
            FPLL.PLLDiscrs = FPLL.PLLDiscrs(1:CACounter);
            FPLL.Outputs   = FPLL.Outputs(1:CACounter);
            FPLL.VelocAccs = FPLL.VelocAccs(1:CACounter);
            FPLL.AccelAccs = FPLL.AccelAccs(1:CACounter);
            FPLL.NCOs      = FPLL.NCOs(1:CACounter);
            FPLL.NCOSteps  = FPLL.NCOSteps(1:CACounter);
            FPLL.States    = FPLL.States(1:CACounter);
            FPLL.isSyncs   = FPLL.isSyncs(1:CACounter);
            
        % Сохраним результаты для k-го спутника
            Track.SamplesShifts{k}     = SamplesShifts;
            Track.CorVals{k}           = CorVals;
            Track.HardSamplesShifts{k} = HardSamplesShifts;
            Track.FineSamplesShifts{k} = FineSamplesShifts;
            Track.EPLCorVals{k}        = EPLCorVals;
            Track.DLL{k}               = DLL;
            Track.FPLL{k}              = FPLL;

            BitSync.CAShifts(k) = BitSync.CAShift;
            BitSync.Cors(k, :) = BitSync.Cor;
            
        % Прорисовки при необходимости
            if isDraw > 0
                SatNum = Res.Search.SatNums(k);
                figure;
                    subplot(4, 1, 1);
                        Buf = abs(Track.CorVals{k});
                        plot(Buf, '.-');
                        title(sprintf(['Модуль корреляций с ', ...
                            'периодами CA-кода для спутника №%d'], ...
                            SatNum));
                        xlim([1, CACounter]);
                        ylim([0, max(Buf)]);
                        xlabel('Номер периода CA-кода');
                        grid on;
                    subplot(4, 1, 2);
                        Buf = angle(Track.CorVals{k})/pi;
                        plot(Buf, '.-');                
                        title(sprintf(['Фазы корреляций с периодами ', ...
                            'CA-кода для спутника №%d'], SatNum));
                        xlim([1, CACounter]);
                        ylim([-1, 1]);
                        xlabel('Номер периода CA-кода');
                        grid on;
                    subplot(4, 1, 3);
                        A = Track.HardSamplesShifts{k};
                        A = A - A(1);
                        A = A - (0:length(A)-1)*CALen;
                        plot(A, 'b');

                        B = Track.SamplesShifts{k};
                        B = B - B(1);
                        B = B - (0:length(B)-1)*CALen;
                        hold on;
                        plot(B, 'r');

                        f = Track.FPLL{k}.VelocAccs / (2*pi);
                        f0 = 1575.42 * 10^6;
                        C = cumsum(f)*TCA*Res.File.Fs/f0;
                        C = C + (C(1) - B(1));
                        hold on;
                        plot(C, 'k');

                        legend('Hard DLL', 'Soft DLL', 'Int Dop');
                        title(sprintf(['Кривая кумулятивного ухода ', ...
                            'синхронизации для спутника №%d'], SatNum));
                        xlim([1, CACounter]);
                        ylim([min([min(A), min(B), min(C)]), ...
                            max([max(A), max(B), max(C)])]);
                        xlabel('Номер периода CA-кода');
                        grid on;
                    subplot(4, 1, 4);
                        Len = min(length(B), length(C));
                        plot(B(1:Len) - C(1:Len));
                        title(sprintf(['(Soft DLL - Int Dop) для ', ...
                            'спутника №%d'], SatNum));
                        xlim([1, CACounter]);
                        xlabel('Номер периода CA-кода');
                        grid on;
                drawnow;
                if isDraw > 1
                    savefig(sprintf('TrackCoh%02d', SatNum));
                    if isDraw > 2
                        close(gcf);
                    end
                end
                
                figure;
                    subplot(5, 1, 1);
                        DLLDiscrs = Track.DLL{k}.Discrs;
                        plot(DLLDiscrs);
                        title(sprintf('DLLDiscrs для спутника №%d', ...
                            SatNum));
                        % ylim([-1, 1]);
                        grid on;
                    subplot(5, 1, 2);
                        FLLDiscrs = Track.FPLL{k}.FLLDiscrs;
                        plot(FLLDiscrs*(FPLL.NumIntCA*TCA)/pi);
                        title(sprintf('FLLDiscrs для спутника №%d', ...
                            SatNum));
                        ylim([-1, 1]);
                        grid on;
                    subplot(5, 1, 3);
                        PLLDiscrs = Track.FPLL{k}.PLLDiscrs;
                        plot(PLLDiscrs/pi);
                        title(sprintf('PLLDiscrs для спутника №%d', ...
                            SatNum));
                    	ylim([-1, 1]);
                        grid on;
                    subplot(5, 1, 4);
                        VelocAccs = Track.FPLL{k}.VelocAccs;
                        plot(VelocAccs/(2*pi));
                        title(sprintf(['VelocAccs для спутника ', ...
                            '№%d, Гц'], SatNum));
                        grid on;
                    subplot(5, 1, 5);
                        AccelAccs = Track.FPLL{k}.AccelAccs;
                        plot(AccelAccs/(2*pi));
                        title(sprintf(['AccelAccs для спутника ', ...
                            '№%d, Гц'], SatNum));
                        grid on;
                drawnow;
                if isDraw > 1
                    savefig(sprintf('LoopsCoh%02d', SatNum));
                    if isDraw > 2
                        close(gcf);
                    end
                end
            end

        % Строка состояния
            fprintf('%s         Завершено.\n', datestr(now));
    end
    % Добавим новые поля с результатами в Res
        Res.Track   = Track;
        Res.BitSync = BitSync;

    % Строка состояния
        fprintf('%s     Завершено.\n', datestr(now));