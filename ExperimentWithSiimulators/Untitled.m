h = [80 100 120 90];%LRepToUser / sqrt(3);
d = 100;
x = d / tand(60);

LRepToUser = [200 : 200 : 800];

Rep(1, 1) = d + 100;
Rep(3, 1) = h(1);
Rep(2, 1) =  sqrt(LRepToUser(1) ^ 2 - Rep(1, 1) ^ 2 - Rep(3, 1) ^ 2)+ 100;

Rep(1, 2) = 0+ 100;
Rep(3, 2) = h(2);
Rep(2, 2) = -sqrt(LRepToUser(2) ^ 2 - Rep(1, 2) ^ 2 - Rep(3, 2) ^ 2)+ 100;

Rep(1, 3) = -d+ 100;
Rep(3, 3) = h(3);
Rep(2, 3) =  sqrt(LRepToUser(3) ^ 2 - Rep(1, 3) ^ 2 - Rep(3, 3) ^ 2)+ 100;

Rep(1, 4) = -0+ 100;
Rep(3, 4) = h(4);
Rep(2, 4) = -sqrt(LRepToUser(4) ^ 2 - Rep(1, 4) ^ 2 - Rep(3, 4) ^ 2)+ 100;

psRngs = LRepToUser;

FindRecPosition(Rep, psRngs);

sqrt(sum(Rep .^ 2, 1))