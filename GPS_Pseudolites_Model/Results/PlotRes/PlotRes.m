close all; clear;
% load('Res_-1200...-300.mat')
load('Res_rombus_cell_(0, 1500).mat')
figure; grid on;
hold on;

for n = 1 : 4
    err2D = Data.Errs{1, n}.err2D;
    m = mean(err2D, 2);
    
    plot(55 : -5 : 35, m);
    
end
legend('1', '2', '3', '4');
xlabel('CN0, дБ/Гц');
ylabel('Ошибка определения горизонтальной составляющей, м');