%close all; clear;
% This script research Near-Far Effect
% (when some pseudolite is'nt seen because of others (not enough power))
% cd ..
% addpath('Common');
% cd PlotGDOP
% [Pseudolite, UPos, topology] = GetTopology();
function [idxVisib, cntVisib] = NearFarEffect(Pseudolite, UPos)

SNR_MIN = -25;

k = 1.38e-23;
T0 = 300;

% UPos.z = 0;
% gridValX = -1500 : 10 : 1500;
% gridValY = -1500 : 10 : 1500;
% 
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);

psSize = size(Pseudolite);

Prec_dBW = zeros(1, psSize(2)); % !!!!

sizePoses = size(UPos.x);

cntVisib = zeros(size(UPos.x));
idxVisib = cell(size(UPos.x));

pointsNum = sizePoses(1) * sizePoses(2); 

for n = 1 : pointsNum
    userECEF.x = UPos.x(n);
    userECEF.y = UPos.y(n);
    userECEF.z = UPos.z;
    for m = 1 : psSize(2)
        Prec_dBW(m) = ComputePower_dBW(Pseudolite{m}, userECEF);
    end
    cnt = 0;
    idxVisibArr = zeros(1, psSize(2));
    for m = 1 : psSize(2)
        Prec_dBW = circshift(Prec_dBW, 1);
        SNR = Prec_dBW(1) / (k * T0 + sum(Prec_dBW(2 : psSize(2))));
        if (10 * log10(SNR) > SNR_MIN)
              cnt = cnt + 1;
              idxVisibArr(psSize(2) - m + 1) = 1;
        end
        
    end
    
    cntVisib(n) = cnt;
    idxVisib{n} = idxVisibArr;
end

s = size(cntVisib);
if s(1) > 1
    figure;
    contourf(UPos.x, UPos.y, cntVisib);
    colorbar;
    grid on;
%     title("Количество видимых спутников");
    xlabel("X, м");
    ylabel("Y, м");
end

end