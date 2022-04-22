function [h_error, t] = Process0x0102(Mes0x0102, true_position, file_name, ...
                                    x_min_val, x_max_val)
struct_size = size(Mes0x0102);
mess_num = struct_size(2);

for k = 1 : mess_num
    Mes  = Mes0x0102{k};
    t(k) = Mes.tow;
    lon(k) = double(Mes.lon) * 1e-7;
    lat(k) = double(Mes.lat) * 1e-7;
    h(k) = double(Mes.height) * 1e-3;
    h_msl(k) = double(Mes.height_msl) * 1e-3;
end

[lat, lon, h_true] = ecef2geodetic(wgs84Ellipsoid('meter'), ...
                                   true_position(1), ...
                                   true_position(2), ...
                                   true_position(3));
ind = intersect(find(t >= x_min_val), find(t <= x_max_val));
t   = t(ind);
h   = h(ind);

h_error = h - h_true;
plot(t, abs(h_error)); 
title("Height Error (abs), m"); 
grid on; xlabel(file_name);
xlim([x_min_val x_max_val]); ylim([0 20]);
end