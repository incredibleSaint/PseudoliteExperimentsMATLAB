% close all; 
clear;
cd ..
addpath('Common');
cd PlotGDOP

[Pseudolite, UPos] = GetTopology();
gridValX = -1500 : 100 : 1500;
gridValY = -1500 : 100 : 1500;
[UPos.x, UPos.y] = meshgrid(gridValX, gridValY);

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
[valCol, indCol] = min(min(HDOP))


