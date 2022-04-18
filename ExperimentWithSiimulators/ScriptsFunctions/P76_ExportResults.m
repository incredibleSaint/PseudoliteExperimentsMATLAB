function P76_ExportResults(RXPoses, FileName)
%
% ������� �������� ��������� � ���� *.kml

%% ��������� ����������
    % ����� �� ��������� ����� ������� ��������
        isSaveUserPoses = 1;
    % ����� �� ��������� ����� ������� ���������
        isSaveSatsPoses  = 0;
    % ����� �� ��������� ��� ��������� ��������
        isCalcCoordinatesVariance = 1;
    % ����� �� ���������� ����� ������� ��������
        isNumerateLabels = 1;

    % ������� ����������
        RefPoses = [0, 0, 0]; % ��� ���� ������, ��� ����������� ����� ��
            % ������������
        % RefPoses = [60.761293 30.108093 19]; % ���� ���������
        % RefPoses = [60.206665 30.258967 68]; % ���� ���������
        % RefPoses = [60.030070 30.401688 44]; % ����� (���������)

    % ��� ����� ��� ���������� �����������
%         FileName = ;

%% ������� ���������
    % ���� ���� ��������� ���������� ��������, �� �������� ��������� ���
    % ��������� ���������� � ������ ���������, � ��� �����, ��������
    % ���������� ������������ ��������� ����������
        if isSaveUserPoses
            Buf = RXPoses(:);
            NumPoses = length(Buf);
            UPoses = zeros(NumPoses, 3);
            dUPoses = zeros(NumPoses, 3);
            for k = 1:NumPoses
                X = Buf{k}.Lat*180/pi; % ������ � ��������
                Y = Buf{k}.Lon*180/pi; % ������� � ��������
                H = Buf{k}.Alt; % ������ � ������
                UPoses(k, :) = [X, Y, H];
                dUPoses(k, :) = UPoses(k, :) - RefPoses;
            end
        end

    % ���� ��������� ��������� ���������� ���������, �� ������ �� ��
    % ������ ���������
        if isSaveSatsPoses
            SatsPoses = RXPoses{1}.SatsPoses;
            SatsPoses.Lat = SatsPoses.Lat*180/pi; % ������ � ��������
            SatsPoses.Lon = SatsPoses.Lon*180/pi; % ������� � ��������
            SatsPoses.El = SatsPoses.El*180; % ���� ��������� � ��������
            SatsPoses.Az = SatsPoses.Az*180; % ���� ������ � ��������
        end

    % ��� �������
    for ZaZa = 1
        % �������� ����
            if length(FileName) >= 4
                if isequal(FileName(end-3:end), '.kml')
                    FileName = FileName(1:end-4);
                end
            end

            FileName = [FileName, '.kml']; %#ok<AGROW>

            fid = fopen(FileName, 'w');

        % ����� ����� ���������
            SatStyle = 'http://maps.google.com/mapfiles/kml/paddle/S.png';
        % ����� �������� �����
            CommonStyle = '';
        % ����� ����������� �����
            RefStyle = ['http://maps.google.com/mapfiles/kml/pushpin/', ...
                'red-pushpin.png'];

        % ��� ������ ������ � ������, ����������� ��������
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
            fprintf(fid,'<kml xmlns="http://www.opengis.net/kml/2.2">\n');    
            fprintf(fid,'<Document>\n');
        % ����� ����� ���������
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
        % ����� �������� �����
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
        % ����� ����������� �����
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
        % ������� ����� ���������
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
        % ������� ����� �������� ���������
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
        % ������� ����� ����������� ���������
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
        % ������ �������� ��������� � �������� kml
            fprintf(fid,'</Document>\n');
            fprintf(fid,'</kml>\n');

        % ������� ����
            fclose(fid);
    end

    % �������� ��� ����� �������� � ����������
        if isCalcCoordinatesVariance
            % ��������� ��� ��������� ������ ������� ������ � ������� (���
            % ����� ������ � �������) � �����
                Mult = [55.8*10^3, 111.111*10^3, 1];
            fprintf('��� ��������� (�): % 6.1f\n', std(dUPoses).*Mult);
            if ~isequal(RefPoses, [0, 0, 0])
                fprintf(['���������� ������� ��������� �� ������� ', ...
                    '(�): % 6.1f\n'], mean(dUPoses).*Mult);
            end
        end
end