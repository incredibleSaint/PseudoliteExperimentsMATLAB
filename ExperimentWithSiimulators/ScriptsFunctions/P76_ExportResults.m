function P76_ExportResults(RXPoses, FileName)
%
% Функция экспорта координат в файл *.kml

%% УСТАНОВКА ПАРАМЕТРОВ
    % Нужно ли сохранять метки позиции приёмника
        isSaveUserPoses = 1;
    % Нужно ли сохранять метки позиции спутников
        isSaveSatsPoses  = 0;
    % Нужно ли вычислять СКО координат приёмника
        isCalcCoordinatesVariance = 1;
    % Нужно ли нумеровать метки позиций приёмника
        isNumerateLabels = 1;

    % Опорные координаты
        RefPoses = [0, 0, 0]; % все нули значат, что референсная метка не
            % используется
        % RefPoses = [60.761293 30.108093 19]; % Дача Суходолье
        % RefPoses = [60.206665 30.258967 68]; % Дача Агалатово
        % RefPoses = [60.030070 30.401688 44]; % Город (Ушинского)

    % Имя файла для сохранения результатов
%         FileName = ;

%% ЭКСПОРТ КООРДИНАТ
    % Если надо сохранять координаты приёмника, то сохраним поочерёдно все
    % имеющиеся координаты в массив координат, в том числе, сохраним
    % разностные относительно референса координаты
        if isSaveUserPoses
            Buf = RXPoses(:);
            NumPoses = length(Buf);
            UPoses = zeros(NumPoses, 3);
            dUPoses = zeros(NumPoses, 3);
            for k = 1:NumPoses
                X = Buf{k}.Lat*180/pi; % широта в градусах
                Y = Buf{k}.Lon*180/pi; % долгота в градсуах
                H = Buf{k}.Alt; % высота в метрах
                UPoses(k, :) = [X, Y, H];
                dUPoses(k, :) = UPoses(k, :) - RefPoses;
            end
        end

    % Если требуется сохранять координаты спутников, то возьмём их из
    % первых координат
        if isSaveSatsPoses
            SatsPoses = RXPoses{1}.SatsPoses;
            SatsPoses.Lat = SatsPoses.Lat*180/pi; % широта в градусах
            SatsPoses.Lon = SatsPoses.Lon*180/pi; % долгота в градсуах
            SatsPoses.El = SatsPoses.El*180; % угол склонения в градусах
            SatsPoses.Az = SatsPoses.Az*180; % угол азимут в градусах
        end

    % Сам экспорт
    for ZaZa = 1
        % Создадим файл
            if length(FileName) >= 4
                if isequal(FileName(end-3:end), '.kml')
                    FileName = FileName(1:end-4);
                end
            end

            FileName = [FileName, '.kml']; %#ok<AGROW>

            fid = fopen(FileName, 'w');

        % Стиль меток спутников
            SatStyle = 'http://maps.google.com/mapfiles/kml/paddle/S.png';
        % Стиль основных меток
            CommonStyle = '';
        % Стиль референсной метки
            RefStyle = ['http://maps.google.com/mapfiles/kml/pushpin/', ...
                'red-pushpin.png'];

        % Две первые строки и строка, открывающая документ
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
            fprintf(fid,'<kml xmlns="http://www.opengis.net/kml/2.2">\n');    
            fprintf(fid,'<Document>\n');
        % Стиль меток спутников
            if isSaveSatsPoses
                if ~isempty(SatStyle) 
                    fprintf(fid,'    <Style id="SatStyle">\n');
                    fprintf(fid,'        <IconStyle>\n');
                    fprintf(fid,'            <scale>5</scale>\n');
                    fprintf(fid,'            <Icon>\n');
                    fprintf(fid,'                <href>%s</href>\n', SatStyle);
                    fprintf(fid,'            </Icon>\n');
                    fprintf(fid,'        </IconStyle>\n');
                    fprintf(fid,'    </Style>\n');
                end
            end
        % Стиль основных меток
            if isSaveUserPoses
                if ~isempty(CommonStyle)
                    fprintf(fid,'    <Style id="CommonStyle">\n');
                    fprintf(fid,'        <IconStyle>\n');
                    fprintf(fid,'            <Icon>\n');
                    fprintf(fid,'                <href>%s</href>\n', CommonStyle);
                    fprintf(fid,'            </Icon>\n');
                    fprintf(fid,'        </IconStyle>\n');
                    fprintf(fid,'    </Style>\n');
                end
            end
        % Стиль референсной метки
            if ~isequal(RefPoses, [0, 0, 0])
                if ~isempty(RefStyle)
                    fprintf(fid,'    <Style id="RefStyle">\n');
                    fprintf(fid,'        <IconStyle>\n');
                    fprintf(fid,'            <Icon>\n');
                    fprintf(fid,'                <href>%s</href>\n', RefStyle);
                    fprintf(fid,'            </Icon>\n');
                    fprintf(fid,'        </IconStyle>\n');
                    fprintf(fid,'    </Style>\n');
                end
            end
        % Вставка меток спутников
            if isSaveSatsPoses
                for k = 1:length(SatsPoses.Lat)
                    fprintf(fid,'   <Placemark>\n');
                    fprintf(fid,'      <name>Sat%d</name>\n', k);
                    fprintf(fid,'      <description>Elevation = %.0f; Azimuth = %.0f; Height = %.0f</description>\n', SatsPoses.El(k), SatsPoses.Az(k), SatsPoses.Alt(k));
                    if ~isempty(SatStyle)
                        fprintf(fid,'      <styleUrl>#SatStyle</styleUrl>\n');
                    end
                    fprintf(fid,'      <Point>\n');
                    fprintf(fid,'         <coordinates>%.6f,%.6f,0</coordinates>\n', SatsPoses.Lon(k), SatsPoses.Lat(k));
                    fprintf(fid,'      </Point>\n');
                    fprintf(fid,'   </Placemark>\n');
                end
            end
        % Вставка меток основных координат
            if isSaveUserPoses
                for k = 1:size(UPoses, 1)
                    fprintf(fid,'   <Placemark>\n');
                    if isNumerateLabels
                        fprintf(fid,'      <name>%d</name>\n', k);
                    end
                    fprintf(fid,'      <description>Height above Earth = %.0f</description>\n', UPoses(k, 3));
                    if ~isempty(CommonStyle)
                        fprintf(fid,'      <styleUrl>#CommonStyle</styleUrl>\n');
                    end
                    fprintf(fid,'      <Point>\n');
                    fprintf(fid,'         <coordinates>%.6f,%.6f,0</coordinates>\n', UPoses(k, 2), UPoses(k, 1));
                    fprintf(fid,'      </Point>\n');
                    fprintf(fid,'   </Placemark>\n');
                end
            end
        % Вставка метки референсных координат
            if ~isequal(RefPoses, [0, 0, 0])
                fprintf(fid,'   <Placemark>\n');
                fprintf(fid,'      <name>Ref</name>\n');
                if ~isempty(RefStyle)
                    fprintf(fid,'      <styleUrl>#RefStyle</styleUrl>\n');
                end
                fprintf(fid,'      <Point>\n');
                fprintf(fid,'         <coordinates>%.6f,%.6f,0</coordinates>\n', RefPoses(2), RefPoses(1));
                fprintf(fid,'      </Point>\n');
                fprintf(fid,'   </Placemark>\n');
            end
        % Строки закрытия документа и закрытия kml
            fprintf(fid,'</Document>\n');
            fprintf(fid,'</kml>\n');

        % Закроем файл
            fclose(fid);
    end

    % Вычислим СКО самих коорднат и разностных
        if isCalcCoordinatesVariance
            % Множители для пересчёта одного градуса широты и долготы (для
            % нашей широты и долготы) в метры
                Mult = [55.8*10^3, 111.111*10^3, 1];
            fprintf('СКО координат (м): % 6.1f\n', std(dUPoses).*Mult);
            if ~isequal(RefPoses, [0, 0, 0])
                fprintf(['Отклонение средних координат от истиных ', ...
                    '(м): % 6.1f\n'], mean(dUPoses).*Mult);
            end
        end
end