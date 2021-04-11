function UPos = P71_GetOneRXPos(SatPos, inTimeShifts, ...
    SampleNums)
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
        MaxNumIters = 1000;%Params.P71_GetOneRXPos.MaxNumIters;
    % ������������ ��������� ��������� ������������ ����� ���������
    % ���������� (�). ���� ����������� ��������� ������, �� ����
    % ���������������
        MaxDelta = 3; %Params.P71_GetOneRXPos.MaxDelta;
        
    % ������ ���������, �������������� ��� ������� ���������:
    sizeSatPos = size(SatPos);
    satsNum = sizeSatPos(2);
    CurSatNums2Pos = 1:satsNum;

%% ��������� ��������
    % �������� �����, �/�
        c = 299792458;
    % ������ �����, �
        R = 6356863;
    % ������� (m)
    dvMax = 10;
    % ����. ����� �������� �������
    CntMax = 100;

    % Height of orbit (between Earth Surface and satellite) in seconds:
    startInTProp = 0;%0.068;
    % Initial guess about pseudoranges (in sec):
%     initGuess = startInTProp + inTimeShifts;

%     SatPos  = zeros(7, length(Params.CurSatNums2Pos));
%     GPSTime = zeros(1, length(Params.CurSatNums2Pos));
%     TProp   = zeros(1, length(Params.CurSatNums2Pos));
    
% for k = 1 : length(Params.CurSatNums2Pos)
%     Esat = Es{1, k};
%     [SatPos(:, k), GPSTime(k), TProp(k)] = P72_GetSatPos(...
%                                   Esat, inGPSTimes(k), initGuess(k) ...
%                                   , Params);
% end

TPropStart = inTimeShifts;%inGPSTimes - startInTProp;
%-------- Initialisation ----------
% ������� ���������� ���������
xs = SatPos(1, :).';
ys = SatPos(2, :).';
zs = SatPos(3, :).';
xm = mean(xs);
ym = mean(ys);
zm = mean(zs);

% ���������� ������ ����� ����������� ����������� ����� (����) �
% �����, ����������� ����� ����� � (xm, ym, zm), ���������� ������
% ����� - ���������������
Buf = 1/sqrt(xm^2 + ym^2 + zm^2);
           
%             x = R*xm*Buf;
%             y = R*ym*Buf;
%             z = R*zm*Buf;
xU = R*xm*Buf;%2.758e6;%;0;
yU = R*ym*Buf;%1.61e6;%;0;
zU = R*zm*Buf;%5.49e6;%;0;
d1 = (xU-xm)^2 + (yU-ym)^2 + (zU-zm)^2;
d2 = (xU+xm)^2 + (yU+ym)^2 + (zU+zm)^2;

if d2 < d1
    xU = -xU;
    yU = -yU;
    zU = -zU;
end
% xU = 0;
% yU = 0;
% zU = 0;
dv = dvMax * 2;
cnt = 1;
cT0 = c * startInTProp;
% cT  = c * TPropStart;
cT = inTimeShifts;%c * TPropStart;

A = zeros(satsNum, 4);
%----------------------------------
while(dvMax < dv && CntMax > cnt)
    % ���������� ������� ���������� 
    % ����� 
    % �������� ����������� ����� ���������� � ���������������
    %                                         ������������ ������������
    % � 
    % ������� ���������� ������������, ������� ����������� �
    % inTimeShifts (������� ������ ����� ��������� �������� ���������,
    % ������� �������� �� ������ �������):
                       
    cTij = sqrt((SatPos(1, :) - xU) .^ 2 + ...
           (SatPos(2, :) - yU) .^ 2 + (SatPos(3, :) - zU) .^ 2) ...
                                                                    - cT0;
    
    
    Bj = cT - cTij;
    
    A(:, 1) = -(SatPos(1, :)' - xU) ./ (cTij + cT0)'; 
    A(:, 2) = -(SatPos(2, :)' - yU) ./ (cTij + cT0)'; 
    A(:, 3) = -(SatPos(3, :)' - zU) ./ (cTij + cT0)';
    A(:, 4) = -1;
    
    if satsNum == 4
        invA = inv(A);
    else
        invA = pinv(A);
    end
    dNow = invA * Bj.';
    dv = sqrt(sum(dNow .^ 2, 1));
    xU = xU + dNow(1);
    yU = yU + dNow(2);
    zU = zU + dNow(3);
    cT0 = cT0 + dNow(4);
%     for k = 1 : length(Params.CurSatNums2Pos)
% %         TPropNew = (cT0 + c * TPropStart(CurSatNums2Pos(k))) / c;
%         TPropNew = (cT0 + c * TPropStart((k))) / c;
%         OutSatPos = P73_RenewSatPos(SatPos(:, k), TPropNew, Params);
%         SatPos(:, k) = OutSatPos;
%     end
    cnt = cnt + 1;
end

UPos.x = xU;
UPos.y = yU;
UPos.z = zU;
[Lat, Lon, Alt] = P74_Cartesian2Spherical([xU yU zU]);
UPos.Lat = Lat;
UPos.Lon = Lon; 
UPos.Alt = Alt;
UPos.T0 = cT0 / c;
UPos.SampleNums = SampleNums;
UPos.SatPos = SatPos;
UPos.NumIters = cnt;
UPos.inTimeShifts = inTimeShifts;
% UPos.inGPSTimes = inGPSTimes;
