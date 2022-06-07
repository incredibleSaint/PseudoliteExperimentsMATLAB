function ubx_log = GetUbxLogFileName()

%% ========== Fpga counter for time ========
%%             GPS
% ubx_log = 'gps_fpga_cntr_check'; % -8 ms error
% ubx_log = 'gps_fpga_cntr_check_2';
% ubx_log = 'gps_cntr_without_tropo_only_full_iono';
% ubx_log = 'gps_cntr_without_tropo_only_full_iono_2';
% % ubx_log ='gps_check_with_cntr_commit_hash_cbb16b6d';
% % ubx_log = 'gps_commit_d88b87a8';
% ubx_log = 'gps_bds_with_logger_v1';
% % ubx_log = 'gps_bds_with_logger_v3';
% ubx_log  = 'gps_bds_with_logger_v4';
% ubx_log = 'bds_with_logger_v6_all_gnss_position';
% 
% 
% %% Beidou
% % ubx_log = 'beidou_new_mess';
% ubx_log = 'bds_nav_mess_skip_bits_plus_one';
% ubx_log = 'bds_withoou_ionosph';
% ubx_log = 'bds_startcounter_plus_20ms';

%% glonass 
ubx_log = 'glonass_right_set_freq';
ubx_log = 'glonass_right_log';
% ubx_log = 'glonass_calc_without_t_propag';
% ubx_log = 'glonass_calc_plus_t_propag';
% ubx_log = 'glonass_calc_minus_t_propag';
% ubx_log = 'glonass_calc_minus_t_propag_v2';
% ubx_log = 'glonass_fix_nav_bit_dur';
% ubx_log = 'glonass_without_ch_2';
ubx_log = 'glonass_around_t_b';
% ubx_log = 'gln_around_tb_v2';
% ubx_log = 'glonass_t_b_minus_800sec';

end