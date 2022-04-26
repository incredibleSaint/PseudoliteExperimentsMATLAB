function  PlotCoordsError(t, x, y, z, true_pos, x_min_val, x_max_val)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    err_x = x - true_pos(1);
    err_y = y - true_pos(2);
    err_z = z - true_pos(3);

    plot(t, [err_x; err_y; err_z]');
    grid on;
    title("ECEF Errors, m");
    legend('x', 'y', 'z');
    xlim([x_min_val x_max_val]); ylim([-15 15]);
end

