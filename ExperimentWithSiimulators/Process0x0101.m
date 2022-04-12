function [err_3D, t] = Process0x0101(Mes0x0101,    ...
                                                                  true_position, ...
                                                                  file_name)

struct_size = size(Mes0x0101);
mess_num = struct_size(2);

for k = 1 : mess_num
    Mes  = Mes0x0101{k};
    t(k) = Mes.tow;
    x(k) = double(Mes.x_ecef) * 1e-2;
    y(k) = double(Mes.y_ecef) * 1e-2;
    z(k) = double(Mes.z_ecef) * 1e-2;
    acc(k) = Mes.acc * 1e-2;
end

pos_ubx = [x' y' z'];
err_3D = sqrt(sum((pos_ubx - true_position) .^ 2, 2));

figure;
plot(t, err_3D);
title("3D Error, m"); grid on;
xlabel(file_name);

% figure; 
% plot(t, acc);
% title("3D Accuracy, m");
% grid on;
end