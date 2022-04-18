function HorizontalError(err_3D, h_error,  t, file_name)

len_3D = length(err_3D);
len_2D = length(h_error);
min_len = min([len_2D len_3D]);

err_2D = sqrt(err_3D(1 : min_len) .^ 2 - h_error(1 : min_len)' .^ 2);

% figure; 
plot(t(1 : min_len), err_2D);
title("2D Error, m");
xlabel(file_name);
grid on;
end

