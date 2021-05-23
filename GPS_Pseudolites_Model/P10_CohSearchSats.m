function Res = P10_CohSearchSats(inRes, isDraw, Params)
%
% Функция когерентного поиска спутников в файле-записи
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
    Search = struct( ...
        'NumSats',       [], ... % Скаляр, количество найденных спутников
        'SatNums',       [], ... % массив 1хNumSats с номерами найденных
            ... % спутников
        'SamplesShifts', [], ... % массив 1хNumSats, каждый элемент -
            ... % количество отсчётов, которые нужно пропустить в файле-
            ... % записи до начала первого периода CA-кода соответствующего
            ... % спутника
        'FreqShifts',    [], ... % массив 1хNumSats со значениями частотных
            ... % сдвигов найденных спутников в Гц
        'CorVals',       [], ... % массив 1хNumSats вещественных значений
            ... % пиков корреляционных функций нормированных на среднее
            ... % значение, по которым были найдены спутники
        'AllCorVals',    zeros(1, 32) ... % массив максимальных значений
            ... % всех корреляционных функций
    );

%% УСТАНОВКА ПАРАМЕТРОВ
    % Количество периодов, учитываемых при обнаружении.
    % Для когерентного обнаружения 1 <= NumCA2Search <= 10
        NumCA2Search = 10;

    % Массив центральных частот анализируемых диапазонов, Гц
        CentralFreqs = -6000 : 1000/(2*NumCA2Search) : 6000;

    % Порог обнаружения
        SearchThreshold = Params.threshold;%10 - real world signal

%% СОХРАНЕНИЕ ПАРАМЕТРОВ
    Search.NumCA2Search    = NumCA2Search;
    Search.CentralFreqs    = CentralFreqs;
    Search.SearchThreshold = SearchThreshold;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Количество рассматрвиаемых частотных диапазонов
        NumCFreqs = length(CentralFreqs);

    % Длина CA-кода с учётом частоты дискретизации
        CALen = 1023 * Res.File.R;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ
    % Подготовка к прорисовке двумерной КФ
        if isDraw
            [X, Y] = meshgrid(0:CALen-1, CentralFreqs);
        end

    % Выделение памяти под массив корреляций
        Corr1 = zeros(NumCFreqs, CALen);
        Corr2 = zeros(NumCFreqs, CALen);

    % Параметры считывания из файла
        % Начинаем с начала
            NumOfShiftedSamples = 0;
        % Количество считываемых элементов зависит от NumCA2Search
            NumOfNeededSamples = 2*NumCA2Search*CALen + (CALen-1);

    % Считаем нужный кусок файла
        [Signal, ~] = ReadSignalFromFile(Res.File, ...
            NumOfShiftedSamples, NumOfNeededSamples);
        if isempty(Signal)
            return
        end

    % Цикл по количеству искомых спутников
        % Строка состояния
            fprintf('%s Поиск спутников:\n', datestr(now));
%         for k = 1:4
        k = Params.sv_id;
            % Строка состояния
                fprintf('%s     поиск спутника №%02d ...', ...
                    datestr(now), k);

            % Сформируем CA-код
                CA = GenCACode(k);

            % Выполним модуляцию
                CA = 2*CA-1;

            % Увеличим частоту дискретизации
                CA = reshape(repmat(CA, Res.File.R, 1), 1, CALen);

            % Цикл по частотным диапазонам
                for n = 1 : NumCFreqs
                    % Сдвинем сигнал по частоте
                        FSignal = Signal .* ...
                            exp(1i*2*pi*(CentralFreqs(n)/Res.File.Fs)* ...
                            (0:NumOfNeededSamples-1));
                    % Вычислим 2*NumCA2Search периодов КФ
                        Buf = conv(FSignal, fliplr(conj(CA)), 'valid');

                    % Выполним накопление КФ
                        if NumCA2Search == 1
                            Corr1(n, :) = Buf(         1:CALen );
                            Corr2(n, :) = Buf(CALen + (1:CALen));
                        else
                            Tmp = NumCA2Search*CALen;
                            Corr1(n, :) = sum(reshape(Buf( ...
                                 1:Tmp ), CALen, NumCA2Search).');
                            Corr2(n, :) = sum(reshape(Buf(Tmp + ...
                                (1:Tmp)), CALen, NumCA2Search).');
                        end
                end
                
            % Перейдём к модулям корреляций
                Corr1 = abs(Corr1);
                Corr2 = abs(Corr2);
            % или квадратам модулей - тогда порог надо возвести в квадрат
                % Corr1 = Corr1 .* conj(Corr1);
                % Corr2 = Corr2 .* conj(Corr2);
                
            % Выберем корреляцию с максимальным пиком
                if max(max(Corr1)) > max(max(Corr2))
                    Corr = Corr1;
                else
                    Corr = Corr2;
                end

            % Прорисовка при необходимости
%                 if isDraw > 0
%                     figure;
%                     surf(X, Y, Corr/mean(mean(Corr)));
%                     xlim([0, CALen-1]);
%                     ylim([min(CentralFreqs), max(CentralFreqs)]);
%                     xlabel('Сдвиг до начала CA-кода, отсчёты');
%                     ylabel('Частотный сдвиг, Гц');
%                     title(sprintf(['Модуль корреляционной функции\n', ...
%                         'нормированной на среднее значение\nдля ', ...
%                         'спутника №%d'], k));
%                     drawnow;
%                     if isDraw > 1
%                         savefig(sprintf('SearchCoh%02d', k));
%                         if isDraw > 2
%                             close(gcf);
%                         end
%                     end
%                 end

            % Поиск пика и сохранение его координат
                Max  = max(max(Corr));
                Mean = mean(mean(Corr));
                Search.AllCorVals(k) = Max / Mean;
                if Search.AllCorVals(k) >= SearchThreshold
                    % Строка состояния
                        fprintf(' найден;\n');

                    % Определение координат максимума (R, C) массива Corr
                        [Vals, RPoses] = max(Corr);
                        [~, C] = max(Vals);
                        R = RPoses(C);

                    % Сдвинем позицию пика на половину длины корреляционной
                    % функции
                        % C = C + NumCA2Search*CALen;
                        
                    % Сохранение результатов
                        Search.SatNums       = [Search.SatNums, k];
                        Search.SamplesShifts = [Search.SamplesShifts ...
                            C - 1];
                        Search.FreqShifts    = [Search.FreqShifts, ...
                            CentralFreqs(R)];
                        Search.CorVals       = [Search.CorVals, Max/Mean];
                else
                    % Строка состояния
                        fprintf(' не найден;\n');
                end
        

    % Прорисовка значений пиков КФ всех спутников
        if isDraw > 0
            figure;
            plot(Search.AllCorVals, '.-b');
            grid on;
            hold on;
            plot(Search.SatNums, Search.AllCorVals(Search.SatNums), ...
                '.r', 'MarkerSize', 24);
            plot([1, 32], [1, 1]*SearchThreshold, 'k');
            xlim([1, 32]);
            xlabel('Номер CA-кода');
            ylabel('Значение нормированной КФ');
            legend('Все значения', 'Значения, превысившие порог', 'Порог');
            drawnow;
            if isDraw > 1
                savefig(sprintf('FoundCoh%02d', k));
                if isDraw > 2
                    close(gcf);
                end
            end
        end
        
    % Сортировка результатов по уровню корреляции
        % Определение порядка элементов для сортировки
            [~, I] = sort(Search.CorVals, 'descend');
        % Сама сортировка
            Search.SatNums       = Search.SatNums(I);
            Search.SamplesShifts = Search.SamplesShifts(I);
            Search.FreqShifts    = Search.FreqShifts(I);
            Search.CorVals       = Search.CorVals(I);

    % Сохраним количество найденных спутников
        Search.NumSats = length(Search.SatNums);

    % Добавим новое поле с результатами в Res
        Res.Search = Search;

    % Строка состояния
        fprintf(['%s     номера найденных спутников в порядке ', ...
            'убывания мощности сигнала:\n'], datestr(now));
        Buf = sprintf('% d', Search.SatNums);
        fprintf('%s     [%s]\n', datestr(now), Buf(2:end));
        fprintf('%s     завершено.\n', datestr(now));