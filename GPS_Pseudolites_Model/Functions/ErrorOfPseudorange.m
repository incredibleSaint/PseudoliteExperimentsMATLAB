function [CalculatedPseudo] = ErrorOfPseudorange(...
                ...
                        CalculatedPositionPeakOfRangingCode, ByteShift, ...
                        constellation, timePropogSvUser, rem_last_emp, ...
                        PseudoR, Sampl_Freq, RealTimeOfPeak, len_CA)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%first
C = 2.99792458e8; %The light speed
AccuracyOf1Sample = 1/(Sampl_Freq * len_CA * 1e3); % исправить частоту !!!!!!!!!!
% ErrorPseudo = zeros(length(CalculatedPositionPeakOfRangingCode(:,1)),length(constellation));
% CalculatedPseudo = zeros(length(CalculatedPositionPeakOfRangingCode(:,1)),length(constellation));
% SvAmbiguity = zeros(1,length(constellation));
CalculatedTimeOfPeak = AccuracyOf1Sample * ...
                                 (CalculatedPositionPeakOfRangingCode );%- ...
%                                                          rem_last_emp * 2);% 2 - because 1 channel and signal consists from I(0ch)Q(0ch)
CalculatedPseudo = zeros(length(CalculatedTimeOfPeak(:,1)),length(constellation));
for n = 1:length(CalculatedTimeOfPeak(:,1))
    for i = 1:length(constellation)
        if CalculatedTimeOfPeak(n,i) ~= 0 
            CalculatedPseudo(n,i) = PseudoR(i);% + C*(CalculatedTimeOfPeak(n,i) - RealTimeOfPeak(i));
        end
    end
end
% for i = 1:length(constellation)
%     SvAmbiguity(i) = AccuracyOf1Chip-rem(timePropogSvUser(i), AccuracyOf1Chip);
% %     trueShiftCorrPeak(i) = rem(time_diff(i),SvAmbig(i));
% %     for n = 1:length(positionPeakOfRangingCode(:,1))
% %         if positionPeakOfRangingCode(n,i) ~= rem_last_emp(i)
% %             ErrorPseudo(n,i) = (positionPeakOfRangingCode(n,i)-rem_last_emp(i))*AccuracyOf1Chip;
% %             dt = ErrorPseudo(n,i)-SvAmbiguity(i);
% %             CalculatedPseudo(n,i) = PseudoR(i) + C*dt;
% %         else
% %             CalculatedPseudo(n,i) = PseudoR(i) - C*SvAmbiguity(i);
% %         end
% %         
% %     end
% 
% end

end

