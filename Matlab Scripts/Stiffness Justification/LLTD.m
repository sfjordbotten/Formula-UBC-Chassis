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
tranferTarget = [0.8, 0.85, 0.9]; 
% set up colormap
col=jet(length(b) + 1);

% Generate curves for varrying dLLTD/dRSD vs k_chassis vs weight distribution
figure(1)
hold on

hInd = 1;
h = zeros(1,5);
hh = zeros(1,4);
for iii = 1 : length(b)
    [kChassis, dLLTD_by_dRSD, LLT_front, LLT_rear] = ...
                        calc_lltd_per_rsd( mSprung, mUnsprung_front, ...
                        mUnsprung_rear, hCG, b(iii), rWheel_front, rWheel_rear, ...
                        hRC_front, hRC_rear, trackWidth_front, ...
                        trackWidth_rear, wheelBase, rollStiffness, 0.1,...
                        0.9, 1, 6000, latAcc);
    % diff_LLTD_per_RSD vs kChassis for this longitudinal position and a
    % line picking out the required chassis stiffness for 90% of 
    % |RSD_r - RSD_f| to translate to |LLTD_r-LLTD_f|
    figure(1)
    for jjj = 1 : length(tranferTarget)
        ind = dLLTD_by_dRSD - tranferTarget(jjj) > 0;
        ind = find(ind, 1, 'first');
        plot([0, kChassis(ind), kChassis(ind)], [dLLTD_by_dRSD(ind), ...
            dLLTD_by_dRSD(ind), 0], 'k')
    end
    rsX3 = rollStiffness * 3;
    rsX5 = rollStiffness * 5;
    index_rsX3 = interp1(kChassis, dLLTD_by_dRSD, rsX3);
    index_rsX5 = interp1(kChassis, dLLTD_by_dRSD, rsX5);
    
    if iii == 1
        h(hInd) = plot([0, rsX3, rsX3], [index_rsX3, index_rsX3, 0],...
            '--', 'color', [1, 0.5, 0]);
        h(hInd + 1) = plot([0, rsX5, rsX5], [index_rsX5, index_rsX5, 0], 'r--');
        hInd = hInd + 2;
        text(rsX3, index_rsX3 - 0.025, ['\leftarrow (', num2str(rsX3), ', ',...
            num2str(round(index_rsX3, 3)), ')'])
        text(rsX5, index_rsX5 - 0.025, ['\leftarrow (', num2str(rsX5), ', ',...
            num2str(round(index_rsX5,3)), ')'])
    else
        plot([0, rsX3, rsX3], [index_rsX3, index_rsX3, 0], '--',...
            'color', [1, 0.5, 0]);
        plot([0, rsX5, rsX5], [index_rsX5, index_rsX5, 0], 'r--');
    end
    
    h(hInd) = plot(kChassis, dLLTD_by_dRSD, 'color',col(iii,:));
    hInd = hInd + 1;
    
    if iii == round(length(b) / 2)
        % plot LLTD % front VS RSD % front for a variety of chassis
        % stiffnesses 
        figure(2)
        hold on
        lower = length(LLT_front(:, 1)) / 4;
        upper = length(LLT_front(:, 1)) * 3 / 4;
        F_pctFront = LLT_front ./ (LLT_front + LLT_rear) * 100;
        hh(1) = plot(linspace(10, 90, length(LLT_front(:, 1))),...
            F_pctFront(:, 16), 'color', col(1, :));
        fit = polyfit(linspace(30, 70, length(LLT_front(:, 1)) / 2 + 1),...
            F_pctFront(lower : upper, 16)', 1);
        plot(linspace(30, 70, length(LLT_front(:, 1))), polyval(fit,...
            linspace(30, 70, length(LLT_front(:, 1)))), 'k--');
       
        hh(2) = plot(linspace(10, 90, length(LLT_front(:, 1))),...
            F_pctFront(:, 50), 'color', col(2, :));
        fit = polyfit(linspace(30, 70, length(LLT_front(:, 1)) / 2 + 1),...
            F_pctFront(lower : upper, 50)', 1);
        plot(linspace(30, 70, length(LLT_front(:, 1))), polyval(fit,...
            linspace(30, 70, length(LLT_front(:, 1)))), 'k--');
       
        hh(3) = plot(linspace(10, 90, length(LLT_front(:, 1))),...
            F_pctFront(:, 200), 'color', col(3,:));
        fit = polyfit(linspace(30, 70, length(LLT_front(:, 1)) / 2 + 1),...
            F_pctFront(lower : upper, 200)', 1);
        plot(linspace(30, 70, length(LLT_front(:, 1))), polyval(fit,...
            linspace(30, 70, length(LLT_front(:, 1)))), 'k--');
        
        hh(4) = plot(linspace(10, 90, length(LLT_front(:, 1))),...
            F_pctFront(:, 600), 'color', col(4, :));
        fit = polyfit(linspace(30, 70, length(LLT_front(:, 1)) / 2 + 1),...
            F_pctFront(lower : upper, 600)', 1);
        plot(linspace(30, 70, length(LLT_front(:, 1))), polyval(fit,...
            linspace(30, 70, length(LLT_front(:, 1)))), 'k--');
        
        figure(3)
        hold on
        xDim = size(LLT_front, 1);
        plot(linspace(1, 6000, length(LLT_front(1, :))), F_pctFront(xDim / 4, :),...
            'color', col(1, :))
        plot(linspace(1, 6000, length(LLT_front(1, :))), F_pctFront(xDim / 2, :),...
            'color', col(2, :))
        plot(linspace(1, 6000, length(LLT_front(1, :))), F_pctFront(3 * xDim / 4, :),...
            'color', col(3,:))
    end
end

figure(1)
xlabel('Chassis Stiffness [Nm/deg]')
ylabel('Region of Interest $\frac{\partial LLTF_{front}}{\partial RSD_{front}}$',...
    'Interpreter', 'Latex')
legend(h, {'kChassis = 3X roll stiffness',...
            'kChassis = 5X roll stiffness',...
            ['Weight ' num2str(b(1) / wheelBase * 100) '% rear'], ...
            ['Weight ' num2str(b(2) / wheelBase * 100) '% rear'], ...
            ['Weight ' num2str(b(3) / wheelBase * 100) '% rear']},...
            'Location', 'best')
        
figure(2)
legend(hh, {['k chassis = ' num2str(round(kChassis(16)))],...
    ['k chassis = ' num2str(round(kChassis(50)))], ...
    ['k chassis = ' num2str(round(kChassis(200)))],...
    ['k chassis = ' num2str(round(kChassis(600)))]},...
    'Location', 'best');
xlabel('Stiffness Distribution % Front')
ylabel('LLTD % Front')

figure(3)
legend({'RSD % Front = 30', 'RSD % Front = 50', 'RSD % Front = 70'}, ...
    'Location', 'best');
xlabel('Chassis Stiffness [Nm/deg]')
ylabel('LLTD % Front')