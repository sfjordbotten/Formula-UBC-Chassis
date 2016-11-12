%Torsional Stiffness Analysis
%Based on the assumption the chassis acts like a torsional spring
%with T=k*theta and E=1/2*k*theta^2
%attempts to find an axis of rotation that makes the angular deflection of 
%both sides of the chassis equal
close all;

%Data for loads
loads = [0 6.2, 12.6, 18.9, 23.9, 30.9, 36.8, 43.1, 49.4, 55.6, 61.7, 67.8,...
    73.9, 80.1]; %lbs

%Data for Deflections
delta = ...
    [0 10 19.5 29.5 40 52 62 73 84 94.5 105 118 129 141;... %load side outermost point (drivers right)
     0 3 8 13 19 24 30 36 42 47.5 53 60 65 71;... %unloaded side outermost point (drivers left)
     0 2 3.5 5 7 9.5 11 13.5 16 17.5 20 22.5 26 29;... %load side innermost point (drivers right)
     0 0 1.5 2 3 4.5 5.5 6.5 8 9 10 11 13 14.5]./1000; %unloaded side innermost point (drivers left)
 
%Point Positions
lp = [-27.5, 10.25, 32]; %load point [x,y,z] inches
mpOut1 = [-23.5, 10.25, 32]; %outer measuring point, load side
mpIn1 = [-6.375, 4.6, 24.75]; %inner measuring pont, load side
mpOut2 = [23.5, 10.25, 32]; %outer measuring point, other side
mpIn2 = [6.375, 4.6, 24.75]; %inner measuring pont, other side
BHC = [0, (16.5765+4.6)/2, 54]; %bulk head center
COM = [0, 14.35, 11.22]; %center of mass

%boundaries of rearward projection of bulkhead
xmin = -6.375;
xmax = 6.375;
ymin = 4.6;
ymax = 16.5765;
xmin1 = -6.375/3;
xmax1 = 6.375/3;
ymin1 = 9;
ymax1 = 12;
dx = 0.1; %iteration x step
dy = 0.1; %iteration y step

x = xmin/2;
y = ymin;
aor = [0 0]; %best calculated axis of rotation [x y]
minDelta = 500; %min differance between opposite angular deflections
delt = [];
while x < xmax
    while y < ymax
        %Load radius options
        r = norm(lp(1)-BHC(1)); %distance from lp to BHC in X

        T1 = loads.*r; %torque in lbin
        
        theta1_1 = asin(delta(1,:)./(norm(mpOut1(1:2)-[x y])))*180/pi; %angle of rotation for outer points
        theta1_1 = [theta1_1; asin(delta(2,:)./(norm(mpOut2(1:2)-[x y])))*180/pi]; %angle of rotation for outer points
        theta1_2 = asin(delta(3,:)./(norm(mpIn1(1:2)-[x y])))*180/pi; %angle of rotation for inner points
        theta1_2 = [theta1_2; asin(delta(4,:)./(norm(mpIn2(1:2)-[x y])))*180/pi]; %angle of rotation for outer points
        
        d1 = (theta1_1(1,:)-theta1_1(2,:));%.*norm(BHC(1:2)-[x y]);
        d2 = (theta1_2(1,:)-theta1_2(2,:));%.*norm(BHC(1:2)-[x y]);
        
        d = abs(max(max([d1 d2])));
        %d = max(d2);
        if d < minDelta
            minDelta = d;
            aor = [aor; x y];
            delt = [delt d];
        end
        
        y = y + dy;
    end
    y = ymin;
    x = x + dx;
end

plot(delt)
fprintf('Axis of rotation = [%f, %f]\n', aor(end,1), aor(end,2))
fprintf('min delta = %f\n', minDelta)
figure(2)
hold on
plot([xmin xmax xmax xmin xmin], [ymax ymax ymin ymin ymax])
plot(aor(:,1),aor(:,2),'x')

        