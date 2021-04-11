close all;
clear;
k = 1.38e-23;
T0 = 300;
EbN0 = 10;
% sense = -148; %dBm
R_dB = 10 * log10(1023);
% -- Pyramide topology -----
d = 8.68;
x = d / tand(60);
S = 1 / 2 * 2 * d * 2 * x;
height = 1;

Pseudolite{1}.x = 0;
Pseudolite{1}.y = x;
Pseudolite{1}.z = height;

Pseudolite{2}.x = d;
Pseudolite{2}.y = 0;
Pseudolite{2}.z = height;

Pseudolite{3}.x = 2 * d;
Pseudolite{3}.y = x;
Pseudolite{3}.z = height;

Pseudolite{4}.x = d;
Pseudolite{4}.y = 0.8 * x;
Pseudolite{4}.z = 3 * height;
%================================
UPos.z = 0;
gridValX = -2 : 0.2 : 20;
gridValY = -2 : 0.2 : 20;
[UPos.x, UPos.y] = meshgrid(gridValX, gridValY);

psSize = size(Pseudolite);
psSizeCol = psSize(2);
Prec_dBW = zeros(1, psSize(2)); % !!!!

sizePoses = size(UPos.x);
PDOP = zeros(size(UPos.x));
GDOP = zeros(size(UPos.x));
HDOP = zeros(size(UPos.x));
VDOP = zeros(size(UPos.x));
visibility = zeros(size(UPos.x));

wgs84 = wgs84Ellipsoid('kilometer');

PseudoliteENU = cell(psSize(1), psSize(2));

for n = 1 : sizePoses(1) * sizePoses(2)
    userECEF.x = UPos.x(n);
    userECEF.y = UPos.y(n);
    userECEF.z = UPos.z;
    for m = 1 : psSize(2)
        Prec_dBW(m) = ComputePower_dBW(Pseudolite{m}, userECEF);
    end
    cnt = 0;
    for m = 1 : psSize(2)
        Prec_dBW = circshift(Prec_dBW, 1);
%         EbN0_exp_dB = Prec_dBW(1) - 10 * log10(k * T0) - ...
%                                                sum(Prec_dBW(2 : 4)) - R_dB;
%                                            
        
%         if (Prec_dBW(1) - 10 * log10(k * T0)  - sum(Prec_dBW(2 : 4)) + R_dB) > -20
        SNR = Prec_dBW(1) / (k*T0 + sum(Prec_dBW(2 : 4)));
        if 10 * log10(SNR) > -30
              cnt = cnt + 1;                                                     
        end
            
%         Prec_dBW(1)
%         Prec_dBW(4) + 80
%         if (Prec_dBW(1) - Prec_dBW(4)) > -30
%             cnt = cnt + 1;
%         end
    end
    if cnt ~= psSize(2)
        visibility(n) = 1;
    end
    
end

figure;
contourf(UPos.x, UPos.y, visibility);
colorbar;