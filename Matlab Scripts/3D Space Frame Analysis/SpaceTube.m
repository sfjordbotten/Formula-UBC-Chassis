classdef SpaceTube < handle
    % Represents a tube in a 3D spaceframe
    
    % Method comments duplicated so they are visible both when functions are
    % collapsed and when viewing class documentation via typing doc SpaceFrame
    % in the MATLAB console
    properties
        id % number to identify the tube
        node1 % the node that defines one end of the tube
        node2 % the node that defines the second end of the tube
        diameter % [m] outside diameter of the tube
        thickness % [m] wall thickness of the tube
        E % [Pa] young's modulus for the tube material
        sigma_y % [Pa] yeild strength for the tube material
        sigma_u % [Pa] ultimate strength for the tube material
        unitVector % unit vector along the tube, pointing from node1 to node 2
        length % [m] length of the tube
        tubeVector % [m] vector with the magnitude and direction of the tube
        force % [N] the force acting on the tube
        stress % [Pa] the axial stress on the tube
    end
    
    methods
        % Creates a tube as a straight line between the specified nodes and
        % with the specified geometric and material properties
        % Parameters:
        %   -id (required): a number to identify the node
        %   -node1 (required): the node where the tube starts
        %   -node2 (required): the node where the tube ends
        %   -diameter (required): the diameter of the tube in inches
        %   -thickness (required): the wall thickness of the tube in inches
        %   -E (optional name-value pair): the youngs modulus of the tube
        %           in Pascals. Corresponds to 4130 steel by default
        %   -sigma_y (optional name-value pair): yeild strength of the tube
        %           material in pascals. Corresponds to 4130 steel by default.
        %   -sigma_u (optional name-value pair): ultimate strength of the tube
        %           material in pascals.. Corresponds to 4130 steel by 
        %           default.
        function obj = SpaceTube(id, node1, node2, diameter, thickness, varargin)
        % Creates a tube as a straight line between the specified nodes and
        % with the specified geometric and material properties
        % Parameters:
        %   -id (required): a number to identify the node
        %   -node1 (required): the node where the tube starts
        %   -node2 (required): the node where the tube ends
        %   -diameter (required): the diameter of the tube in inches
        %   -thickness (required): the wall thickness of the tube in inches
        %   -E (optional name-value pair): the youngs modulus of the tube
        %           in Pascals. Corresponds to 4130 steel by default
        %   -sigma_y (optional name-value pair): yeild strength of the tube
        %           material in pascals. Corresponds to 4130 steel by default.
        %   -sigma_u (optional name-value pair): ultimate strength of the tube
        %           material in pascals.. Corresponds to 4130 steel by 
        %           default.
            p = inputParser;
            default_E = 100e9; % [Pa] TODO update to real value
            default_Sy = 100e6; % [Pa] TODO update to real value
            default_Su = 100e6; % [Pa] TODO update to real value
            addRequired(p, 'id', @isnumeric);
            addRequired(p, 'node1', @(x) isa(x, 'SpaceNode'));
            addRequired(p, 'node2', @(x) isa(x, 'SpaceNode'));
            addRequired(p, 'diameter', @isnumeric);
            addRequired(p, 'thickness', @isnumeric);
            addParameter(p, 'E', default_E, @isnumeric);
            addParameter(p, 'sigma_y', default_Sy, @isnumeric);
            addParameter(p, 'sigma_u', default_Su, @isnumeric);
            parse(p, id, node1, node2, diameter, thickness, varargin{:});
            
            % if inputs were valid, initialize tube properties
            obj.id = p.Results.id;
            obj.node1 = p.Results.node1;
            obj.node2 = p.Results.node2;
            obj.diameter = p.Results.diameter * 25.4 / 1000;
            obj.thickness = p.Results.thickness * 25.4 / 1000;
            obj.E = p.Results.E;
            obj.sigma_y = p.Results.sigma_y;
            obj.sigma_u = p.Results.sigma_u;
            obj.tubeVector = obj.node2.position - obj.node1.position;
            obj.length = norm(obj.tubeVector);
            obj.unitVector = obj.tubeVector./obj.length;
            
            obj.node1.tubes = [obj.node1.tubes, obj];
            obj.node2.tubes = [obj.node2.tubes, obj];
        end
        
        % calculates the stress in a tube based on its diameter, area,
        % thickness, and force applied
        function calculateStress(obj)
        % calculates the stress in a tube based on its diameter, area,
        % thickness, and force applied
            area = (pi / 4) * (obj.diameter^2 - (obj.diameter - ...
                    obj.thickness) ^ 2); % [m^2]
            obj.stress = obj.force / area; % [Pa]
        end
    end
    
end

