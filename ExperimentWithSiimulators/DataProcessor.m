function [ProcessedData, fourSatIsValid] = DataProcessor(RawData, test_gnss)
ProcessedData = RawData;
fourSatIsValid = 1;
if ~isfield(RawData, 'svId')
    fourSatIsValid = 0;
    fprintf("There is a bad packet (Without svId) \n")
    return
end
uniqueSvId = unique(RawData.svId);
svCntUse = 0;
% cnt = zeros(1, length(uniqueSvId));
% for k = 1 : length(uniqueSvId)
%     cnt(k) = sum(uniqueSvId(k) == RawData.svId);
% end
% uniqInd = (cnt == 1);
% usingSvId = uniqueSvId(uniqInd);
% for n = 1 : length(usingSvId)
%     ind = find(RawData.svId == usingSvId(n));
%     if (sum((RawData.trkStat{ind}) - '0') >= 3 && ...
%          RawData.gnssId(ind) == test_gnss)
%         svCntUse = svCntUse + 1;
%         indPrMes(svCntUse) = ind;
%     end
% %      = RawData.prMes;  
% end

for n = 1 : length(RawData.svId)
    if(sum(RawData.trkStat{n} - '0') >= 3 && ...
         RawData.gnssId(n) == test_gnss)
        svCntUse = svCntUse + 1;
        indPrMes(svCntUse) = n;
    end
end

if svCntUse < 4
    fourSatIsValid = 0;
    return
end
ProcessedData.numMeas = svCntUse;

ProcessedData.svId = RawData.svId(indPrMes);
ProcessedData.prMes = RawData.prMes(indPrMes);
ProcessedData.cpMes = RawData.cpMes(indPrMes);
ProcessedData.doMes = RawData.doMes(indPrMes);

ProcessedData.gnssId = RawData.gnssId(indPrMes);
ProcessedData.reserved2 = RawData.reserved2(indPrMes);
ProcessedData.freqId = RawData.freqId(indPrMes);
ProcessedData.lockTime = RawData.lockTime(indPrMes);
ProcessedData.cn0 = RawData.cn0(indPrMes);
ProcessedData.cpStdev = RawData.cpStdev(indPrMes);
ProcessedData.doStdev = RawData.doStdev(indPrMes);
ProcessedData.trkStat = RawData.trkStat(indPrMes);

end