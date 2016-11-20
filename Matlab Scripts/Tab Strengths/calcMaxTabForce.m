function [force, mode] = calcMaxTabForce(Sy, thickness, edge_dist,...
    d_bolt, width)
% calculates the max force to failure for a tab with the given geometry

% falure modes array
modes = {'Bearing', 'Edge Shear', 'Tensile Yield'};

% Bearing in members
% stress = force / area = Strength
F_bearing = thickness * d_bolt * Sy;

% Edge shearing of members 
% shear = force / (edge_dist * thickness) = 0.577 * Strength = shear
% strength
F_shear = edge_dist * thickness * 0.577 * Sy;

% Tensile yield
% stress = force / (width - d_bolt) / thickness = strength
F_tensile = (width - d_bolt) * thickness * Sy;

forces = [F_bearing, F_shear, F_tensile];
force = min(forces);
mode = modes(forces == force);

end
