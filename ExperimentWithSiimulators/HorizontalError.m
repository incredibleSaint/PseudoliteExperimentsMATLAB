function HorizontalError(err_3D, h_error, t_3D, t_h, file_name, ...
                         x_min_val, x_max_val)
len_3D = length(err_3D);
len_2D = length(h_error);
min_len = min([len_2D len_3D]);

t_common = intersect(t_3D, t_h);
ind_3D = ismember(t_3D, t_common);
ind_h  = ismember(t_h,  t_common);

err_3D  = err_3D(ind_3D);
h_error = h_error(ind_h);

err_2D = sqrt(err_3D .^ 2 - h_error' .^ 2);

plot(t_common, err_2D);
title("2D Error, m");
xlabel(file_name);
grid on;
xlim([x_min_val x_max_val]); ylim([0 10]);
end

