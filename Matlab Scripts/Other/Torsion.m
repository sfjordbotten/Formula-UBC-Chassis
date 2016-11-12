%Torsional Stiffness Analysis
%Based on the assumption the chassis acts like a torsional spring
%with T=k*theta and E=1/2*k*theta^2

%close all;

%Data for loads
loads = [0 6.2, 12.6, 18.9, 23.9, 30.9, 36.8, 43.1, 49.4, 55.6, 61.7, 67.8,...
    73.9, 80.1]; %lbs

%Data for Deflections
delta = ...
   ( [0 10 19.5 29.5 40 52 62 73 84 94.5 105 118 129 141;... %load side outermost point (drivers right)
     0 3 8 13 19 24 30 36 42 47.5 53 60 65 71;... %unloaded side outermost point (drivers left)
     0 2 3.5 5 7 9.5 11 13.5 16 17.5 20 22.5 26 29;... %load side innermost point (drivers right)
     0 0 1.5 2 3 4.5 5.5 6.5 8 9 10 11 13 14.5])./1000; %unloaded side innermost point (drivers left)
 
%Point Positions
lp = [27.5, 10.25, 32]; %load point [x,y,z] inches
mpOut = [23.5, 10.25, 32]; %outer measuring point, load side
mpIn = [6.375, 4.6, 24.75]; %inner measuring pont, load side
BHC = [0, (16.5765+4.6)/2, 54]; %bulk head center
COM = [0, 14.35, 11.22]; %center of mass

%Load radius options
r1 = norm(lp(1)-BHC(1)); %distance from lp to BHC in X
r2 = norm(lp(1)-COM(1)); %distance from lp to BHC in X

T1 = loads.*r1; %torque in lbin
theta1_1 = asin(delta(1:2,:)./(norm(mpOut(1:2)-BHC(1:2))))*180/pi; %angle of rotation for outer points
theta1_2 = asin(delta(3:4,:)./(norm(mpIn(1:2)-BHC(1:2))))*180/pi; %angle of rotation for inner points
theta2_1 = atan(delta(1:2,:)./23.5)*180/pi; %angle of rotation for outer points
%theta2_1 = (atan((mpOut(2)-BHC(2))/mpOut(1)) - atan((mpOut(2)-BHC(2)-delta(1:2,:))/mpOut(1)))*180/pi;
theta2_2 = atan(delta(3:4,:).*2./6.375)*180/pi; %angle of rotation for inner points

a1 = asin((delta(1,:)+delta(2,:))./2./(norm(mpOut(1:2)-BHC(1:2))))*180/pi; %angle of rotation for outer points
b1 = asin((delta(3,:)+delta(4,:))./2./(norm(mpIn(1:2)-BHC(1:2))))*180/pi; %angle of rotation for inner points

a2 = atan((delta(1,:)+delta(2,:))./2./23.5)*180/pi; %angle of rotation for outer points
b2 = atan((delta(3,:)+delta(4,:))./2./6.375)*180/pi; %angle of rotation for inner points

hold on
plot(loads, delta(1,:), 'b')
plot(loads, delta(2,:), 'r')
plot(loads, delta(3,:), 'g')
plot(loads, delta(4,:), 'y')

figure(2)
hold on
plot(theta1_1(1,:), T1, 'b')
plot(theta1_1(2,:), T1, 'r')
plot(theta1_2(1,:), T1, 'g')
plot(theta1_2(2,:), T1, 'y')

figure(3)
hold on
plot(T1, T1./theta1_1(1,:).*0.112984829333, 'b')
%plot(T1, T1./theta1_1(2,:).*0.112984829333, 'r')
%plot(T1, T1./theta1_2(1,:).*0.112984829333, 'g')
plot(T1, T1./theta1_2(2,:).*0.112984829333, 'y')

%plot(T1, T1./a1.*0.112984829333, 'c')
%plot(T1, T1./b1.*0.112984829333, 'm')
legend('Point 1 Only', 'Point 4 Only', 'Point 2 Only', 'Point 3 Only', 'Average P1-P4', 'Average P2-P3')
xlabel('Torque (lbs*in)')
ylabel('Stiffness (Nm/deg)')
title('Torsional Stiffness VS Load, assuming twist about centerpoint of Bulkhead')
grid on

figure(4)
hold on
fprintf('Mean Out DR: %0.2f Nm/deg \n', mean(T1(2:end)./theta1_1(1,2:end).*0.112984829333))
fprintf('Mean Out DL: %0.2f Nm/deg \n', mean(T1(2:end)./theta1_1(2,2:end).*0.112984829333))
fprintf('Mean Out ave: %0.2f Nm/deg \n', mean(T1(2:end)./a2(2:end).*0.112984829333))
plot(T1, T1./theta2_1(1,:).*0.112984829333, 'b')
plot(T1, T1./theta2_1(2,:).*0.112984829333, 'r')
plot(T1, T1./theta2_2(1,:).*0.112984829333, 'g')
plot(T1, T1./theta2_2(2,:).*0.112984829333, 'y')
plot(T1, T1./a2.*0.112984829333, 'c')
plot(T1, T1./b2.*0.112984829333, 'm')


fprintf('')
mean(T1(2:end)./a1(2:end))*0.112984829333;
mean(T1(2:end)./b1(2:end))*0.112984829333;

legend('Point 1 Only', 'Point 4 Only', 'Point 2 Only', 'Point 3 Only', 'Average P1-P4', 'Average P2-P3')
xlabel('Torque (lbs*in)')
ylabel('Stiffness (Nm/deg)')
title('Torsional Stiffness VS Torque, Using Cornell Angle Calculation')
grid on

% %uncertainty calcs
% lb2N = 4.448221628254617;
% dL = 0.025/2/2; %m uncertainty in load location
% dF = 0.2225/2; %N uncertainty in load
% %uncertianty in k for outer points
% dk1 = sqrt( (dL .* lb2N .* loads .* pi./ (asin((delta(1,:)+delta(2,:))./...
%     2./(norm(mpOut(1:2)-BHC(1:2))))*180/pi) ).^2 + (dF .* r1 ./ ...
%     asin((delta(1,:)+delta(2,:))./2./(norm(mpOut(1:2)-BHC(1:2))))*180/pi ).^2);
% %uncertianty in k for inner points
% dk2 = sqrt( (dL .* lb2N .* loads .* pi./ (asin((delta(3,:)+delta(4,:))./...
%     2./(norm(mpIn(1:2)-BHC(1:2))))*180/pi) ).^2 + (dF .* r1 ./ ...
%     asin((delta(3,:)+delta(4,:))./2./(norm(mpIn(1:2)-BHC(1:2))))*180/pi ).^2);
% 
% dk1_1 = (dL./r1*100+dF./(loads*lb2N))./...
%     ( asin((delta(3,:)+delta(4,:))./2./(norm(mpIn(1:2)-BHC(1:2))))*180/pi );
% dk2_1 = (dL./r1*100+dF./(loads*lb2N))./...
%     (asin((delta(3,:)+delta(4,:))./2./(norm(mpIn(1:2)-BHC(1:2))))*180/pi);
% 
% figure(5)
% hold on
% plot(T1, T1./a1.*0.112984829333, 'c')
% plot(T1, T1./b1.*0.112984829333, 'm')
% % plot(T1(6:end), T1(6:end)./a1(6:end).*0.112984829333.*(1 + dk1_1(6:end)), ':c')
% % plot(T1(6:end), T1(6:end)./a1(6:end).*0.112984829333.*(1 - dk1_1(6:end)), ':c')
% % plot(T1(6:end), T1(6:end)./b1(6:end).*0.112984829333.*(1 + dk2_1(6:end)), ':m')
% % plot(T1(6:end), T1(6:end)./b1(6:end).*0.112984829333.*(1 - dk2_1(6:end)), ':m')
% 
% %legend('Average P1-P4', 'Average P2-P3')
% xlabel('Torque (lbs*in)')
% ylabel('Stiffness (Nm/deg)')
% title('Torsional Stiffness VS Load, assuming twist about centerpoint of Bulkhead')
% grid on


