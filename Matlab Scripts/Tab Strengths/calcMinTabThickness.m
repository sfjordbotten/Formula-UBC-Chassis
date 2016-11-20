function [thickness, mode] = calcMinTabThickness(force, Sy, edge_dist,...
    d_bolt, width)
% calculates the min thickness to aviod failure for a tab with the given 
% geometry and load

% falure modes array
modes = {'Bearing', 'Edge Shear', 'Tensile Yield'};

% Bearing in members
% stress = force / area = Strength
t_bearing = force / (d_bolt * Sy);

% Edge shearing of members 
% shear = force / (edge_dist * thickness) = 0.577 * Strength = shear
% strength
t_shear = force / (edge_dist * 0.577 * Sy);

% Tensile yield
% stress = force / (width - d_bolt) / thickness = strength
t_tensile = force / ((width - d_bolt) * Sy);

thicknesses = [t_bearing, t_shear, t_tensile];
thickness = max(thicknesses);
mode = modes(thicknesses == thickness);

end
