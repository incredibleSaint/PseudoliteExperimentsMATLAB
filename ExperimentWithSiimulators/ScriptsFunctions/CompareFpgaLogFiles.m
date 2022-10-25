function [] = CompareFpgaLogFiles(t1, t2, time1, time2, prms)
t = {t1 t2};
time = {time1, time2};
files_num = length(t);
sv_id = prms.sv_id;
c = prms.light_speed;
ref_ch = prms.ref_channel;

for k = 1 : files_num
    gnss_idx{k} = find(t{k}.gnss_id == prms.fpga_gnss_id);
    assert_message = ['There is no ' prms.current_gnss ...
                      ' in' prms.fpga_logs{k} ' . Please, check choosed GNSS in Config.m'];
    assert(~isempty(gnss_idx), assert_message);
end


for n = 1 : length(sv_id)
    for k = 1 : files_num
        sv_idx      = find(t{k}.sv_num == sv_id(n));
        idx{k, n}   = intersect(gnss_idx{k}, sv_idx);
        tow_fpga{k} = t{k}.tow(idx{k, n});
    end
    sv_tow{n}  = intersect(tow_fpga{1}, tow_fpga{2});
    tow_len(n) = length(sv_tow{n});
end
[~, sv_num_idx] = min(tow_len);
min_tow = sv_tow{sv_num_idx};
min_tow = min_tow(2 : end);

sv_idx = [];
for n = 1 : length(sv_id)
    for k = 1 : files_num
        for m = 1 : length(min_tow)
            eq_time_str_num = find(t{k}.tow == min_tow(m));
            sv_idx(m) = intersect(eq_time_str_num, idx{k, n});
        end
        assert(sum(sv_idx == 0) == 0, "Zero Tow indexes");
    
        tow_fpga{k}      = t{k}.tow(sv_idx);
        curr_del_calc{k} = t{k}.curr_delay_calc(sv_idx);
        curr_clk_cnt{k}  = t{k}.curr_clk_count(sv_idx);
        doppl_calc{k}    = t{k}.doppler_calc(sv_idx);
        gnss_name{k}     = t{k}.gnss_id(sv_idx);
    end
    
    curr_del_calc_comm1 = curr_del_calc{1};
    curr_clk_cnt_comm1  = curr_clk_cnt{1};
    doppl_calc_comm1    = doppl_calc{1};
    tow_fpga_check1     = tow_fpga{1};
    
    curr_del_calc_comm2 = curr_del_calc{2};
    curr_clk_cnt_comm2  = curr_clk_cnt{2};
    doppl_calc_comm2    = doppl_calc{2};
    tow_fpga_check2     = tow_fpga{2};
    
    bits_delay = floor(curr_del_calc_comm1(2) / 1e10 / prms.nav_mess_bit_duration);
    tow_fpga_arr1(n, :) = tow_fpga_check1;
    theor_delay1(n, :)  = curr_del_calc_comm1 / 1e10 * c;
    fpga_delay1( n, :)  = (bits_delay * prms.nav_mess_bit_duration + ...
                    curr_clk_cnt_comm1 / 250e6) / prms.nav_mess_bit_duration; % todo make bit_duration, clk_freq
    doppl_theor1(n, :)  = doppl_calc_comm1;
    curr_clk_cnt_rem1(n, :) =  rem(curr_clk_cnt_comm1 / 250e6, prms.nav_mess_bit_duration) * c;
    
    bits_delay = floor(curr_del_calc_comm2(2) / 1e10 / prms.nav_mess_bit_duration);
    tow_fpga_arr2(n, :) = tow_fpga_check2;
    theor_delay2(n, :)  = curr_del_calc_comm2 / 1e10 * c;
    fpga_delay2( n, :)  = (bits_delay * prms.nav_mess_bit_duration + ...
                    curr_clk_cnt_comm2 / 250e6) / prms.nav_mess_bit_duration;
    doppl_theor2(n, :)  = doppl_calc_comm2;
    curr_clk_cnt_rem2(n, :) =  rem(curr_clk_cnt_comm2 / 250e6, prms.nav_mess_bit_duration) * c;
end

diff_delay_theor1 = theor_delay1 - theor_delay1(ref_ch, :);
diff_delay_theor2 = theor_delay2 - theor_delay2(ref_ch, :);

diff_hardware_delay = fpga_delay1 - fpga_delay2; 

diff_theor_fpga = diff_delay_theor1 - diff_delay_theor2;

diff_clk_cnt_rem = curr_clk_cnt_rem2 - curr_clk_cnt_rem1;

diff_time = tow_fpga_arr2 - tow_fpga_arr1;

figure;
subplot(4, 1, 1);
obj_p = plot(min_tow, diff_theor_fpga);
title('Diff of calculated pseudoranges, units');


subplot(4, 1, 2);
obj_p = plot(min_tow, diff_hardware_delay');
title('Diff of real  fpga pseudoranges, nav_mess_bits');

subplot(4, 1, 3);
obj_p = plot(min_tow, diff_clk_cnt_rem');
title('Diff of real fpga psRngs remainder, meters');

subplot(4, 1, 4);
obj_p = plot(min_tow, diff_time');
title('Diff time, ms');
end