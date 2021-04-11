clear

folderPath = [cd '\ScriptsFunctions'];
addpath(folderPath);
addpath([cd '\Records']);
%---------------------------------
%-- Parser of U-blox Messages: --%
%---------------------------------
% dirName  = 'D:\Windows\Programming\Matlab\GNSS\ModelHelgor\AddFunctions\';

fileName = '\Records\4realPseudo_200met.ubx'; %'\ReleaseBuild_200meters.ubx';% 'COM5_201210_093149.ubx';

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
    if fourSatIsValid
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
% 
% xlabel('t, сек')
% ylabel('3D error, м')
% grid on;
