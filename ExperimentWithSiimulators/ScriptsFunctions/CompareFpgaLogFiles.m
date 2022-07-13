function [] = CompareFpgaLogFiles(t1, t2, time1, time2, prms)
t = {t1 t2};
time = {time1, time2};
files_num = length(t);
sv_id = prms.sv_id;
c = prms.light_speed;
ref_ch = prms.ref_channel;


for k = 1 : files_num
    gnss_idx = find(t{k}.gnss_id == prms.fpga_gnss_id);
    assert_message = ['There is no ' prms.current_gnss ...
                      ' in' prms.fpga_logs{k} ' . Please, check choosed GNSS in Config.m'];
    assert(~isempty(gnss_idx), assert_message);
end

for n = 1 : length(sv_id)
    for k = 1 : files_num
        sv_idx = find(t{k}.sv_num == sv_id(n));
        idx{k} = intersect(gnss_idx, sv_idx);
        tow_fpga{k}      = t{k}.tow(idx{k});
        curr_del_calc{k} = t{k}.curr_delay_calc(idx{k});
        curr_clk_cnt{k}  = t{k}.curr_clk_count( idx{k});
        doppl_calc{k}    = t{k}.doppler_calc(   idx{k});
    end

    common_tow = intersect(tow_fpga{1}, tow_fpga{2});

   file1_idx = ismember(tow_fpga{1}, common_tow);
   file2_idx = ismember(tow_fpga{1}, common_tow);

    curr_del_calc_comm1 = curr_del_calc{1}(file1_idx);
    curr_clk_cnt_comm1  = curr_clk_cnt{1}(file1_idx);
    doppl_calc_comm1    = doppl_calc{1}(file1_idx);
    tow_fpga_check1     = tow_fpga{1}(file1_idx);

    curr_del_calc_comm2 = curr_del_calc{2}(file2_idx);
    curr_clk_cnt_comm2  = curr_clk_cnt{2}(file2_idx);
    doppl_calc_comm2    = doppl_calc{2}(file2_idx);
    tow_fpga_check2     = tow_fpga{2}(file2_idx);

    bits_delay = floor(curr_del_calc_comm1(idx{1}(1)) / 1e10 / 20e-3);
    theor_delay1(n, :)  = curr_del_calc_comm1 / 1e10 * c;
    fpga_delay1( n, :)  = (bits_delay * 20e-3 + curr_clk_cnt_comm1 / 250e6) * c;
    doppl_theor1(n, :) = doppl_calc_comm1;

    bits_delay = floor(curr_del_calc_comm2(idx{2}(2)) / 1e10 / 20e-3);
    theor_delay2(n, :)  = curr_del_calc_comm2 / 1e10 * c;
    fpga_delay2( n, :)  = (bits_delay * 20e-3 + curr_clk_cnt_comm2 / 250e6) * c;
    doppl_theor2(n, :) = doppl_calc_comm2;

    comm_tow(n, :) = common_tow;
end

diff_delay_theor1 = theor_delay1 - theor_delay1(ref_ch, :);
diff_delay_theor2 = theor_delay2 - theor_delay2(ref_ch, :);

diff_hardware_delay = fpga_delay1 - fpga_delay2; 

diff_theor_fpga = diff_delay_theor1 - diff_delay_theor2;
figure;
subplot(2, 1, 1);
obj_p = plot(comm_tow(1, :), diff_theor_fpga);


subplot(2, 1, 2);
obj_p = plot(comm_tow(1, :), diff_hardware_delay');
