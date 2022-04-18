function  PlotCoordsError(t, x, y, z, true_pos)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    err_x = x - true_pos(1);
    err_y = y - true_pos(2);
    err_z = z - true_pos(3);
    len = length(t);
    plot(t, [err_x(1 : len); err_y(1 : len); err_z(1 : len)]');
    grid on;
    title("ECEF Errors, m");
    legend('x', 'y', 'z');
end

