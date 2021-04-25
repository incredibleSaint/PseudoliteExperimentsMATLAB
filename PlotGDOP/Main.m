close all; 
clear;
% Cube Topology:

% ---- Receiver Positions --------

% cubeLength = 1000;
% Pseudolite{1}.x = cubeLength;
% Pseudolite{1}.y = cubeLength;
% Pseudolite{1}.z = cubeLength;
% 
% Pseudolite{2}.x = 0;
% Pseudolite{2}.y = cubeLength;
% Pseudolite{2}.z = cubeLength;
% 
% Pseudolite{3}.x = 0;
% Pseudolite{3}.y = 0;
% Pseudolite{3}.z = cubeLength;
% 
% Pseudolite{4}.x = cubeLength;
% Pseudolite{4}.y = 0;
% Pseudolite{4}.z = cubeLength;



%-------------------------------

% ---- Rombus topology --- 

% d = 8.68;
% x = d / tand(60);
% S = 1 / 2 * 2 * d * 2 * x;
% height = 1;
% 
% Pseudolite{1}.x = 0;
% Pseudolite{1}.y = x;
% Pseudolite{1}.z = height;
% 
% Pseudolite{2}.x = d;
% Pseudolite{2}.y = 0;
% Pseudolite{2}.z = height;
% 
% Pseudolite{3}.x = 2 * d;
% Pseudolite{3}.y = x;
% Pseudolite{3}.z = height;
% 
% Pseudolite{4}.x = d;
% Pseudolite{4}.y = 2 * x;
% Pseudolite{4}.z = height;
% 
% 
% % ----- UserPosition -----------
% UPos.z = 0;
% gridValX = 0 +2 : 0.1 : 2 * d -4;
% gridValY = 0 : 0.1 : 2 * x;
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);

% -- Pyramide topology -----
d = 10;
x = d / tand(60);
S = 1 / 2 * 2 * d * 2 * x;
height = 10;

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

%----- UserPosition -----------
UPos.z = 0;
gridValX = 0 +2 : 0.1 : 2 * d -4;
gridValY = 0 : 0.1 : 2 * x;
[UPos.x, UPos.y] = meshgrid(gridValX, gridValY);

%===========================

psSize = size(Pseudolite);
psSizeCol = psSize(2);

sizePoses = size(UPos.x);
PDOP = zeros(size(UPos.x));
GDOP = zeros(size(UPos.x));
HDOP = zeros(size(UPos.x));
VDOP = zeros(size(UPos.x));
wgs84 = wgs84Ellipsoid('kilometer');

PseudoliteENU = cell(psSize(1), psSize(2));

for n = 1 : sizePoses(1) * sizePoses(2)
    userECEF.x = UPos.x(n);
    userECEF.y = UPos.y(n);
    userECEF.z = UPos.z;
    [lat, lon, h] = ecef2geodetic(wgs84, UPos.x(n), UPos.y(n), UPos.z, ...
                                                                'radians');
    UserENU = ECEFtoENU(userECEF, userECEF, lon, lat);
    
    for m = 1 : psSize(2)
        PseudoliteENU{m} = ECEFtoENU(Pseudolite{m}, userECEF, lon, lat);
    end
        
    [GDOP(n), PDOP(n), HDOP(n), VDOP(n)] = CalculateGDOP(PseudoliteENU, ...
                                                                UserENU);                                                
end


figure;
contourf(UPos.x, UPos.y, GDOP, 20);
title("GDOP");
xlabel("X, м");
ylabel("Y, м");
colorbar;

figure;
contourf(UPos.x, UPos.y, PDOP, 20);
title("PDOP");
xlabel("X, м");
ylabel("Y, м");
colorbar;

figure;
contourf(UPos.x, UPos.y, VDOP, 20);
title("VDOP"); 
xlabel("X, м");
ylabel("Y, м");
colorbar;

figure;
contourf(UPos.x, UPos.y, HDOP, 20);
title("HDOP");
xlabel("X, м");
ylabel("Y, м");
colorbar;

[valStr, indStr] = min(min(HDOP, [], 2));
[valCol, indCol] = min(min(HDOP));

