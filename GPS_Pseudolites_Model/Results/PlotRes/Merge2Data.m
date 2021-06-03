clear;

fname = 'Merged_Res_CN0_55__35_(x_-1410 -1210 -600 0  170 440 920 1400,y_ 0).mat';

Data1 = load('Res_CN0_55_50_(x_-1410 -1210 -600 0  170 440 920 1400,y_ 0).mat');
Data2 = load('Res_romb_50deg_CN0_45_40_35_(x_-1410 -1210 -600 0  170 440 920 1400,y_ 0).mat');

s = size(Data1.Data.Errs);
pntsNum = s(2);

for k = 1 : pntsNum
    err1 = Data1.Data.Errs{1, k}.err3D;   
    err2 = Data2.Data.Errs{1, k}.err3D;
    new_err3D = vertcat(err1, err2);

    err1 = Data1.Data.Errs{1, k}.err2D;   
    err2 = Data2.Data.Errs{1, k}.err2D;
    new_err2D = vertcat(err1, err2);
    
    err1 = Data1.Data.Errs{1, k}.err_psrng;
    err2 = Data2.Data.Errs{1, k}.err_psrng;
    err1{3} = err2{1};
    err1{4} = err2{2};
    err1{5} = err2{3};
    
    Data1.Data.Errs{1, k}.err3D = new_err3D;
    Data1.Data.Errs{1, k}.err2D = new_err2D;
    Data1.Data.Errs{1, k}.err_psrng = err1;
end
Data = Data1.Data;
save(fname, 'Data');