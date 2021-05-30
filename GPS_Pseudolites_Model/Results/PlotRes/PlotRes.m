close all; clear;
% load('Res_-1200...-300.mat')
load('Res_0_50_600.mat')
figure; grid on;
hold on;

for n = 1 : 13
    if isempty(Data.Errs{1, n})
        continue
    end
    err2D = Data.Errs{1, n}.err2D;
    m = mean(err2D, 2);
    
    plot(55 : -5 : 35, m);
    
end
legend('1', '2', '3', '4');
xlabel('CN0, дБ/Гц');
ylabel('Ошибка определения горизонтальной составляющей, м');