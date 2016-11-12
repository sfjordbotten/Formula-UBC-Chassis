function [ F_tires ] = calc_vertTireForces( F_front, F_rear, Faero_front, Faero_rear, mSprung, mUnsprung_front, mUnsprung_rear, dist_cg_from_rear, wheelBase)
% Calculates the vertical force on each wheel given the difference beween
% left and right wheel forces, mass values, and CG position
% Parameters:
%   - F_front: [N] force outside - force inside for at the front tires while
%              cornering.
%   - F_rear: [N] force outside - force inside for at the rear tires while
%              cornering.
%   - mSprung: [kg] Sprung vehicle mass, including driver.
%   - mUnsprung_front: [kg] unsprung mass of front components
%   - mUnsprung_rear: [kg] unsprung mass of rear components
%   - dist_cg_from_rear: [m] longitudinal distance from the rear axle to
%                         the CG.
%   - wheelBase : [m] wheel base of the vehicle
% Returns:
%   - F_tires: [N] an array of vertical tire forces in the following format
%              [front outside, front inside, rear outside, rear inside]. If
%              F_front and F_rear are vectors or matricies, the output will
%              be a matrix with an added dimension corresponding to the
%              tire forces for each F_front and F_rear pair.

g = 9.81; % [m/s^2] acceleration due to gravity
F_frontInside = (g * (mUnsprung_front + (dist_cg_from_rear / wheelBase) * ...
                 mSprung) + Faero_front - F_front) / 2;
F_frontOutside = F_front + F_frontInside;
F_rearInside = (g * (mUnsprung_rear + ((wheelBase - dist_cg_from_rear) ...
                / wheelBase) * mSprung) + Faero_rear - F_rear) / 2;
F_rearOutside = F_rear +  F_rearInside;

F_tires = cat(3, F_frontOutside, F_frontInside, F_rearOutside, F_rearInside);

end

