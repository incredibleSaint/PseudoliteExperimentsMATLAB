function UPos = P71_GetOneRXPos(SatsPoses, inTimeShifts, SampleNums)
%
% ������� ������� ������ ������ ��������� ��������
%
% ������� ����������
%   Es - cell-������ � ����������� ���������;
%   inGPSTimes - ������� �������, � ������� ���� �������� ������� ��
%       ���������;
%   inTimeShifts - ������� �������� �������� ��������������� ��������
%       ��������� �� ����� ���������� ������������ ��������
%       ���������������;
%   SampleNums - ������ ��������, � ������� ������ ������� ��������� �
%       ������� ������� inGPSTimes.
%
% �������� ����������
%   UPos - ���������-��������� � ������:
%       x, y, z - ���������� � ������������� ���
%       T0 - ����� ������������ ������ �� �������
%       tGPSs, SampleNums - �������� ������� GPS ��� �������� �������� 
%       Lat, Lon, Alt - ������, �������, ������
%       SatsPoses - ���������� ���������, ������� �� ���������
%           x, y, z - ���������� � ������������� ���;
%           xs_k, ys_k, i_k - ���������� ����� ���������������� ��;
%           Lat, Lon, Alt - ������, �������, ������;
%           El, Az - ���� ��������� � ������;
%       NumIters, MaxNumIters - ����������� � ������������ ����� ��������;
%       Delta, MaxDelta - ����������� � ������������ �������� ������
%           ��������� ��������� ������������ ����� ��������� ����������
%           (�);
%       inGPSTimes, GPSTimes, inTimeShifts, TimeShifts - ����������
%           ���������� � ����������������� ����������.

%% ��������� ����������
    % ������������ ����� ��������
        MaxNumIters = 100;
    % ������������ ��������� ��������� ������������ ����� ���������
    % ���������� (�). ���� ����������� ��������� ������, �� ����
    % ���������������
        MaxDelta = 0.1;

%% ��������� ��������
    % �������� �����, �/�
        c = 299792458;
    % ������ �����, �
        R = 6356863;

%% �������������    
    % ��������� ���������� ������������ ���������
%         NumSats = length(Es);
    sizeSatsPoses = size(SatsPoses);
    NumSats = sizeSatsPoses(2);
    % ��������� �������� ����������� ����� ������������ �������
    % ��������������� �������, �
        T0 = 0;%68*10^(-3); 

    % �������� ��������� ���������� ���������
%         SatsPoses = zeros(8, NumSats); % ������ 3 �������� - x, y, z,
            % ��������� - ����������, ������ ��� ��������� ���������
            % ���������
        GPSTimes   = zeros(1, NumSats);
        TimeShifts = zeros(1, NumSats);
%         for k = 1:NumSats
%             [SatsPoses(:, k), GPSTimes(k), TimeShifts(k)] = ...
%                 P72_GetSatPos(Es{k}, inGPSTimes(k), T0 + inTimeShifts(k));
%         end
        inTimeShifts = inTimeShifts - T0;

    % ������� ������ ���������� � �������
        T  = inTimeShifts.';
        xs = SatsPoses(1, :).';
        ys = SatsPoses(2, :).';
        zs = SatsPoses(3, :).';

    % ��������� ���������� ������������
        % ������� ���������� ���������
            xm = mean(xs);
            ym = mean(ys);
            zm = mean(zs);

        % ���������� ������ ����� ����������� ����������� ����� (����) �
        % �����, ����������� ����� ����� � (xm, ym, zm), ���������� ������
        % ����� - ���������������
            Buf = 1/sqrt(xm^2 + ym^2 + zm^2);
            x = 0; 
            y = 0;
            z = 0;
%             x = R*xm*Buf;
%             y = R*ym*Buf;
%             z = R*zm*Buf;

        % ��������� �������� ���������� �� (xm, ym, zm) �� ���� ����������
        % �����
%             d1 = (x-xm)^2 + (y-ym)^2 + (z-zm)^2;
%             d2 = (x+xm)^2 + (y+ym)^2 + (z+zm)^2;
% 
%         % ������� ���������
%             if d2 < d1
%                 x = -x;
%                 y = -y;
%                 z = -z;
%             end

    % ����� �������� �������� ������� A ��� ����� ����������, ������� ��
    % Tj, T � T0 � cTj = c*Tj, cT = c*T � cT0 = c*T0
        % cTj = c*Tj;
        cT = c*T;
        cT0 = c*T0;

    % ���������� � �����    
        % ������������� A � B
            % B = zeros(NumSats, 1); % ������������� �� ���������
            A = zeros(NumSats, 4);
            % A(:, 4) = -c;
            A(:, 4) = -1;

        % ������� ��������
            IterCounter = 0;

        % ���� ������ �� �����
            isStop = false;

%% ��������
    while ~isStop
        % �������� Tj, ��������������� ������� ��������� xs, ys, zs, x, y,
        % z, T0:
            % Tj = sqrt((xs - x).^2 + (ys - y).^2 + (zs - z).^2)/c - T0;
            cTj = sqrt((xs - x).^2 + (ys - y).^2 + (zs - z).^2) - cT0;
        % �������� �������� B
            % B = c*(T - Tj);
            B = cT - cTj;

        % �������� �������� ��������� �������, ������� � �������� ��������
        % ������� A, ��������� ��� �����������.
            % Buf = 1./((Tj + T0)*c);
            Buf = 1./(cTj + cT0);
            A(:, 1) = -(xs - x).*Buf;
            A(:, 2) = -(ys - y).*Buf;
            A(:, 3) = -(zs - z).*Buf;

        % �������� ��������/�������������� ������� � ������� A
            if NumSats == 4
                iA = inv(A);
            else
                iA = pinv(A);
            end

        % ����� �������
            X = iA * B;

        % ������� ������� ��������
            IterCounter = IterCounter + 1;

        % �������� ������ �� �����
            % Delta = sqrt(sum((X.*[1; 1; 1; c]).^2));
            Delta = sqrt(sum(X.^2));
            if (IterCounter > MaxNumIters) || (Delta <= MaxDelta)
                isStop = true;
            else
                % ������� �������� x, y, z, T
                    x  = x  + X(1);
                    y  = y  + X(2);
                    z  = z  + X(3);
                    % T0 = T0 + X(4);
                    cT0 = cT0 + X(4);

                % ������� ���������� ��������� � ������ ������ �������� T0
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

    % �������� �������������� �� cTj, cT � cT0 � Tj, T � T0
        % Tj = cTj/c; % �� �����������
        % T  = cT/c;  % �� �����������
        T0 = cT0/c;

%% ����������� - ������ Lat, Lon, Alt, El, Az
    % ������� ���������� ��������� � ������� ���� ������� ��� �������
    % �������� ��� ���������� Lat, Lon, Alt, El, Az
        SatsPoses = SatsPoses(1:6, :);
        SatsPoses = [SatsPoses; zeros(5, NumSats)];

    % �������������� ��������� �� XYZ � LLA
        % ��� ��������
            [Lat, Lon, Alt] = P74_Cartesian2Spherical([x, y, z]);

        % ��� ���������
%             for k = 1:NumSats
%                 [SatsPoses(7, k), SatsPoses(8, k), SatsPoses(9, k)] = ...
%                     P74_Cartesian2Spherical(SatsPoses(1:3, k));
%             end

    % ������ ����� ��������� � ������� ��� ���������
%         for k = 1:NumSats
%             [SatsPoses(10, k), SatsPoses(11, k)] = ...
%                 P75_CalculateSatElAz(SatsPoses(1:3, k).', [x, y, z]);
%         end

%% ���������� �����������
    % ����������� SatsPoses � �������
        SatsPoses = array2table(SatsPoses.', 'VariableNames', {'x', ...
            'y', 'z', 'xs_k', 'ys_k', 'i_k', 'Lat', 'Lon', 'Alt', 'El', ...
            'Az'});

    % �������� ����������
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