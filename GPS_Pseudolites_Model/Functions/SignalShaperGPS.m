function [filenameForWriting, rem_last_emp, posPeakOrig, ShiftZero, ...
                                            RealTimeOfPeak, pos_peak_first] ...
                       = SignalShaperGPS(time_diff, curr_u_pos, ...
                                         constellation, f_CA,...
                                         len_CA, sample_freq, bandwidth,...
                                         sig_dur, CN0, delta_f_doppl)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%--Message Duration---
% dur_mess = 1;%sec
%--Date----
% Year = 2018;
% Month = 1;
% Day = 1;
% Hour = 10;
% Min = 0;
% Sec = 0;

%--------------------------------------
DataType = 'int16';
bytesIn1Data = 2;%int16 - 2; double - 8;
%--------------------------------------
% Set Noise level:
% CN0 = 49;% dB-Hz
BW = 10 * log10(bandwidth);
SNR = CN0 - BW;%signal-to-noise ratio per sample (in dB)
% SNR = 0;% temporary
%-------------------------------
nav_bitsBitRate = 50;%nav.bits in 1 sec 
% Quantity periods of Ranging code in file
% quant_nav_m_bits = 44;% 30 = 30*20 = 600 ms, timeSvUser ~ 70-120 ms
quant_nav_m_bits = ceil(sig_dur * nav_bitsBitRate);
%-------------------------------
% Enter No. satellite and their f_doppl

% constellation = [   12   10   15  5     2  ];
% array_of_doppl = [-2500 -564 3000 1000 -500  ];
%---Sampling Frequency-----
% sample_freq = 2;


%-----------------------


ran_codes = zeros(length(constellation)*2, sample_freq*len_CA);
periods_of_r_c = 20;%quantity of ranging periods in  one NH code
% date = [Year,Month,Day,Hour,Min,Sec];
% filenameForWriting = zeros(1,)length(constellation);
filenameForWriting = cell(1,length(constellation));
rem_last_emp = zeros(1,length(constellation));
ShiftZero = zeros(1,length(constellation));
QuantityOfIntegerMillisec = zeros(1,length(constellation));
TimeRemain = zeros(1,length(constellation));
TimeOfBlockDataOfArrivalRCInFile = zeros(1,length(constellation));% 1 ms = 1e-3 = Period of C/A code 
RealTimeOfPeak = zeros(1,length(constellation));
posPeakOrig = zeros(1,length(constellation));

t_chip = 1 / (sample_freq * f_CA);
pos_peak_first = time_diff / t_chip;

rem_last_emp   = round(pos_peak_first);
% t_rem = rem(time_diff, t_chip);
t_rem = pos_peak_first - rem_last_emp;
%                     Phase0 = (rem(RealTimeOfPeak(j),1e-3/len_CA)*2*pi)/(1e-3/len_CA);
phase_0 = t_rem * 2 * pi;

for j = 1 : length(constellation)
    %----------------------------------------
    %File with result signal
    current_time = fix(clock);
    filenameForWriting{j} = [num2str(current_time(1)),'_',num2str(current_time(2)),'_',num2str(current_time(3)),'_',num2str(current_time(4)),'_',num2str(current_time(5)),'_',num2str(current_time(6)),...
    '_CN0_',num2str(CN0),'_',DataType,'_','SamplFreq_',num2str(sample_freq),'_Sv_',num2str(constellation(j)),'ByteShiftToFindSat100%_24396372', '_', num2str(curr_u_pos),'.dat'];
   
    code = GenCACode(constellation(j), 1);
    
    bi_code = bipolar( code );
    bi_codeX4 = discretizationX4( bi_code, sample_freq );
    ran_codes(2*j-1,:) = bi_codeX4;
    ran_codes(2*j,:) = bi_codeX4*(-1);
    
%     Nav_m(j,:) = NEW_Form_Nav_Mess( dur_mess, date, ephemeris(j,:) );
%     nav_m(j, :) = randi([0 1], 1, quant_nav_m_bits);
    nav_m(j, :) = zeros(1, quant_nav_m_bits);
    mod_inf(j, :) =  Neumann_Hoffman(nav_m(j, :));

    
    %-------shift in file because of time delay between user and satellite-----
%----------------this bits are zero----------------------------------------
    shift_bits = ceil(time_diff(j) * sample_freq * ...
                                len_CA * periods_of_r_c*nav_bitsBitRate);
    
    empty_mod_bits = floor(shift_bits / (sample_freq * len_CA * periods_of_r_c));%Quantity of information symbols
    
%     rem_last_emp(j) = rem(shift_bits, sample_freq * len_CA * periods_of_r_c);
    
    
% -------Open new file-----------------------------------------------------    
    Fid = fopen(filenameForWriting{j}, 'a');
    % 
    sig = zeros(1,rem_last_emp(j));
    Buf = zeros(length(sig)*2, 1);
    Buf(1:2:end) = real(sig);
    Buf(2:2:end) = imag(sig);
    
    
    status = fseek(Fid,0, 'bof');
    fwrite(Fid, Buf, DataType);
    fclose(Fid);
    
    c =0;
    flagCorr = 0;
    for i = 1 : quant_nav_m_bits
        sig = zeros(1, periods_of_r_c*sample_freq*len_CA);

        if c < empty_mod_bits 
            c = c+1;
        else
            if mod_inf(j,i)== 0
                bits = ran_codes(2*j-1,:);
            else
                bits = ran_codes(2*j,:);
            end
            for jj = 1 : periods_of_r_c          
                if flagCorr == 0
                    if mod_inf(j,i)== 0
                        rc =ran_codes(2*j-1,:);
                    else
                        rc =ran_codes(2*j,:);
                    end
                    R = calculation_autocorr_f(rc , rc );
                    [ ~ , posPeakOrig(j) ] = max(R);
                    flagCorr = 1;
                    ShiftZero(j) = 0;%(i-1)*2*length(sig)+2*length(sig);%+rem_last_emp(j)*2;
%                     QuantityOfIntegerMillisec(j) = floor((ShiftZero(j)-2*length(sig)+2*rem_last_emp(j))/(len_CA*sample_freq*2));% потому что в начале кратно 20 теперь сделали !!!
%                     TimeRemain(j) = rem((ShiftZero(j)-2*length(sig)),(2*sample_freq*len_CA));
%                     TimeOfBlockDataOfArrivalRCInFile(j) = (QuantityOfIntegerMillisec(j)+TimeRemain(j)/len_CA)*1e-3;% 1 ms = 1e-3 = Period of C/A code 
%                     RealTimeOfPeak(j) = time_diff(j) - TimeOfBlockDataOfArrivalRCInFile(j);
                    
                    
                    
%                     phase_0 = 0.9 * 2 * pi;
                end
%                 phase_0(j) = -0.2 * 2 * pi;
                [F_doppl_1, ~] = analog(bits, delta_f_doppl, phase_0(j), sample_freq, len_CA);%signal conditioning
                sig((jj-1)*sample_freq*len_CA+1:jj*sample_freq*len_CA) = F_doppl_1;
            end
        end
        Noise = awgn(sig, SNR, 'measured', 'dB');
        sig = sig + Noise;

        Buf = zeros(length(sig)*2, 1);% 2 - because 1 channel and signal in file consists from I(0ch)Q(0ch) (each 'int16' is I(0ch) or Q(0ch))
        Buf(1:2:end) = int16(real(sig));
        Buf(2:2:end) = int16(imag(sig));
        Fid = fopen(filenameForWriting{j}, 'r+');
        Step_Shift = (i-1)*2*length(sig)+rem_last_emp(j)*2;% 2 - because 1 channel and signal consists from I(0ch)Q(0ch)
        status = fseek(Fid,bytesIn1Data*Step_Shift, 'bof');%signal_new.txt
        count = fwrite(Fid, Buf, DataType);
        fclose(Fid);
        sig = zeros(1,length(sig));

    end
        
        
        
end

