function  Azimutal_Projection(R)
%
figure;
n = 6;
for i = 1:n
    x = -i*R/n:0.001:i*R/n;
    y1 = sqrt((i*R/n)^2-x.^2);
    y2 = -sqrt((i*R/n)^2-x.^2);
    hold all
    axis equal
    plot(x,y1,'k--');
    plot(x,y2,'k--');
end
plot(x,y1,'k');
plot(x,y2,'k');
grid on
% scatter(0,0, 'g', 'filled'); 
s = ['90' char(176)];
text(0,0,s);
% scatter(1,0, 'g', 'filled'); 
s = ['0' char(176) ', 90' char(176)];
text(1,0,s);
% scatter(0,1, 'g', 'filled');
s = ['0' char(176)];
text(0,1,s);
% scatter(-1,0, 'g', 'filled');
s = ['270' char(176)];
text(-1,0,s);
% scatter(0,-1, 'g', 'filled');
s = ['180' char(176)];
text(0,-1,s);
% scatter(0.5,0, 'y', 'filled'); 
s = ['45' char(176)];
text(0.5,0,s);
s = ['75' char(176)];
text(1/6,0,s);
s = ['60' char(176)];
text(1/3,0,s);
s = ['30' char(176)];
text(2/3,0,s);
s = ['15' char(176)];
text(5/6,0,s);
end

