function [t, time, sv_id, chs_num] = ReadFpgaLog(prms, fullpath)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
chs_num = 12;
sv_id   = prms.sv_id;
% sv_id = [13 22 12 4 21 3 14 23];
svs_num = length(sv_id);
% A = importdata([folder filename]);
t = readtable(fullpath);
s = size(t);
tow = zeros(svs_num, ceil(s(1) / svs_num));

time = unique(t.tow);

% for n = 1 : svs_num
%     idx = find(t.sv_num == sv_id(n));
%     if any(idx)
%         cnt_cell(idx) = cnt_cell(idx) + 1;
%         c(idx, cnt_cell(idx)) = t(n, :);
%         tow(n, :) = t.tow(idx);
%     end
% end
end

