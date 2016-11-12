clear all; close all
%% Lateral load transfer distribution for varying torsional stiffness
% Based on models from:
%	Chalmers University Paper: http://publications.lib.chalmers.se/records/fulltext/191830/191830.pdf
%	SAE Paper : The Effect of Chassis Stiffness on Race Car Handling Balance. Deakin et. al.
% TODO: SHOULD WE BE CONSIDERING LATERAL FRICTION FORCES AT THE WHEELS?

%% Lateral accelleration
latAcc = 2 * 9.81; %[m/s^2]
%% Car input static data [m]
% Car dimensions
hCG = 0.31122; % CG's height over ground contact line
rWheel_front = 9 * 25.4 / 1000; % Front wheel radius
rWheel_rear = 9 * 25.4 / 1000; % Rear wheel radius
hRC_front = 1.906 * 25.4 / 1000; % Front wheel roll centre height
hRC_rear = 2.234 * 25.4 / 1000; % Rear wheel roll centre height
trackWidth_front = 48 * 25.4 / 1000; % Track width
trackWidth_rear = 47 * 25.4 / 1000; % Track width
wheelBase = 60.5 * 25.4 / 1000; %[m]
rollStiffness =  850; %[Nm/deg]
% Masses
mSprung = 244; % Sprung mass, including driver [kg]
mUnsprung_front = 8; % Front unsprung mass [kg]
mUnsprung_rear = 7.5; % Rear unsprung mass [kg]
%% weight distributions to consider
b = wheelBase.*[0.6, 0.5, 0.4]; % CG's longitudal position from rear axle
% target percent of roll stiffness distribution difference that translates 
% into lateral load transfer distribution difference
tranferTarget = 0.9; 
% set up colormap
col=jet(length(b) + 1);

% Generate curves for varrying dLLTD/dRSD vs k_chassis vs weight distribution
figure(1)
hold on
figure(4)
hold on
h = zeros(1,3);
hh = zeros(1,3);
for iii = 1 : length(b)
    [kChassis, diff_LLTD_per_RSD, LLT_front, LLT_rear] = ...
                        calc_lltd_per_rsd( mSprung, mUnsprung_front, ...
                        mUnsprung_rear, hCG, b(iii), rWheel_front, rWheel_rear, ...
                        hRC_front, hRC_rear, trackWidth_front, ...
                        trackWidth_rear, wheelBase, rollStiffness, 0.1,...
                        0.9, 1, 6000, latAcc);
    % diff_LLTD_per_RSD vs kChassis for this longitudinal position and a
    % line picking out the required chassis stiffness for 90% of 
    % |RSD_r - RSD_f| to translate to |LLTD_r-LLTD_f|
    figure(1)
    ind = diff_LLTD_per_RSD - tranferTarget > 0;
    ind = find(ind, 1, 'first');
    plot([0, kChassis(ind), kChassis(ind)], [diff_LLTD_per_RSD(ind), ...
        diff_LLTD_per_RSD(ind), 0], 'k')
    h(iii) = plot(kChassis, diff_LLTD_per_RSD, 'color',col(iii,:));
    
    slopes = zeros(1, length(kChassis));
    F_pctFront = LLT_front ./ (LLT_front + LLT_rear) * 100;
    for jjj = 1 : length(kChassis)
        fit = polyfit(linspace(10, 90, length(LLT_front(:, 1))), F_pctFront(:, jjj)', 1);
        slopes(jjj) = fit(1);
    end
    figure(4)
    hh(iii) = plot(kChassis, slopes, 'color', col(iii,:));
    ind = slopes - tranferTarget > 0;
    ind = find(ind, 1, 'first');
    plot([0, kChassis(ind), kChassis(ind)], [slopes(ind), slopes(ind), 0], 'k')
    
    if iii == round(length(b) / 2)
        % plot LLTD % front VS RSD % front for a variety of chassis
        % stiffnesses 
        figure(2)
        hold on
        F_pctFront = LLT_front ./ (LLT_front + LLT_rear) * 100;
        plot(linspace(10, 90, length(LLT_front(:, 1))), F_pctFront(:, 16),...
            'color', col(1, :))
        plot(linspace(10, 90, length(LLT_front(:, 1))), F_pctFront(:, 50),...
            'color', col(2, :))
        plot(linspace(10, 90, length(LLT_front(:, 1))), F_pctFront(:, 200),...
            'color', col(3,:))
        plot(linspace(10, 90, length(LLT_front(:, 1))), F_pctFront(:, 600),...
            'color', col(4, :))
        figure(3)
        hold on
        xDim = size(LLT_front, 1);
        plot(linspace(1, 6000, length(LLT_front(1, :))), F_pctFront(xDim / 4, :),...
            'color', col(1, :))
        plot(linspace(1, 6000, length(LLT_front(1, :))), F_pctFront(xDim / 2, :),...
            'color', col(2, :))
        plot(linspace(1, 6000, length(LLT_front(1, :))), F_pctFront(3 * xDim / 4, :),...
            'color', col(3,:))
        
%         % Determine vertical force distribution % Outside
%         F_tires = calc_vertTireForces(LLT_front, LLT_rear, 0, 0, mSprung, ...
%             mUnsprung_front, mUnsprung_rear, b(iii), wheelBase);
%         F_tires_outside = F_tires(:, :, 1) + F_tires(:, :, 3);
%         F_tires_inside = F_tires(:, :, 2) + F_tires(:, :, 4);
%         F_tires_pctOutside = F_tires_outside ./ (F_tires_outside + F_tires_inside) .* 100;
%         figure(4)
%         hold on
%         plot(linspace(10, 90, length(F_tires(:, 1, 1))), F_tires_pctOutside(:, 16), ...
%             'color', col(1, :))
%         plot(linspace(10, 90, length(F_tires(:, 1, 1))), F_tires_pctOutside(:, 50), ...
%             'color', col(2, :))
%         plot(linspace(10, 90, length(F_tires(:, 1, 1))), F_tires_pctOutside(:, 200), ...
%             'color', col(3, :))
%         plot(linspace(10, 90, length(F_tires(:, 1, 1))), F_tires_pctOutside(:, 600), ...
%             'color', col(4, :))
%         figure(5)
%         hold on
%         plot(linspace(1, 6000, length(F_tires(1, :, 1))), F_tires_pctOutside(xDim / 4, :), ...
%             'color', col(1, :))
%         plot(linspace(1, 6000, length(F_tires(1, :, 1))), F_tires_pctOutside(xDim / 2, :), ...
%             'color', col(2, :))
%         plot(linspace(1, 6000, length(F_tires(1, :, 1))), F_tires_pctOutside(3 * xDim / 4, :), ...
%             'color', col(3, :))
    end
end

figure(1)
xlabel('Chassis Stiffness [Nm/deg]')
ylabel('|LLTD_r-LLTD_f| / |RSD_r - RSD_f|')
legend(h, {['Weight ' num2str(b(1) / wheelBase * 100) '% rear'], ...
            ['Weight ' num2str(b(2) / wheelBase * 100) '% rear'], ...
            ['Weight ' num2str(b(3) / wheelBase * 100) '% rear']},...
            'Location', 'best')
figure(4)
xlabel('Chassis Stiffness [Nm/deg]')
ylabel('dLLTF_front/dkChassis')
legend(hh, {['Weight ' num2str(b(1) / wheelBase * 100) '% rear'], ...
            ['Weight ' num2str(b(2) / wheelBase * 100) '% rear'], ...
            ['Weight ' num2str(b(3) / wheelBase * 100) '% rear']},...
            'Location', 'best')
        
figure(2)
legend(['k chassis = ' num2str(round(kChassis(16)))], ['k chassis = ' num2str(round(kChassis(50)))], ...
    ['k chassis = ' num2str(round(kChassis(200)))], ['k chassis = ' num2str(round(kChassis(600)))],...
    'Location', 'best');
xlabel('Stiffness Distribution % Front')
ylabel('LLTD % Front')

figure(3)
legend('RSD % Front = 30', 'RSD % Front = 50', 'RSD % Front = 70', ...
    'Location', 'best');
xlabel('Chassis Stiffness [Nm/deg]')
ylabel('LLTD % Front')

% figure(4)
% legend(['k chassis = ' num2str(round(kChassis(16)))], ['k chassis = ' num2str(round(kChassis(50)))], ...
%     ['k chassis = ' num2str(round(kChassis(200)))], ['k chassis = ' num2str(round(kChassis(600)))],...
%     'Location', 'best');
% xlabel('Stiffness Distribution % Front')
% ylabel('VFD % Outside')

% figure(5)
% legend('RSD % Front = 30', 'RSD % Front = 50', 'RSD % Front = 70', ...
%     'Location', 'best');
% xlabel('Chassis Stiffness [Nm/deg]')
% ylabel('VFD % Outside')