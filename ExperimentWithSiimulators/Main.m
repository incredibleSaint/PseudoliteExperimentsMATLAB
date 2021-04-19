clear

folderPath = [cd '\ScriptsFunctions'];
addpath(folderPath);
addpath([cd '\Records']);
%---------------------------------
%-- Parser of U-blox Messages: --%
%---------------------------------
% dirName  = 'D:\Windows\Programming\Matlab\GNSS\ModelHelgor\AddFunctions\';

fileName = '\Records\4realPseudo_200met_onlyOne1pps_TmsLog_v6_theSameRanges.ubx'; %'\ReleaseBuild_200meters.ubx';% 'COM5_201210_093149.ubx';

fullName = [cd fileName];

[Mes0x1502] = ParserUbxpacket(fullName);

sizeStr = size(Mes0x1502);
load([cd '\ScriptsFunctions\PseudoliteCorrdinates.mat']);
c = 299792458;

posCnt = 0;

for n = 1 : sizeStr(2)
    svCnt = 0;
    SatsPoses = [];
    psRngs = [];
    
    RawData = Mes0x1502{n};
    [ProcessedMes, fourSatIsValid] = DataProcessor(RawData);
    if fourSatIsValid && ...
                    CheckCANumsMatchUp(ProcessedMes.svId, PseudoCoord.svId)
        for k = 1 : length(ProcessedMes.svId)
            ind = (PseudoCoord.svId == ProcessedMes.svId(k));
            if sum(ind) && sum(ProcessedMes.trkStat{k}  - '0') >= 3
                
                svCnt = svCnt + 1;
                SatsPoses(1, svCnt) = PseudoCoord.Rep(ind).X;
                SatsPoses(2, svCnt) = PseudoCoord.Rep(ind).Y;
                SatsPoses(3, svCnt) = PseudoCoord.Rep(ind).Z;

                psRngs(svCnt) = ProcessedMes.prMes(k);
            end
        end
        if isempty(SatsPoses)
            continue
        end
        inTimeShifts = (ProcessedMes.prMes - ProcessedMes.prMes(1)) / c;
        
        [UPos, err] = FindRecPosition(SatsPoses, psRngs);
        posCnt = posCnt + 1;
        UserPoses(posCnt, :) = UPos;
        errPos3D(posCnt, :) = err;
        diffPsRngs(posCnt, :) = psRngs - psRngs(1);
        
    end
end

figure; plot(errPos3D);
ylabel("3D Error, met");

figure; plot(diffPsRngs);
ylabel("diffPsRngs, m");


figure; plot(diffPsRngs - mean(diffPsRngs))
legend(num2str(mean(diffPsRngs)'));
refDiffPs = [0 : 200 : 600];
for n = 1 : 4
   maxDiff = max(diffPsRngs(:, n)); 
   minDiff = min(diffPsRngs(:, n));
   
   changesDueTime(n) = maxDiff - minDiff;
   
   meanDiff(n) = mean(diffPsRngs(:, n));
   
   
end
ppsErrorExp = meanDiff - refDiffPs;

stdPps = 250e-9;

stdPpsInMet = c * stdPps;
if stdPpsInMet - abs(ppsErrorExp) > 0 
   fprintf("Errors of pseudoranges satisfy 1PPS errors \n"); 
end

% 
% xlabel('t, сек')
% ylabel('3D error, м')
% grid on;
