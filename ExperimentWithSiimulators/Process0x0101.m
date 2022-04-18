function [err_3D, t, x, y, z] = Process0x0101(Mes0x0101,    ...
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

% figure;
plot(t, err_3D);
title("3D Error, m"); grid on;
xlabel(file_name);

Params = Setup();

%% Export Results to *.kml (receiver gnss chip position)
kml_filename = [file_name '.kml'];
% First point is true position
pos.x = true_position(1); 
pos.y = true_position(2);
pos.z = true_position(3);
[pos.Lat, pos.Lon, pos.Alt] = P74_Cartesian2Spherical([pos.x pos.y pos.z]);
RxPoses{1, 1} = pos;

% Experimental Results
cnt = 0;
for k = 1 : 20 : mess_num
    pos.x = x(k); pos.y = y(k); pos.z = z(k);
    [pos.Lat, pos.Lon, pos.Alt] = P74_Cartesian2Spherical([pos.x pos.y pos.z]);
    cnt = cnt + 1;
    RxPoses{1, cnt +1} = pos;
end

cd ./Results;
P76_ExportResults(RxPoses, kml_filename);
cd ..

% figure; 
% plot(t, acc);
% title("3D Accuracy, m");
% grid on;
end