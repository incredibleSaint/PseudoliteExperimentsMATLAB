function CompareUbloxAndFpgaPseudoranges(sv_id, t, tow_ubx, ps_rng_ubx, ...
                                                      doppl_ubx, x_min_val, x_max_val)
c =  2.99792458e8;
diff_ps_rng_ublox = ps_rng_ubx - ps_rng_ubx(:, 1);
diff_doppl_ubx = doppl_ubx - doppl_ubx(:, 1);
% Round ublox data to integer TOW: 
diff_speed = diff(ps_rng_ubx);
delta_time = round(tow_ubx) - tow_ubx -5e-3;
add_psrange = diff_speed' .* delta_time(2 : end);

diff_ps_rng_ublox = diff_ps_rng_ublox(2 : end, :) + add_psrange';
diff_doppl_ubx = diff_doppl_ubx(2 : end, :);
tow_ubx = round(tow_ubx(2 : end));
        
for n = 1 : length(sv_id)
        % Fpga TOW:
        idx = find(t.sv_num == sv_id(n));
        tow_fpga = t.tow(idx);
        curr_del_calc = t.curr_delay_calc(idx);
        curr_clk_cnt  = t.curr_clk_count( idx);
        doppl_calc = t.doppler_calc(idx);

        % Intersect with ublox TOW:
        tow_fpga = round(tow_fpga);%delete this if update_freq ~= 1 Hz
        common_tow = intersect(tow_fpga, tow_ubx);
        
        fpga_idx = ismember(tow_fpga, common_tow);
        ublox_idx = ismember(tow_ubx, common_tow);

        curr_del_calc_comm = curr_del_calc(fpga_idx);
        curr_clk_cnt_comm = curr_clk_cnt(fpga_idx);
        doppl_calc_comm = doppl_calc(fpga_idx);
        tow_fpga_check = tow_fpga(fpga_idx);     
       
        bits_delay = floor(curr_del_calc_comm(idx(1)) / 1e10 / 20e-3);
        theor_delay(n, :) = curr_del_calc_comm / 1e10 * c;
        fpga_delay(n, :) = (bits_delay * 20e-3 + curr_clk_cnt_comm / 250e6) * c;
        doppl_theor(n, :) = doppl_calc_comm;
        
%         diff_secs = fpga_delay_sec - curr_del_calc / 1e10;
        ubx_diff_psrange(n, :) = diff_ps_rng_ublox(ublox_idx, n);
        diff_doppl_ubx_proc(n, :) = diff_doppl_ubx(ublox_idx, n);
        comm_tow(n, :) = common_tow;
end

for i = 1 : length(sv_id)
    legend_text{i} = num2str(sv_id(i));
end


diff_delay_theor = theor_delay - theor_delay(1, :);
diff_doppl_theor = doppl_theor - doppl_theor(1, :);

diff_ubx_theor = ubx_diff_psrange - diff_delay_theor;
diff_ubx_theor = ubx_diff_psrange - diff_delay_theor;
diff_doppl_ubx_theor = -diff_doppl_ubx_proc - diff_doppl_theor;

figure;
title("Diff doppler between ublox and theor, Hz");
plot(comm_tow(1, :), diff_doppl_ubx_theor');
grid on;
leg = legend(legend_text);

plots_num = 3; figure;
x_lims = [379000 381720];
subplot(plots_num, 1, 1);
plot(comm_tow(1, :)', diff_ubx_theor');
grid on;
title("Diff between ublox and theor, met");
xlabel("TOW, sec");
ylabel("(psR_{ubx} - psR_{ubx}(1, :)) - (psR_{theor} - psR_{theor}(1, :)), m");
xlim(x_lims); ylim([-2 2]);

leg = legend(legend_text);

% diff_delay_fpga = fpga_delay - fpga_delay(1, :);
% diff_ubx_fpga = ubx_diff_psrange - diff_delay_fpga;
% figure;
% plot(comm_tow(1, :), diff_ubx_fpga');
% grid on;
% title("Diff between ublox and fpga, met");
% xlabel("TOW, sec");
% ylabel("(psR_{ubx} - psR_{ubx}(1, :)) - (psR_{fpga} - psR_{fpga}(1, :)), m");
% xlim([379e3 381e3]); ylim([-20 30]);
% leg = legend(legend_text);

subplot(plots_num, 1, 2);
res1 = (diff_ubx_theor(:, 2 : end))';
res2 = diff(fpga_delay');
plot(comm_tow(1, 2 : end), res1 ./ res2);
xlim(x_lims); ylim([-0.2 0.2]);
% plot(comm_tow(1, 3 : end), a);

% a = diff(diff((theor_delay(:, 1 : 10 : end))'));
% plot(comm_tow(1, (2 + 10 * 2) : 10 : end), a);


% grid on;
% title("diff(diff(psR_{theor}(1 : 10 : end)))");
% % title("Diff between ublox and theor divide by diff(psR_{theor}), met");
% xlabel("TOW, sec");
% xlim([379e3 381e3]); ylim([-10 20]);
% leg = legend(legend_text);

subplot(plots_num, 1, 3);
plot((comm_tow(1, 2 : end))', diff((theor_delay - theor_delay(1, :))')); 
title("diff(psR_{theor}), m");
xlabel("TOW, sec");
grid on; 
xlim(x_lims); ylim([-600 800]);
leg = legend(legend_text);
