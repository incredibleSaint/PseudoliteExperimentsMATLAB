%close all; clear;

cd ..
addpath('Common');
cd PlotGDOP
[Pseudolite, UPos, topology] = GetTopology();

SNR_MIN = -25;

k = 1.38e-23;
T0 = 300;

UPos.z = 0;
gridValX = -1500 : 10 : 1500;
gridValY = -1500 : 10 : 1500;
[UPos.x, UPos.y] = meshgrid(gridValX, gridValY);

psSize = size(Pseudolite);
% psSizeCol = psSize(2);
Prec_dBW = zeros(1, psSize(2)); % !!!!

sizePoses = size(UPos.x);
PDOP = zeros(size(UPos.x));
GDOP = zeros(size(UPos.x));
HDOP = zeros(size(UPos.x));
VDOP = zeros(size(UPos.x));
visibility = zeros(size(UPos.x));
cntVisib = zeros(size(UPos.x));

% wgs84 = wgs84Ellipsoid('kilometer');

% PseudoliteENU = cell(psSize(1), psSize(2));
pointsNum = sizePoses(1) * sizePoses(2); 

for n = 1 : pointsNum
    userECEF.x = UPos.x(n);
    userECEF.y = UPos.y(n);
    userECEF.z = UPos.z;
    for m = 1 : psSize(2)
        Prec_dBW(m) = ComputePower_dBW(Pseudolite{m}, userECEF);
    end
    cnt = 0;
    for m = 1 : psSize(2)
        SNR = Prec_dBW(1) / (k * T0 + sum(Prec_dBW(2 : 23)));
        if 10 * log10(SNR) > SNR_MIN
              cnt = cnt + 1;                                                     
        end
        Prec_dBW = circshift(Prec_dBW, 1);
    end
    if cnt < 16%~= psSize(2)
        visibility(n) = 1;
    end
    cntVisib(n) = cnt;
    
end

figure;
contourf(UPos.x, UPos.y, visibility);
colorbar;

figure;
contourf(UPos.x, UPos.y, cntVisib);
colorbar;
grid on;