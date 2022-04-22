function  PlotCoordsError(t, x, y, z, true_pos)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    err_x = x - true_pos(1);
    err_y = y - true_pos(2);
    err_z = z - true_pos(3);

    plot(t, [err_x; err_y; err_z]');
    grid on;
    title("ECEF Errors, m");
    legend('x', 'y', 'z');
end

