function PlotElevationAndResidual(sv_id, t, elev, psrange_res, filename, ...
                                    x_min_val, x_max_val)
% Plot [elevations] = degree
%      [pseudorange residuals] = meters
for n = 1 : length(sv_id)
    figure;
    subplot(2, 1, 1);
    title(filename);
    p = plot(t, elev(:, n), '.');
    ylabel("Elev, deg");
    xlim([x_min_val x_max_val]); ylim([-15 90]);
    grid on;
    legend(num2str(sv_id(n)))    

    subplot(2, 1, 2);
    plot(t, psrange_res(:, n), '.');
    ylabel("Resid, met");
    xlim([x_min_val x_max_val]); %ylim([-15 90]);
    grid on;
    legend(num2str(sv_id(n)));
end
end