function [fname, rem_last_emp, pos_peak_first] ...
              ...
                       = SignalShaperGPS(time_diff, curr_u_pos, ...
                                         constellation, f_CA, ...
                                         len_CA, sample_freq, bandwidth,...
                                         sig_dur, CN0, delta_f_doppl)
% Generate signal GPS L1 (IQ):
% - Random navigation message 
% - Fix phase of signal
%------- Data Format -------------------------------
data_type = 'int16';
size_int16 = 2;%int16 - 2; double - 8;

% ---- Set Noise level --------
BW = 10 * log10(bandwidth);
SNR = CN0 - BW;%signal-to-noise ratio per sample (in dB)

%---- Duration nav message -------------------------
BIT_RATE = 50;%nav.bits in 1 sec (BDS/GPS: 50 bit/sec)
% Quantity periods of Ranging code in file
% quant_nav_m_bits = 44;% 30 = 30*20 = 600 ms, timeSvUser ~ 70-120 ms
quant_nav_m_bits = ceil(sig_dur * BIT_RATE);
%----------------------------------------
len_discr_ca = sample_freq * len_CA;

ran_codes = zeros(2, len_discr_ca);
NUM_CA_PER_BIT = 20;%quantity of ranging periods in  one NH code
ca_num = NUM_CA_PER_BIT * quant_nav_m_bits;

fname = cell(1, length(constellation));

t_chip = 1 / (sample_freq * f_CA);
pos_peak_first = time_diff / t_chip;

rem_last_emp   = round(pos_peak_first);
t_rem = pos_peak_first - rem_last_emp;
phase_0 = t_rem * 2 * pi;

for idx_sv = 1 : length(constellation)

    code = GenCACode(constellation(idx_sv), 1);
    
    bi_code = Bipolar(code);
    bi_code_dscr = Upsample(bi_code, sample_freq);
    ran_codes(1, :) = bi_code_dscr;
    ran_codes(2, :) = bi_code_dscr * (-1);
    
    sig_dur_1bit = zeros(2, NUM_CA_PER_BIT * len_discr_ca);
    for n = 1 : NUM_CA_PER_BIT
        idx_start = (n - 1) * len_discr_ca + 1;
        idx_finish = n      * len_discr_ca;
        
        sig_dur_1bit(1, idx_start : idx_finish) = ran_codes(1, :);
        sig_dur_1bit(2, idx_start : idx_finish) = ran_codes(2, :);
    end
    nav_m = randi([0 1], 1, quant_nav_m_bits);
    nav_m(end - 50 : end) = 0;

    ones_sampl = ones(1, NUM_CA_PER_BIT);
    ca_mod_inf = zeros(1, ca_num);
     
    sig = zeros(1, rem_last_emp(idx_sv));
    buf = zeros(length(sig) * 2, 1);
    buf(1 : 2 : end) = real(sig);
    buf(2 : 2 : end) = imag(sig);
    
    current_time = fix(clock);
    fname{idx_sv} = [num2str(current_time(1)), '_', ...
           num2str(current_time(2)), '_', num2str(current_time(3)), '_', ...
           num2str(current_time(4)), '_',num2str(current_time(5)), ...
           '_', num2str(current_time(6)),...
           '_CN0_', num2str(CN0), '_', data_type, '_' , 'SamplFreq_', ...
           num2str(sample_freq), '_Sv_', num2str(constellation(idx_sv)), ...
           '__', num2str(curr_u_pos), '.dat'];
    
    fid = fopen(fname{idx_sv}, 'a');
    status = fseek(fid, 0, 'bof');
    fwrite(fid, buf, data_type);
    
    for i = 1 : quant_nav_m_bits
        if nav_m(i) == 0
            chips = sig_dur_1bit(1, :);
        else
            chips = sig_dur_1bit(2, :);
        end
        ch_sig = analog(chips, delta_f_doppl, ...
                                 phase_0(idx_sv), sample_freq, len_CA);
            
%         ch_sig = awgn(ch_sig, SNR + 3, 'measured', 'dB');

        buf = zeros(NUM_CA_PER_BIT * len_discr_ca * 2, 1);% 2 - because 1 channel and signal in file consists from I(0ch)Q(0ch) (each 'int16' is I(0ch) or Q(0ch))
        buf(1 : 2 : end) = int16(real(ch_sig));
        buf(2 : 2 : end) = int16(imag(ch_sig));

        step_shift = (i - 1) * 2 * NUM_CA_PER_BIT * len_discr_ca + rem_last_emp(idx_sv) * 2;% 2 - because 1 channel and signal consists from I(0ch)Q(0ch)
        status = fseek(fid, size_int16 * step_shift, 'bof');%signal_new.txt
        count = fwrite(fid, buf, data_type);
       
    end
    fclose(fid);
end

