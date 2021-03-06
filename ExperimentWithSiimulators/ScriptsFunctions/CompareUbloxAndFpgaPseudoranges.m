function CompareUbloxAndFpgaPseudoranges(sv_id, t, res, ...
                                          x_min_val, x_max_val, prms)
c =  2.99792458e8;
ref_ch = prms.ref_channel;

tow_ubx     = res.tow;
ps_rng_ubx  = res.ps_rng;
doppl_ubx   = res.doppl_ubx;
carr_ph_ubx = res.carrier_phase;


%% ublox message frequency is more than 1 Hz:
rounded_t = round(tow_ubx);
un_round_tow = unique(rounded_t);
ind_1hz = zeros(1, length(un_round_tow));
for n = 1 : length(un_round_tow)
    min_diff   = min( abs(tow_ubx - un_round_tow(n)));
    ind        = find(abs(tow_ubx - un_round_tow(n)) == min_diff);
    ind_1hz(n) = ind(1);
end

figure; plot(ps_rng_ubx(:, 4));

% Round ublox data to integer TOW: 
diff_ps_rng_ublox = ps_rng_ubx( ind_1hz, :) - ps_rng_ubx(  ind_1hz, ref_ch);
diff_doppl_ubx    = doppl_ubx(  ind_1hz, :) - doppl_ubx(   ind_1hz, ref_ch);
diff_carr_ph_ubx  = carr_ph_ubx(ind_1hz, :)  - carr_ph_ubx(ind_1hz, ref_ch); 
diff_speed        = diff(ps_rng_ubx(ind_1hz, :));
tow_ubx           = tow_ubx(ind_1hz);

delta_time = round(tow_ubx) - tow_ubx;% + 50e-3;% + 0.0201;% - 5e-3; %+5e-3;
add_psrange = (diff_speed - diff_speed(:, ref_ch))' .* delta_time(2 : end);
data_size = size(add_psrange);

diff_ps_rng_ublox = diff_ps_rng_ublox ;%+ ...
                                        %[zeros(data_size(1), 1) add_psrange]';
tow_ubx = round(tow_ubx);
gnss_idx = find(t.gnss_id == prms.fpga_gnss_id);
assert_message = ['There is no ' prms.current_gnss ...
                  ' in fpga_log.txt. Please, check choosed GNSS in Config.m'];
assert(~isempty(gnss_idx), assert_message);
for n = 1 : length(sv_id)
        % Fpga TOW:
        
        sv_idx = find(t.sv_num == sv_id(n));
        idx = intersect(gnss_idx, sv_idx);
        tow_fpga      = t.tow(idx);
        curr_del_calc = t.curr_delay_calc(idx);
        curr_clk_cnt  = t.curr_clk_count( idx);
        doppl_calc    = t.doppler_calc(   idx);

        % Intersect with ublox TOW:
%         tow_fpga = round(tow_fpga);%delete this if update_freq ~= 1 Hz
        common_tow = intersect(tow_fpga, tow_ubx);
        
        fpga_idx  = ismember(tow_fpga, common_tow);
        ublox_idx = ismember(tow_ubx,  common_tow);

        curr_del_calc_comm = curr_del_calc(fpga_idx);
        curr_clk_cnt_comm   = curr_clk_cnt(fpga_idx);
        doppl_calc_comm      = doppl_calc( fpga_idx);
        tow_fpga_check         = tow_fpga( fpga_idx);     
       
        bits_delay = floor(curr_del_calc_comm(idx(1)) / 1e10 / 20e-3);
        theor_delay(n, :)  = curr_del_calc_comm / 1e10 * c;
        fpga_delay( n, :)  = (bits_delay * 20e-3 + curr_clk_cnt_comm / 250e6) * c;
        doppl_theor(n, :) = doppl_calc_comm;
        
%         diff_secs = fpga_delay_sec - curr_del_calc / 1e10;
        ubx_diff_psrange(n, :)       = diff_ps_rng_ublox(ublox_idx, n);
        diff_doppl_ubx_proc(n, :) = diff_doppl_ubx(     ublox_idx, n);
        comm_tow(n, :) = common_tow;
end

for i = 1 : length(sv_id)
    legend_text{i} = num2str(sv_id(i));
end


diff_delay_theor = theor_delay - theor_delay(ref_ch, :);
diff_doppl_theor = doppl_theor - doppl_theor(ref_ch, :);

diff_ubx_theor = ubx_diff_psrange - diff_delay_theor;

% Test (overamplification psrange) =======
figure; subplot(2, 1, 1);
obj_p = plot(ps_rng_ubx);
obj_p(1).LineWidth = 2;
title("Ublox psrange, m");
subplot(2, 1, 2);
plot(diff_delay_theor');
title("Theor diff_psrange, m");
% Test end ==========================


diff_doppl_ubx_theor = -diff_doppl_ubx_proc - diff_doppl_theor;

plots_num = 2; figure;
subplot(plots_num, 1, 1);
plot(comm_tow(1, :), diff_doppl_ubx_theor');
grid on; leg = legend(legend_text);
title("Diff doppler between ublox and theor, Hz");

subplot(plots_num, 1, 2);
plot(comm_tow(1, :), diff_doppl_theor);
grid on; leg = legend(legend_text);
title("Relative theorethical doppler, Hz");

plots_num = 4; figure;
x_lims = [comm_tow(1, 1) comm_tow(1, end)];% [379000 381720];
subplot(plots_num, 1, 1);
obj_p = plot(comm_tow(1, :)', diff_ubx_theor');
obj_p(1).LineWidth = 2;
grid on;
title("Diff between ublox and theor, met");
xlabel("TOW, sec");
ylabel("(psR_{ubx} - psR_{ubx}(1, :)) - (psR_{theor} - psR_{theor}(1, :)), m");
xlim(x_lims); ylim([-10 10]);
% ylim auto
leg = legend(legend_text);

subplot(plots_num, 1, 2);
obj_p = plot(diff_carr_ph_ubx);
obj_p(1).LineWidth = 2;
title("Diff Carrier phase, cycles");
grid on;
% xlim(x_lims);
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

subplot(plots_num, 1, 3);
res1 = (diff_ubx_theor(:, 2 : end))';
res2 = diff(theor_delay');
obj_p = plot(comm_tow(1, 2 : end), res1 ./ res2);
obj_p(1).LineWidth = 2;
title("diff betw ubx and theor) ./ diff(theor)");
grid on;
xlim(x_lims); %ylim([-0.2 0.2]);
leg = legend(legend_text);

% plot(comm_tow(1, 3 : end), a);

% a = diff(diff((theor_delay(:, 1 : 10 : end))'));
% plot(comm_tow(1, (2 + 10 * 2) : 10 : end), a);


% grid on;
% title("diff(diff(psR_{theor}(1 : 10 : end)))");
% % title("Diff between ublox and theor divide by diff(psR_{theor}), met");
% xlabel("TOW, sec");
% xlim([379e3 381e3]); ylim([-10 20]);
% leg = legend(legend_text);

subplot(plots_num, 1, 4);
plot((comm_tow(1, 2 : end))', diff((theor_delay - theor_delay(1, :))')); 
title("diff(psR_{theor}), m");
xlabel("TOW, sec");
grid on; 
xlim(x_lims); 
 ylim([-1000 1000]);
leg = legend(legend_text);

