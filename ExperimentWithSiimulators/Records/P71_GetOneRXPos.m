function UPos = P71_GetOneRXPos(SatsPoses, inTimeShifts, SampleNums)
%
% Функция расчёта одного набора координат приёмника
%
% Входные переменные
%   Es - cell-массив с эфемеридами спутников;
%   inGPSTimes - моменты времени, в которые были испущены сигналы со
%       спутников;
%   inTimeShifts - отличия значений задержки распространения сигналов
%       спутников от общей постоянной составляющей задержки
%       распространения;
%   SampleNums - номера отсчётов, в которые пришли сигналы спутников с
%       метками времени inGPSTimes.
%
% Выходные переменные
%   UPos - результат-структура с полями:
%       x, y, z - координаты в прямоугольной ДСК
%       T0 - общая составляющая сдвига по времени
%       tGPSs, SampleNums - значения времени GPS для заданных отсчётов 
%       Lat, Lon, Alt - широта, долгота, высота
%       SatsPoses - координаты спутников, таблица со столбцами
%           x, y, z - координаты в прямоугольной ДСК;
%           xs_k, ys_k, i_k - координаты перед преобразованиями СК;
%           Lat, Lon, Alt - широта, долгота, высота;
%           El, Az - угол склонения и азимут;
%       NumIters, MaxNumIters - выполненное и максимальное число итераций;
%       Delta, MaxDelta - достигнутое и максимальное значение оценки
%           изменения координат пользователя между соседними итерациями
%           (м);
%       inGPSTimes, GPSTimes, inTimeShifts, TimeShifts - сохранение
%           параметров и скорректированных параметров.

%% УСТАНОВКА ПАРАМЕТРОВ
    % Максимальное число итераций
        MaxNumIters = 100;
    % Максимальное изменение координат пользователя между соседними
    % итерациями (м). Если фактическое изменение меньше, то цикл
    % останавливается
        MaxDelta = 0.1;

%% УСТАНОВКА КОНСТАНТ
    % Скорость света, м/с
        c = 299792458;
    % Радиус Земли, м
        R = 6356863;

%% ИНИЦИАЛИЗАЦИЯ    
    % Определим количество используемых спутников
%         NumSats = length(Es);
    sizeSatsPoses = size(SatsPoses);
    NumSats = sizeSatsPoses(2);
    % Начальное значение неизвестной обшей составляющей времени
    % распространения сигнала, с
        T0 = 0;%68*10^(-3); 

    % Вычислим начальные координаты спутников
%         SatsPoses = zeros(8, NumSats); % Первые 3 значения - x, y, z,
            % остальное - переменные, нужные для уточнения координат
            % спутников
        GPSTimes   = zeros(1, NumSats);
        TimeShifts = zeros(1, NumSats);
%         for k = 1:NumSats
%             [SatsPoses(:, k), GPSTimes(k), TimeShifts(k)] = ...
%                 P72_GetSatPos(Es{k}, inGPSTimes(k), T0 + inTimeShifts(k));
%         end
        inTimeShifts = inTimeShifts - T0;

    % Выделим нужную информацию в столбцы
        T  = inTimeShifts.';
        xs = SatsPoses(1, :).';
        ys = SatsPoses(2, :).';
        zs = SatsPoses(3, :).';

    % Начальные координаты пользователя
        % Средние координаты спутников
            xm = mean(xs);
            ym = mean(ys);
            zm = mean(zs);

        % Координаты первой точки пересечения поверхности Земли (шара) и
        % линии, соединяющей центр Земли с (xm, ym, zm), координаты второй
        % точки - противоположные
            Buf = 1/sqrt(xm^2 + ym^2 + zm^2);
            x = 0; 
            y = 0;
            z = 0;
%             x = R*xm*Buf;
%             y = R*ym*Buf;
%             z = R*zm*Buf;

        % Определим квадраты расстояний от (xm, ym, zm) до двух полученных
        % точек
%             d1 = (x-xm)^2 + (y-ym)^2 + (z-zm)^2;
%             d2 = (x+xm)^2 + (y+ym)^2 + (z+zm)^2;
% 
%         % Выберем ближайшую
%             if d2 < d1
%                 x = -x;
%                 y = -y;
%                 z = -z;
%             end

    % Чтобы диапазон значений матрицы A был более однородным, перейдём от
    % Tj, T и T0 к cTj = c*Tj, cT = c*T и cT0 = c*T0
        % cTj = c*Tj;
        cT = c*T;
        cT0 = c*T0;

    % Подготовка к циклу    
        % Инициализация A и B
            % B = zeros(NumSats, 1); % инициализация не требуется
            A = zeros(NumSats, 4);
            % A(:, 4) = -c;
            A(:, 4) = -1;

        % Счётчик итераций
            IterCounter = 0;

        % Флаг выхода из цикла
            isStop = false;

%% ИТЕРАЦИИ
    while ~isStop
        % Вычислим Tj, соответствующие текущим значениям xs, ys, zs, x, y,
        % z, T0:
            % Tj = sqrt((xs - x).^2 + (ys - y).^2 + (zs - z).^2)/c - T0;
            cTj = sqrt((xs - x).^2 + (ys - y).^2 + (zs - z).^2) - cT0;
        % Вычислим значения B
            % B = c*(T - Tj);
            B = cT - cTj;

        % Вычислим значения элементов первого, второго и третьего столбцов
        % матрицы A, остальные уже установлены.
            % Buf = 1./((Tj + T0)*c);
            Buf = 1./(cTj + cT0);
            A(:, 1) = -(xs - x).*Buf;
            A(:, 2) = -(ys - y).*Buf;
            A(:, 3) = -(zs - z).*Buf;

        % Вычислим обратную/псевдообратную матрицу к матрице A
            if NumSats == 4
                iA = inv(A);
            else
                iA = pinv(A);
            end

        % Решим систему
            X = iA * B;

        % Обновим счётчик итераций
            IterCounter = IterCounter + 1;

        % Проверка выхода из цикла
            % Delta = sqrt(sum((X.*[1; 1; 1; c]).^2));
            Delta = sqrt(sum(X.^2));
            if (IterCounter > MaxNumIters) || (Delta <= MaxDelta)
                isStop = true;
            else
                % Обновим значения x, y, z, T
                    x  = x  + X(1);
                    y  = y  + X(2);
                    z  = z  + X(3);
                    % T0 = T0 + X(4);
                    cT0 = cT0 + X(4);

                % Обновим координаты спутников с учётом нового значения T0
%                     for k = 1:NumSats
%                         % SatsPoses(1:3, k) = P73_RenewSatPos( ...
%                         %     SatsPoses(:, k), T0 + T(k));
%                         SatsPoses(1:3, k) = P73_RenewSatPos( ...
%                             SatsPoses(:, k), (cT0 + cT(k))/c);
%                     end
%                     xs = SatsPoses(1, :).';
%                     ys = SatsPoses(2, :).';
%                     zs = SatsPoses(3, :).';
            end
    end

    % Обратное преобразование от cTj, cT и cT0 к Tj, T и T0
        % Tj = cTj/c; % не понадобится
        % T  = cT/c;  % не понадобится
        T0 = cT0/c;

%% ДООБРАБОТКА - расчёт Lat, Lon, Alt, El, Az
    % Вытянем координаты спутников и добавим пять позиций для каждого
    % спутника для сохранения Lat, Lon, Alt, El, Az
        SatsPoses = SatsPoses(1:6, :);
        SatsPoses = [SatsPoses; zeros(5, NumSats)];

    % Преобразование координат из XYZ в LLA
        % Для приёмника
            [Lat, Lon, Alt] = P74_Cartesian2Spherical([x, y, z]);

        % Для спутников
%             for k = 1:NumSats
%                 [SatsPoses(7, k), SatsPoses(8, k), SatsPoses(9, k)] = ...
%                     P74_Cartesian2Spherical(SatsPoses(1:3, k));
%             end

    % Расчёт углов склонения и азимута для спутников
%         for k = 1:NumSats
%             [SatsPoses(10, k), SatsPoses(11, k)] = ...
%                 P75_CalculateSatElAz(SatsPoses(1:3, k).', [x, y, z]);
%         end

%% СОХРАНЕНИЕ РЕЗУЛЬТАТОВ
    % Преобразуем SatsPoses в таблицу
        SatsPoses = array2table(SatsPoses.', 'VariableNames', {'x', ...
            'y', 'z', 'xs_k', 'ys_k', 'i_k', 'Lat', 'Lon', 'Alt', 'El', ...
            'Az'});

    % Сохраним результаты
        UPos.x  = x;
        UPos.y  = y;
        UPos.z  = z;
        UPos.T0 = T0;
        UPos.tGPSs = GPSTimes + T0 + TimeShifts;
        UPos.SampleNums = SampleNums;
        UPos.Lat = Lat;
        UPos.Lon = Lon;
        UPos.Alt = Alt;
        UPos.SatsPoses = SatsPoses;
        UPos.NumIters    = IterCounter;
        UPos.MaxNumIters = MaxNumIters;
        UPos.Delta    = Delta;
        UPos.MaxDelta = MaxDelta;
        UPos.inGPSTimes = inGPSTimes;
        UPos.GPSTimes   = GPSTimes;
        UPos.inTimeShifts = inTimeShifts;
        UPos.TimeShifts   = TimeShifts;
end