function [k_chassis, diff_LLTD_per_RSD, LLT_front, LLT_rear] = ...
    calc_lltd_per_rsd( mSprung, mUnsprung_front, mUnsprung_rear, hCG,...
    dist_cg_from_rear, rWheel_front, rWheel_rear, hRC_front, hRC_rear,...
    trackWidth_front, trackWidth_rear, wheelBase, kRoll, kRoll_pctFrontMin,...
    kRoll_pctFrontMax, kChassis_min, kChassis_max, latAcc)
% Calculates the lateral load distribution difference per roll
% stiffness distribution difference as a function of chassis stiffness.
% Parameters :
%   - mSprung : [kg] Sprung vehicle mass, including driver.
%   - mUnsprung_front : [kg] unsprung mass of front components
%   - mUnsprung_rear : [kg] unsprung mass of rear components
%   - hCG : [m] height of CG above the ground
%   - dist_cg_from_rear : [m] longitudinal distance from the rear axle to
%                         the CG.
%   - rWheel_front : [m] radius of the front wheels
%   - rWheel_rear : [m] radius of the rear wheels
%   - hRC_front : [m] height of the front roll center above the ground
%   - hRC_rear : [m] height of the rear roll center above the ground
%   - trackWidth_front : [m] track width at the front wheels
%   - trackWidth_rear : [m] track width at the rear wheels
%   - wheelBase : [m] wheel base of the vehicle
%   - kRoll : [Nm/deg] total roll stiffness (sum of front and rear roll
%             stiffness
%   - kRoll_pctFrontMin: [unitless] the minimum fraction of total roll
%                        stiffness to consider as front roll stiffness
%   - kRoll_pctFrontMax: [unitless] the maximum fraction of total roll
%                        stiffness to consider as front roll stiffness
%   - kChassis_min : [Nm/deg] minimum chassis stiffness to consider
%   - kChassis_max : [Nm/deg] maximum chassis stiffness to consider
%   - latAcc : [m/s^2] lateral acceleration to use for calculations
% Returns :
%   - k_chassis : [Nm/deg] vector for range of chassis stiffnesses considered
%   - diff_LLTD_per_RSD : |LLTD_r-LLTD_f| / |RSD_r - RSD_f|, where RSD is
%                         roll stiffness distribution as a percent and LLTD
%                         is lateral load transfer distribution as a percent
%                         averaged over RSD = 10-30% front and 70-90%
%                         front. This ignores the near linear portion of
%                         graph and the portion where |RSD_r - RSD_f| = 0
%   - LLT_front : [N] Load transferred from the front inside wheel to the 
%              front outside wheel. Rows vary roll stiffness distribution 
%              from 10-90% front and columns vary chassis stiffness from 
%              kChassis_min to kChassis_max

%   - LLT_rear : [N] Load transferred from the rear inside wheel to the 
%              rear outside wheel. Rows vary roll stiffness distribution 
%              from 10-90% front and columns vary chassis stiffness from 
%              kChassis_min to kChassis_max

% Based on models from:
%	Chalmers University Paper: http://publications.lib.chalmers.se/records/fulltext/191830/191830.pdf
%	SAE Paper : The Effect of Chassis Stiffness on Race Car Handling Balance. Deakin et. al.

    kChassis_dataPoints = 1000; % number of points within the chassis stiffness range provided to use
    kRoll_dataPoints = 160; % number of points to use for front and rear roll stiffness
    
    g = 9.81; % [m/s^2] acceleration due to gravity
    k_front = kRoll.*linspace(kRoll_pctFrontMin, kRoll_pctFrontMax,...
        kRoll_dataPoints); % front suspension stiffness range [Nm/deg]
    k_rear = kRoll.*linspace(1 - kRoll_pctFrontMin, 1 - kRoll_pctFrontMax,...
        kRoll_dataPoints); % rear suspension stiffness range [Nm/deg]
    k_chassis = linspace(kChassis_min, kChassis_max, kChassis_dataPoints); % range of chassis stiffnesses to consider [Nm/deg]
    b = dist_cg_from_rear; % longitudinal distance from rear axle to CG [m]
    a = wheelBase - b; % longitudinal position from front axel to CG [m]
    x = hCG-(a*hRC_rear+b*hRC_front)/(wheelBase); % CG's Height over roll centre axis [m]
    
    M_cg = mSprung*latAcc*x; % Momentum on roll axis from sprung mass [Nm]
    % Moment from unsprung masses on front and rear axle
    MUnsprung_front = latAcc*(rWheel_front-hRC_front)*mUnsprung_front; % [Nm]
    MUnsprung_rear = latAcc*(rWheel_rear-hRC_rear)*mUnsprung_rear; % [Nm]
    
    % Total cornering moment about roll axis, assume chassis stiffness is
    % uniformly distributed and that the location of the CG will determine
    % how much of the CG moment is transfered to the front and rear axle
    M_front_total = MUnsprung_front + (b / (a + b)) * M_cg; % [Nm]
    M_rear_total = MUnsprung_rear + (a / (a + b)) * M_cg; % [Nm]
    
    LLT_front = zeros(kRoll_dataPoints, kChassis_dataPoints);
    LLT_rear = zeros(kRoll_dataPoints, kChassis_dataPoints);
    for iii = 1 : length(k_chassis)
        for jjj = 1 : length(k_front)
            %% Equation system
            % matrix relating angular deflection of suspension and chassis to 
            % moments and continuity equation
            A = [k_front(jjj) 0 -k_chassis(iii);
            0 k_rear(jjj) k_chassis(iii);
            1 -1 1];
            M_array = [M_front_total; M_rear_total; 0];

            angles_of_rotation = A \ M_array; % angles of rotation (front, rear, chassis) [deg]
            LLT_front(jjj, iii) = 1 / trackWidth_front * (k_chassis(iii) * angles_of_rotation(3) + M_front_total); % [N] Front left vertical wheel force - Front right vertical wheel force
            LLT_rear(jjj, iii) = 1 / trackWidth_rear * (-k_chassis(iii) * angles_of_rotation(3) + M_rear_total); % [N] Rear left vertical wheel force - Rear right vertical wheel force
        end
    end
    
    rearLoadDist = LLT_rear./(LLT_front + LLT_rear).*100;
    frontLoadDist = LLT_front./(LLT_front + LLT_rear).*100;
    
    rollStiffness_diff = (k_front ./ (k_front + k_rear) - k_rear ./ (k_front + k_rear)) .* 100;
    
    loadDist_diff = frontLoadDist - rearLoadDist;   
    diff_LLTD_per_RSD = zeros(1, length(k_chassis));
    for iii = 1 : length(k_chassis)
        diff_LLTD_per_RSD(iii) = abs(mean([loadDist_diff(1 : kRoll_dataPoints / 4,iii)', ...
            loadDist_diff(kRoll_dataPoints * 3 / 4 : kRoll_dataPoints, iii)']...
            ./ [rollStiffness_diff(1 : kRoll_dataPoints / 4), ...
            rollStiffness_diff(kRoll_dataPoints * 3 / 4 : kRoll_dataPoints)])); 
    end
end

