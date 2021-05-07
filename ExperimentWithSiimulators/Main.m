clear;

folderPath = [cd '\ScriptsFunctions'];
addpath(folderPath);
addpath([cd '\Records']);
%---------------------------------
%-- Parser of U-blox Messages: --%
%---------------------------------
% dirName  = 'D:\Windows\Programming\Matlab\GNSS\ModelHelgor\AddFunctions\';
folder = '\Records\';
fileName = 'Big_Case_Interseal_2Clocks_MixedPseudo_sv_10_11_15_16__2d_launch_diff_0_met_static_position_v1.ubx'; %'\ReleaseBuild_200meters.ubx';% 'COM5_201210_093149.ubx';

fullName = [cd folder fileName];

[Mes0x1502] = ParserUbxpacket(fullName);

sizeStr = size(Mes0x1502);
load([cd '\ScriptsFunctions\PseudoliteCorrdinates.mat']);
c = 299792458;

posCnt = 0;

% == if check pseudorange for some CAcodes (without positioning) ======
flagWorkWithSomeCAcodesJustPsRngs = 1;
if flagWorkWithSomeCAcodesJustPsRngs
    % Big_Case #1:
%     PseudoCoord.svId = [2 3 6 12 19 24 25 29 31 32];
    
    % Big_Case #2:
%     PseudoCoord.svId = [2 6 24 25 29 31];
    % Big_Case #3:
%       PseudoCoord.svId = [2 9 12 18 25 26 29 31 4];
    % Big_Case #4:
%         PseudoCoord.svId = [2 5 16 18 20 25 26 29 31];
    % Big_Case #5:
%         PseudoCoord.svId = [5 16 18 20 23 26 29 31];

    % Big_Case #6:
        PseudoCoord.svId = [10 11 15 16];
        
    diffPsRngs = zeros(sizeStr(2), length(PseudoCoord.svId));
    % Old Interseal (one simulator)
%     PseudoCoord.svId = [5     7     8    13    14    18    28];
end
%========================

tow = zeros(1, sizeStr(2));

for n = 1 : sizeStr(2)
    svCnt = 0;
    SatsPoses = [];
    psRngs = [];

    RawData = Mes0x1502{n};
    
    if RawData.numMeas > 0
        [ProcessedMes, fourSatIsValid] = DataProcessor(RawData);
        necessarySat = CheckCANumsMatchUp(ProcessedMes.svId, ...
                                                        PseudoCoord.svId);
        if flagWorkWithSomeCAcodesJustPsRngs % when less than 4 CA-codes
    %         fourSatIsValid = 1;
    %         necessarySat = 1;
        end
        if fourSatIsValid && necessarySat

            for k = 1 : length(ProcessedMes.svId)
                ind = (PseudoCoord.svId == ProcessedMes.svId(k));
                if sum(ind) && sum(ProcessedMes.trkStat{k}  - '0') >= 3

                    svCnt = svCnt + 1;
                    if ~flagWorkWithSomeCAcodesJustPsRngs
                        SatsPoses(1, ind) = PseudoCoord.Rep(ind).X;
                        SatsPoses(2, ind) = PseudoCoord.Rep(ind).Y;
                        SatsPoses(3, ind) = PseudoCoord.Rep(ind).Z;
                    end
                    psRngs(ind) = ProcessedMes.prMes(k);
                end
            end

            if ~flagWorkWithSomeCAcodesJustPsRngs
                if isempty(SatsPoses)
                    continue
                end
            end
            inTimeShifts = (ProcessedMes.prMes - ProcessedMes.prMes(1)) / c;

            if ~flagWorkWithSomeCAcodesJustPsRngs
                [UPos, err] = FindRecPosition(SatsPoses, psRngs);
                UserPoses(posCnt, :) = UPos;
                errPos3D(posCnt, :) = err;
            end
            posCnt = posCnt + 1;

            tow(posCnt) = ProcessedMes.rcvTow;
            diffPsRngs(posCnt, 1 : length(psRngs)) = psRngs - psRngs(1);        
        end
    end
end
    
figure; plot(diff(tow(1 : posCnt)));
grid on;
title("TOW");
ylabel("TOW, sec");

if ~flagWorkWithSomeCAcodesJustPsRngs
    figure; plot(errPos3D(1 : posCnt));
    ylabel("3D Error, met");
end

figure; plot(diffPsRngs(1 : posCnt, :));
ylabel("diffPsRngs, m");
grid on;


num_sv = 9;
legend_text = cell(1, num_sv);
for i = 1 : num_sv
    legend_text{i} = num2str(i);
end
legend(legend_text);

% -- Plot Error of pseudorange difference --------

figErr = figure;
emitted_rng_diff = 0 : 1000 : 0;
plot(diffPsRngs(1 : posCnt, :) - emitted_rng_diff);
xlabel("t, sec");
ylabel("error(diff(psRng)), met");
grid on;

cd 'Results'
saveas(figErr, [fileName '.emf']);
cd ..

% figure; plot(diffPsRngs - mean(diffPsRngs))
% legend(num2str(mean(diffPsRngs)'));
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
