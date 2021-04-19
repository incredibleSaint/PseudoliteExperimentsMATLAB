function flagCANumsMatchUp = CheckCANumsMatchUp(CANums1, CANums2)
% CANum1 - CANums from u-blox
% CANum2 - reference CANums, which are known
flagCANumsMatchUp = 0;
svCnt = 0;


for k = 1 : length(CANums1)
    if sum(CANums2 == CANums1(k)) == 1
        svCnt = svCnt + 1;
    end
end

enoughNumForPositioning = 4;

if svCnt >= enoughNumForPositioning
   flagCANumsMatchUp = 1;
end
    
