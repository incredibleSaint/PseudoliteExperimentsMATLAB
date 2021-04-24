function [ R ] = calculation_autocorr_f( bi_code_1,bi_code_2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%bi_code_2 = circshift(bi_code_2,length(bi_code_2)/2);

if length(bi_code_1) < length(bi_code_2)
    bi_code_2 = bi_code_2(1:length(bi_code_1));
elseif length(bi_code_1) > length(bi_code_2)
   v= bi_code_2(1:(length(bi_code_1)-length(bi_code_2)));
        bi_code_2 = cat(2,bi_code_2,v);
end
R = ifft(fft(bi_code_1).*conj(fft(bi_code_2)));

% R_not = (ifft(fft(bi_code_1).*conj(fft(bi_code_2))));
% [ Max , posPeak ] = max(R_not);
% Amb = atan2(imag(R_not(posPeak)),real(R_not(posPeak)));
end

