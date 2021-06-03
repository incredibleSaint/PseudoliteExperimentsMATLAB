% close all; 
clear;
% load('Res_-1200...-300.mat')
% load('Res_romb_50deg_CN0_45_40_35_(x_-1410 -1210 -600 0  170 440 920 1400,y_ 0).mat')
filename = 'Merged_Res_CN0_55__35_(x_-1410 -1210 -600 0  170 440 920 1400,y_ 0)';
load([filename '.mat'])
f = figure; grid on;
hold on;

CN0 = 55 : -5 : 35;
thrhld = 1000;

for n = 1 : 8
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
        m(k) = mean(err1(idx));
            
    end
    if flagNotDraw
       continue; 
    end    
    plot(CN0, m); 
end
legend('1', '2', '3', '4', '5', '6', '7', '8');
xlabel('CN0, дБ-Гц');
% ylabel('Ошибка определения горизонтальной составляющей, м');
ylabel('{\Delta}R, m');

cd Images
saveas(f, filename);
cd ..