function [UPos, err] = FindRecPosition(SatPoses, LRepToUser)

%% УСТАНОВКА КОНСТАНТ
    % Скорость света, м/с
        c = 299792458;
    % Радиус Земли, м
        R = 6356863;
    % Невязка (m)
    dvMax = 0.1;
    % Макс. число операций расчета
    CntMax = 100;

    % Height of orbit (between Earth Surface and satellite) in seconds:
    startInTProp = 0;%0.068;
    % Initial guess about pseudoranges (in sec):
%     initGuess = startInTProp + inTimeShifts;

%     SatPos  = zeros(7, length(Params.CurSatNums2Pos));
%     GPSTime = zeros(1, length(Params.CurSatNums2Pos));
%     TProp   = zeros(1, length(Params.CurSatNums2Pos));
%     
% for k = 1 : length(Params.CurSatNums2Pos)
%     Esat = Es{1, k};
%     [SatPos(:, k), GPSTime(k), TProp(k)] = P72_GetSatPos(...
%                                   Esat, inGPSTimes(k), initGuess(k) ...
%                                   , Params);
% end

% TPropStart = TProp - startInTProp;
%-------- Initialisation ----------
usOrig = [ 2.758658132707859e+06 ...
           1.617358627867161e+06 ...
           5.500122591801262e+06 ];
% 2.758658132707859
%    1.617358627867161
%    5.500122591801262
xU = 2.758658132707859e6;%;0;
yU = 1.617358627867161e6;%;0;
zU = 5.500122591801262e6;%;0;
dv = dvMax * 2;
cnt = 1;
% cT0 = c * startInTProp;
% cT  = c * TPropStart;

% sizeSatPos = size(SatPos);
% satsNum = sizeSatPos(2);
%-----------------
sizeRng = size(LRepToUser);
satsNum = sizeRng(2);
% LRepToUser = [0.199999999999983   1.199999999999897   0.400000000000257   0.600000000000157  0.8] * 1e3;
%;[2000 12000 4000 6000 8000];
cT = LRepToUser - LRepToUser(1);
cT0 = 0;
SatPos = [];
SatPos = SatPoses;
% load('PseudoliteCorrdinates.mat');

% sv_coord = [   
%   2.758818295914609   2.758201013375015   2.758861177420232   2.758855639906060   2.759388940148959;
%    1.617459797917240   1.616440043733785   1.617596765453138   1.617003202809395   1.617140768005656;
%    5.500058464052429   5.500744882011253   5.500371716940343   5.500563799161775   5.500364371793773];
% sv_coord = sv_coord * 1.0e+06;
% 
% 
% % cT = sv_coord(4, 1 : satsNum);
% % cT = cT - cT(1);
% for k = 1 : satsNum
%     SatPos(1, k) = sv_coord(1, k);%PseudoCoord.Rep(k).X;
%     SatPos(2, k) = sv_coord(2, k);%PseudoCoord.Rep(k).Y;
%     SatPos(3, k) = sv_coord(3, k);%PseudoCoord.Rep(k).Z;
% end


%%----------
xs = SatPos(1, :).';
ys = SatPos(2, :).';
zs = SatPos(3, :).';

% Начальные координаты пользователя
% Средние координаты спутников
    xm = mean(xs(1 : satsNum));
    ym = mean(ys(1 : satsNum));
    zm = mean(zs(1 : satsNum));

    xU = xm;
    yU = ym;
    zU = zm;
% xU = 2.758658132707859e6;%;0;
% yU = 1.617358627867161e6;%;0;
% zU = 5.500122591801262e6;%;0;
%------------
%-----------------
A = zeros(satsNum, 4);
while(dvMax < dv && CntMax > cnt)
    % Рассчитаем разницу расстояний 
    % между 
    % текущими дальностями между спутниками и предполагаемыми
    %                                         координатами пользователя
    % и 
    % текущей постоянной составляющей, которая добавляется к
    % inTimeShifts (разницы времен между приходами сигналов спутников,
    % которые узнаются из самого сигнала):
                       
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
    dv  = sqrt(sum(dNow .^ 2, 1));
    xU  = xU + dNow(1);
    yU  = yU + dNow(2);
    zU  = zU + dNow(3);
    cT0 = cT0 + dNow(4);
%     for k = 1 : length(Params.CurSatNums2Pos)
% %         TPropNew = (cT0 + c * TPropStart(CurSatNums2Pos(k))) / c;
%         TPropNew = (cT0 + c * TPropStart((k))) / c;
%         OutSatPos = P73_RenewSatPos(SatPos(:, k), TPropNew, Params);
%         SatPos(:, k) = OutSatPos;
%     end
    cnt = cnt + 1;
end

UPos = [xU yU zU];
errSmart = sqrt(sum((UPos - usOrig).^2))
err = sqrt((UPos(1) - usOrig(1))^2 + (UPos(2) - usOrig(2)).^2 + (UPos(3) - usOrig(3)).^2)
if isnan(err)
   fprintf("\n FindRecPositioin.m: err = NaN \n");
end
end