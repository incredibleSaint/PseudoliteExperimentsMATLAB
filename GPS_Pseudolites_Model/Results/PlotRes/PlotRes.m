% close all; 
clear;
% load('Res_-1200...-300.mat')
% load('Res_romb_50deg_CN0_45_40_35_(x_-1410 -1210 -600 0  170 440 920 1400,y_ 0).mat')
% filename = 'Merged_Res_CN0_55__35_(x_-1410 -1210 -600 0  170 440 920 1400,y_ 0)';
filename = 'Res_45degree romb';% good
% filename = 'Res_0_50_600';
load([filename '.mat'])
f = figure; grid on;
hold on;

CN0 = 55 : -5 : 35;
thrhld = 3000;

sizeRes = size(Data.Errs);
% legend_text = cell(1, sizeRes(2));
cntPlot = 0;

for n = 1 : sizeRes(2)
    flagNotDraw = 0;
    if isempty(Data.Errs{1, n})
        continue
    end
    err2D = Data.Errs{1, n}.err2D;
    ss = size(err2D);
    for k = 1 : ss(1)
        err1 = err2D(k, :);
        idx = (err1 < thrhld);
        if ~sum(idx) % empty array
            flagNotDraw = 1;
            break;
        end
        buf = err1(idx);
        m(k) = sqrt(mean(buf .^ 2));
    end
    if flagNotDraw
       continue; 
    end
    plot(CN0, m);
    cntPlot = cntPlot + 1;
    legend_text{cntPlot} = num2str(Data.Errs{1, cntPlot}.sv_num);
end
 
leg = legend(legend_text);
title(leg, 'Число псевдолитов');


% leg = legend('16', '16', '16', '16', '16', '16', '16','7', '7');
% title(leg, 'Число псевдолитов');
xlabel('CN0, дБ-Гц');
ylabel('СКО измерения положения, м');
% ylabel('{\Delta}R, м');

cd Images
saveas(f, filename);
cd ..