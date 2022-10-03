function [] = CompareUbloxFiles(prms, raw_measure1, raw_measure2)
ref_ch = prms.ref_channel;

tow_ubx1     = raw_measure1.tow;
ps_rng_ubx1  = raw_measure1.ps_rng;
doppl_ubx1   = raw_measure1.doppl_ubx;
carr_ph_ubx1 = raw_measure1.carrier_phase;

tow_ubx2     = raw_measure2.tow;
ps_rng_ubx2  = raw_measure2.ps_rng;
doppl_ubx2   = raw_measure2.doppl_ubx;
carr_ph_ubx2 = raw_measure2.carrier_phase;

tow1_int = round(tow_ubx1);
tow2_int = round(tow_ubx2);




%% Sort to 1 Hz
un_round_tow = unique(tow1_int);
ind_1hz = zeros(1, length(un_round_tow));
for n = 1 : length(un_round_tow)
    min_diff   = min( abs(tow_ubx1 - un_round_tow(n)));
    ind        = find(abs(tow_ubx1 - un_round_tow(n)) == min_diff);
    ubx1_ind_1hz(n) = ind(1);
end
un_round_tow = unique(tow2_int);
ind_1hz = zeros(1, length(un_round_tow));
for n = 1 : length(un_round_tow)
    min_diff   = min( abs(tow_ubx2 - un_round_tow(n)));
    ind        = find(abs(tow_ubx2 - un_round_tow(n)) == min_diff);
    ubx2_ind_1hz(n) = ind(1);
end

tow1 = tow_ubx1(ubx1_ind_1hz);
tow2 = tow_ubx2(ubx2_ind_1hz);

psrng1   = ps_rng_ubx1( ubx1_ind_1hz, :);
carr_ph1 = carr_ph_ubx1(ubx1_ind_1hz, :);
doppl1   = doppl_ubx1(  ubx1_ind_1hz, :);

psrng2   = ps_rng_ubx2( ubx2_ind_1hz, :);
carr_ph2 = carr_ph_ubx2(ubx2_ind_1hz, :);
doppl2   = doppl_ubx2(  ubx2_ind_1hz, :);

delta_time1 = round(tow1) - tow1;
cycle_speed = diff(carr_ph1);
add_cycles = (cycle_speed - cycle_speed(:, ref_ch)) .* ...
                delta_time1(2 : end)' .* (doppl1(2 : end, :));% - doppl1(2 : end, ref_ch));
data_size = size(add_cycles);

carr_ph1 = carr_ph1 + ...
                              [zeros(1, data_size(2)); add_cycles];

delta_time2 = round(tow2) - tow2;
cycle_speed = diff(carr_ph2);
add_cycles = (cycle_speed - cycle_speed(:, ref_ch)) .* ...
                delta_time2(2 : end)' .* (doppl2(2 : end, :));% - doppl2(2 : end, ref_ch));
data_size = size(add_cycles);

carr_ph2 = carr_ph2 + ...
                              [zeros(1, data_size(2)); add_cycles];

tow1_int = round(tow1);
tow2_int = round(tow2);

%% Find values with the same time:
    comm_tow = intersect( tow1_int, tow2_int);
    
    ublox1_idx = ismember(tow1_int, comm_tow);
    ublox2_idx = ismember(tow2_int, comm_tow);
    
    ps_rng1 = psrng1(ublox1_idx, :);
    ps_rng2 = psrng2(ublox2_idx, :);

    carr_ph1 = carr_ph1(ublox1_idx, :);
    carr_ph2 = carr_ph2(ublox2_idx, :);

    doppl1 = doppl1(ublox1_idx, :);
    doppl2 = doppl2(ublox2_idx, :);

%% Calculate 
    diff_ps_rng1 = ps_rng1 - ps_rng1(:, ref_ch);
    diff_ps_rng2 = ps_rng2 - ps_rng2(:, ref_ch);

    diff_carr_ph1 = carr_ph1 - carr_ph1(:, ref_ch);
    diff_carr_ph2 = carr_ph2 - carr_ph2(:, ref_ch);

    diff_doppl1 = doppl1 - doppl1(:, ref_ch);
    diff_doppl2 = doppl2 - doppl2(:, ref_ch);

    for i = 1 : length(prms.sv_id)
        legend_text{i} = num2str(prms.sv_id(i));
    end
    
    
    figure;
    plots_num = 4;
    subplot(plots_num, 1, 1);
    diff_of_diff_ps_rng = diff_ps_rng2 - diff_ps_rng1;
    obj_p = plot(comm_tow, diff_of_diff_ps_rng);
    obj_p(1).LineWidth = 2;
    title("Diff PsRanges, m");
    grid on;
    xlim([min(comm_tow) max(comm_tow)]);
    ylim([-10 10]);
    legend(legend_text);

    subplot(plots_num, 1, 2);
    second_diff = diff_carr_ph2 - diff_carr_ph1;
    obj_p = plot(comm_tow, second_diff - second_diff(6, :));
    obj_p(1).LineWidth = 2;
    title("Diff carr phase, cycles");
    grid on;
    xlim([min(comm_tow) max(comm_tow)]);
%     ylim([-10 10]);
    legend(legend_text);


    subplot(plots_num, 1, 3);
    obj_p = plot(comm_tow, diff_doppl2 - diff_doppl1);
    obj_p(1).LineWidth = 2;
    title("Diff doppler, Hz");
    grid on;
    xlim([min(comm_tow) max(comm_tow)]);
    ylim([-10 10]);
    legend(legend_text);

    subplot(plots_num, 1, 4);
    a = diff(diff_ps_rng1);
    obj_p = plot(comm_tow(2 : end), a);
    obj_p(1).LineWidth = 2;
    title("Diff of real ps_rng, m");
    grid on;
    xlim([min(comm_tow) max(comm_tow)]);
%     ylim([-1 10]);
    legend(legend_text);
    
%     obj_p = plot(comm_tow, diff_of_diff_ps_rng - )
    
end