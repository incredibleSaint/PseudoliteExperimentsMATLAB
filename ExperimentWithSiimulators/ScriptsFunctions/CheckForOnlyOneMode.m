function [modes] = CheckForOnlyOneMode(modes)
v(1) = modes.visualize_ublox_log;
v(2) = modes.compare_ublox_and_fpga;
v(3) = modes.compare_ublox_files;
v(4) = modes.compare_fpga_files;
non_zero_modes = find(v ~= 0);
first_non_zero = non_zero_modes(1);
v = zeros(1, length(v));
v(first_non_zero) = 1;

modes.visualize_ublox_log = v(1);
modes.compare_ublox_and_fpga = v(2);
modes.compare_ublox_files = v(3);
modes.compare_fpga_files = v(4);
end