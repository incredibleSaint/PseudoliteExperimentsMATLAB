clear;
% This function calculate positions of simulators (repealites)

file = matfile("for_spp.mat");
pRObserved = file.pRObserved;
svCoord = file.svCoord;
svInUse = length(pRObserved);
sa_measures = zeros(svInUse,5);

%--- Imitation position ------------
lat = 59.992859;
lon = 30.382437;
h = 50;
%-----------------------------------
svId = [10 11 12 13];%[5     7    13    14    18];
%--- range between repealites ------
% LRepToUser = 200 * ones(1, svInUse);
% LRepToUser = [1 : svInUse] .* LRepToUser;
LRepToUser = [200 400 600 800];%[200 1200 400 600 800];
%-----------------------------------
wgs84 = wgs84Ellipsoid('meters');
[UserPosZeroBased.X, UserPosZeroBased.Y, UserPosZeroBased.Z] = ...
                                            geodetic2ecef(wgs84,lat,lon,h);


a = svCoord(1,:)';
sa_measures(:,2) = a;
sa_measures(:,3) = svCoord(2,:)';
sa_measures(:,4) = svCoord(3,:)';
sa_measures(:,1) = (1:svInUse)';
figure;
hold on;
scatter3(UserPosZeroBased.X, UserPosZeroBased.Y, UserPosZeroBased.Z,30, ...
                                                        'g','filled');
title("satellites and User");
xlabel("X");
ylabel("Y");
zlabel("Z");

svInUse = 4;
for i = 1 : svInUse
    sa_measures(i,5) = sqrt((svCoord(1,i)-UserPosZeroBased.X)^2 + ...
                            (svCoord(2,i)-UserPosZeroBased.Y)^2 + ...
                            (svCoord(3,i)-UserPosZeroBased.Z)^2);
    
    svParams(i).x = sa_measures(i,2);
    svParams(i).y = sa_measures(i,3);
    svParams(i).z = sa_measures(i,4);
    scatter3(svParams(i).x,svParams(i).y,svParams(i).z, 30, 'r', 'filled');

end
% LRepToUser(1 : svInUse) = sa_measures(1 : svInUse, 5);
% LRepToUser = LRepToUser / 1e1;
figure;
hold on;
scatter3(UserPosZeroBased.X, UserPosZeroBased.Y, UserPosZeroBased.Z,30, ...
                                                        'g','filled');
title("Pseudolites and User");
xlabel("X");
ylabel("Y");
zlabel("Z");
grid on;
for  i = 1 : svInUse
    
    sa_measures(i,5) = sqrt((UserPosZeroBased.X-sa_measures(i,2))^2 + ...
                            (UserPosZeroBased.Y-sa_measures(i,3))^2 + ...
                            (UserPosZeroBased.Z-sa_measures(i,4))^2 );

    LRelat = (sa_measures(i,5)-LRepToUser(i))/LRepToUser(i);
    rep(1, i) = (svParams(i).x + LRelat * UserPosZeroBased.X) ...
                                                            / (1+LRelat);
    rep(2, i) = (svParams(i).y + LRelat * UserPosZeroBased.Y) ...
                                                            / (1+LRelat);
    rep(3, i) = (svParams(i).z + LRelat * UserPosZeroBased.Z) ...
                                                            / (1+LRelat);
                                                        
    rngBtwUserAndRep(i) = sqrt((rep(1, i) - UserPosZeroBased.X)^2 + ...
                               (rep(2, i) - UserPosZeroBased.Y)^2 + ...
                               (rep(3, i) - UserPosZeroBased.Z)^2);
                                                        
    REP(i).X = rep(1, i);
    REP(i).Y = rep(2, i);
    REP(i).Z = rep(3, i);
    scatter3(REP(i).X, REP(i).Y, REP(i).Z, 30, 'b', 'filled');

    drawnow;
    
end


% hold on;

R_circle = 1;

% Azimutal_Projection(R_circle);
ElevationGood = 0;

figure;
grid on;
for i = 1 : svInUse

    posParams.x = UserPosZeroBased.X;
    posParams.y = UserPosZeroBased.Y;
    posParams.z = UserPosZeroBased.Z;
    
    [ azimuth, elevation ] = Calc_Peleng( posParams, svParams );
   
     if elevation>10
        elevation = 90 - elevation;
        ElevationGood = ElevationGood+1;
        svUseForCalc(ElevationGood) = sa_measures(i,1);
        u = R_circle * sind(elevation) * cosd(azimuth) / sqrt(2);
        v = R_circle * sind(elevation) * sind(azimuth) / sqrt(2);
        sv = num2str(sa_measures(i, 1));
%         scatter(u, v, 100, 'k', 'filled');
%         hold on;
%         text(u,v,sv);
                
        SA_measures(ElevationGood,1) = sa_measures(i,1);
        SA_measures(ElevationGood,2) = sa_measures(i,2);
        SA_measures(ElevationGood,3) = sa_measures(i,3);
        SA_measures(ElevationGood,4) = sa_measures(i,4);
        SA_measures(ElevationGood,5) = sa_measures(i,5);
        
        Rep(ElevationGood).X = REP(i).X;
        Rep(ElevationGood).Y = REP(i).Y;
        Rep(ElevationGood).Z = REP(i).Z;
%         set(gca,'XTick',[]); 
%         set(gca,'YTick',[]);
    end
end
PseudoCoord.UserPos = UserPosZeroBased;
PseudoCoord.svId = svId;
PseudoCoord.Rep = Rep;
PseudoCoord.LRepToUser = LRepToUser;
save('PseudoliteCorrdinates.mat', 'PseudoCoord');
save('svUseForCalc.mat','svUseForCalc');
save('UserECEFZeroBased.mat','UserPosZeroBased');
save('RepeaterStadiumECEF.mat','Rep');
save('SvECEF.mat','SA_measures');
save('SvInUse.mat','ElevationGood');
grid on;