
% Represents a 3D space frame structure
classdef SpaceFrame < handle
    
    % Method comments duplicated so they are visible both when functions are
    % collapsed and when viewing class documentation via typing doc SpaceFrame
    % in the MATLAB console

    properties
        nodes % an array of nodes in the space frame
        tubes % an array of tubes in the space frame
        confinedNodes % list of nodes that are not free
        numReactionForces % list corresponding to confinedNodes with the number of reation forces at each node
        solved % boolean, true if the space frame has been solved
        maxStress % [Pa] max stress in the frame after solving
        minStress % [Pa] in stress in the frame after solving
    end
    
    methods
        % creates a new space frame with no nodes or tubes
        function obj = SpaceFrame()
            % creates a new space frame with no nodes or tubes
            obj.nodes = [];
            obj.tubes = [];
            obj.confinedNodes = [];
            obj.solved = false;
            obj.maxStress = 0;
            obj.minStress = 0;
        end         
        
        % adds a node to the spaceframe
        % Parameters:
        %   - obj: the space frame object to which the node will be added
        %   - node: the node object to add
        function addNode(obj, node)
        % adds a node to the spaceframe
        % Parameters:
        %   - obj: the space frame object to which the node will be added
        %   - node: the node object to add
            if isa(node, 'SpaceNode')
                obj.nodes = [obj.nodes, node];
                
                if max(node.fixtures) ~= 0
                    obj.confinedNodes = [obj.confinedNodes, node];
                    obj.numReactionForces = [obj.numReactionForces, nnz(node.fixtures)];
                end
            else
                error('Only nodes can be added as a node')
            end
        end
        
        % creates a 4130 steel tube between node1 and node2
        % Parameters:
        %   - obj: the spaceframe in which the tube will be created
        %   - node1: the node object where the tube starts
        %   - node2: the node object where the tube ends
        %   - diameter: the tube diameter in inches
        %   - thickness: the tube thickness in inches
        function createTube(obj, node1, node2, diameter, thickness)
        % creates a 4130 steel tube between node1 and node2
        % Parameters:
        %   - obj: the spaceframe in which the tube will be created
        %   - node1: the node object where the tube starts
        %   - node2: the node object where the tube ends
        %   - diameter: the tube diameter in inches
        %   - thickness: the tube thickness in inches
            id = length(obj.tubes);
            for iii = 1 : length(obj.tubes)
                tube = obj.tubes(iii);
                if tube.id > id
                    id = tube.id + 1;
                end
            end
            
            obj.tubes = [obj.tubes, SpaceTube(id, node1, node2, diameter, thickness)];
        end
        
        % adds the specified tube to the space frame
        % Parameters:
        %   - obj: the space frame to which the tube will be added
        %   - tube: the spaceTube object to add
        function addTube(obj, tube)
        % adds the specified tube to the space frame
        % Parameters:
        %   - obj: the space frame to which the tube will be added
        %   - tube: the spaceTube object to add
            if isa(tube, 'SpaceTube')
                obj.tubes = [obj.tubes, tube];
            else
                error('Only tubes can be added as a tube')
            end
        end
        
        % plots the space frame in a figure. If the frame is solved, tubes
        % are color coded by stress
        function plotFrame(obj)  
        % plots the space frame in a figure. If the frame is solved, tubes
        % are color coded by stress
            figure;
            hold on
            xlabel('X [m]');
            ylabel('Y [m]')
            zlabel('Z [m]')
            plottedNodeIds = [];
            if obj.solved
                colors = jet(1001);
                colormap jet
                bar = colorbar('eastoutside');
                set(bar, 'TickLabels', linspace(obj.minStress, obj.maxStress, 11))
                ylabel(bar, 'Stress [Pa]');
            end
            nodeX = zeros(1, length(obj.nodes));
            nodeY = zeros(1, length(obj.nodes));
            nodeZ = zeros(1, length(obj.nodes));
            nodeLabels = cell(1, length(obj.nodes));
            nodeInd = 1;
            for iii = 1 : length(obj.tubes)
                tube = obj.tubes(iii);
                x = zeros(1, 2);
                y = zeros(1, 2);
                z = zeros(1, 2);
                % plot node1 if not plotted
                if ~any(tube.node1.id==plottedNodeIds)
                    plottedNodeIds = [plottedNodeIds, tube.node1.id]; 
                    nodeX(nodeInd) = tube.node1.position(1);
                    nodeY(nodeInd) = tube.node1.position(2);
                    nodeZ(nodeInd) = tube.node1.position(3);
                    nodeLabels(nodeInd) = {num2str(tube.node1.id)};
                    nodeInd = nodeInd + 1;
                end
                
                % plot node2 if not plotted 
                if ~any(tube.node2.id==plottedNodeIds)
                    plottedNodeIds = [plottedNodeIds, tube.node1.id];
                    nodeX(nodeInd) = tube.node2.position(1);
                    nodeY(nodeInd) = tube.node2.position(2);
                    nodeZ(nodeInd) = tube.node2.position(3);
                    nodeLabels(nodeInd) = {num2str(tube.node2.id)};
                    nodeInd = nodeInd + 1;
                end
                x(1) = tube.node1.position(1);
                y(1) = tube.node1.position(2);
                z(1) = tube.node1.position(3);
                x(2) = tube.node2.position(1);
                y(2) = tube.node2.position(2);
                z(2) = tube.node2.position(3);
                text((x(2) + x(1)) / 2, (y(2) + y(1)) / 2, ...
                    (z(2) + z(1)) / 2, num2str(tube.id))
                if ~obj.solved
                    plot3(x,y,z, 'b')
                else
                    plot3(x, y, z, 'color', colors(floor(abs((tube.stress -...
                        obj.minStress) / (obj.maxStress - obj.minStress)...
                        * 1000)) + 1, :))
                end
            end
            
            plot3(nodeX, nodeY, nodeZ, 'bo')
            text(nodeX, nodeY, nodeZ, nodeLabels)
        end
        
        % creates the matrix defining the forces in the spaceframe and
        % solves. System of equations is defined as A * x = y where x is
        % the force on each tube or a reaction force and y is the applied
        % loads. The order of x is <tube forces>, <reaction forces> where
        % the tube forces are in the order they occur in obj.tubes and 
        % reaction forces are in the order they occur in obj.confinedNodes.
        function [A, x, y] = solveFrame(obj)
        % creates the matrix defining the forces in the spaceframe and
        % solves. System of equations is defined as A * x = y where x is
        % the force on each tube or a reaction force and y is the applied
        % loads. The order of x is <tube forces>, <reaction forces> where
        % the tube forces are in the order they occur in obj.tubes and 
        % reaction forces are in the order they occur in obj.confinedNodes.
        
            % determine number of constraints
            constraints = 0;
            for iii = 1 : length(obj.confinedNodes)
               node =  obj.confinedNodes(iii);
               constraints = constraints + sum(node.fixtures);
            end
            
            % if there are less than 6 contraints, the frame is
            % underdefined and cannot be solved
            if constraints < 6
                error('Space frame is underconstrained and cannot be solved')
            end
            
            % check if the model is statically determinate (number of
            % unknowns <= number of equations
            if constraints + length(obj.tubes) > 3 * length(obj.nodes)
                error('Space frame is statically indeterminate and cannot be solved')
            end
            
            % System is described by
            %   A * x = y
            % where A is a matrix, x is a vector of tube forces and
            % reaction forces, and y is a vector of constants defined by
            % the geometry
            % matrix defining the system
            A = zeros(3 * length(obj.nodes), ...
                           constraints + length(obj.tubes));
            
            y = zeros(3 * length(obj.nodes), 1);
            % the equation currently being created
            equation = 1;
            for iii = 1 : length(obj.nodes)
                node = obj.nodes(iii);
                for jjj = 1 : length(node.tubes)
                    tube = node.tubes(jjj);
                    direction = tube.unitVector; % default points from node1 to node2
                    % ensure vector points away from the node (assume tubes
                    % are in tension)
                    if node == tube.node1
                        % switch direction so it points from node2 to node1
                        direction = -1 .* direction;
                    end
                    
                    index = find(tube == obj.tubes);
                    % node forces in x sum to zero
                    A(equation, index) = direction(1);
                    % node forces in y sum to zero
                    A(equation + 1, index) = direction(2);
                    % node forces in z sum to zero
                    A(equation + 2, index) = direction(3);
                end
                
                index = find(node == obj.confinedNodes, 1);
                % if this node has reaction forces, add them to the matrix
                if ~isempty(index)
                    % find the matrix column corresponding to the node's
                    % reaction forces
                    matIndex = length(obj.tubes) + 1;
                    for jjj = 1 : index - 1
                        matIndex = matIndex + obj.numReactionForces(jjj);
                    end
                    
                    for jjj = 1 : 3
                        % if the node has a reaction force
                        if node.fixtures(jjj) ~= 0
                            % add it to the matrix
                            A(equation + jjj - 1, matIndex) = 1;
                            matIndex = matIndex + 1;
                        end
                    end
                end
                
                % add node loads to the vector y
                y(equation) = node.load(1);
                y(equation + 1) = node.load(2);
                y(equation + 2) = node.load(3);
                
                equation = equation + 3;
            end
            
            % solve the system of equations
            solution = rref([A, y]);
            x = solution(:, end);
            
            for iii = 1 : length(x)
                if x(iii) ~= 0 && nnz(solution(iii, 1 : end - 1)) == 0
                    error(['Cannot be solved. The model is unstable or'...
                           ' one or more members or under bending.'])
                end
            end
            
            % assign results to tubes and calculate max/min stress
            max = 0;
            min = 0;
            for iii = 1 : length(obj.tubes)
                tube = obj.tubes(iii);
                tube.force = x(iii);
                tube.calculateStress();
                if tube.stress > max
                    max = tube.stress;
                elseif tube.stress < min
                    min = tube.stress;
                end
            end
            obj.maxStress = max;
            obj.minStress = min;
            
            % assign reaction forces to nodes
            iii = iii + 1;
            for jjj = 1 : length(obj.confinedNodes)
                node = obj.confinedNodes(jjj);
                node.reactions(node.fixtures == 1) = x(iii : iii + ...
                    sum(node.fixtures) - 1);
                iii = iii + sum(node.fixtures);
            end
            
            obj.solved = true;
            % plot with stress
            obj.plotFrame();
        end
        
        % calculates stiffness using energy methods, sum(strain energy in
        % tube) = work done by torque.
        % Parameters: 
        %   - obj: the space frame object
        %   - torque: the torque applied to the model
        % Returs:
        %   - K: stiffness of the space frame
        function K = calcTorsionalStiffness(obj, torque)
        % calculates stiffness using energy methods, sum(strain energy in
        % tube) = work done by torque.
        % Parameters: 
        %   - obj: the space frame object
        %   - torque: the torque applied to the model
        % Returs:
        %   - K: stiffness of the space frame
            energy = 0; % [J] strain energy in tubes
            for i = 1 : length(obj.tubes)
                tube = obj.tubes(i);
                % strain energy = 1/(2E) * stress^2 * pi * area * length
                energy = energy + 1 / (2 * tube.E) * (tube.stress) ^ 2 * ...
                    pi * ((tube.diameter / 2)^2 - (tube.diameter / 2 - ...
                    tube.thickness) ^2) * tube.length;
            end
            % work = strain energy => T * theta / 2 = strain energy
            theta = (2 * energy / torque) * (180 / pi); % [degrees] angular deflection
            K = torque / theta; % [Nm/deg] stiffness
        end    
    end
    
    methods(Static)
        % creates a space frame object from csv files containing node and
        % tube information. csv files should be generated using the
        % following process:
        %   1. Make a 3D sketch in solidworks
        %   2. select the sketch and run the attached solidworks macro to
        %      generate an excel file with raw data
        %   3. Save the excel file as a csv
        %   4. Run the attached matlab function parse_SWoutput.m on the csv
        %      generated by the macro to generate the proper files for this
        %      package
        %   5. Fill in the node load and fixture information, and tube
        %      property information in the generated node and tube csv
        %      files.
        %   6. Pass the populated node and tube csv files to this function
        %      to create a spaceFrame for analysis
        % Parameters:
        %   - nodeFile: The csv containing node information generated by
        %               following the above process
        %   - tubeFile: the csv containing tube information generated by
        %               following the above process
        % Returns:
        %   - obj: a SpaceFrame object created from the specified files
        function obj = spaceFrameFromFiles(nodeFile, tubeFile)
        % creates a space frame object from csv files containing node and
        % tube information. csv files should be generated using the
        % following process:
        %   1. Make a 3D sketch in solidworks
        %   2. select the sketch and run the attached solidworks macro to
        %      generate an excel file with raw data
        %   3. Save the excel file as a csv
        %   4. Run the attached matlab function parse_SWoutput.m on the csv
        %      generated by the macro to generate the proper files for this
        %      package
        %   5. Fill in the node load and fixture information, and tube
        %      property information in the generated node and tube csv
        %      files.
        %   6. Pass the populated node and tube csv files to this function
        %      to create a spaceFrame for analysis
        % Parameters:
        %   - nodeFile: The csv containing node information generated by
        %               following the above process
        %   - tubeFile: the csv containing tube information generated by
        %               following the above process
        % Returns:
        %   - obj: a SpaceFrame object created from the specified files
            maxFileLines = 100000; % maximum number of file lines to scan
            obj = SpaceFrame(); % create empty frame to populate
            nodeFile = fopen(nodeFile); % open file with node info
            fgets(nodeFile); %skip header line

            for iii = 1 : maxFileLines
                line = fgets(nodeFile);
                if line == -1
                    % found end of file
                    break
                else
                    % format of solidworks macro output is
                    % [ID, X, Y, Z, Load X, Load Y, Load Z, Fixture X, 
                    %  Fixture Y, Fixture Z, Tubes
                    vars = textscan(line, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%s');
                    id = vars{1};
                    position = [vars{2:4}];
                    load = [vars{5:7}];
                    fixtures = [vars{8:10}];
                    node = SpaceNode(id, position, fixtures);
                    node.addLoad(load);
                    obj.addNode(node);
                end
            end
            
            fclose(nodeFile); % close node file
            
            tubeFile = fopen(tubeFile); % open file with tube info
            fgets(tubeFile); %skip header line
            
            for iii = 1 : maxFileLines
                line = fgets(tubeFile);
                if line == -1
                    % found end of file
                    break
                else
                    % format of solidworks macro output is
                    % [ID, Node1, Node2, diameter, thickness, E, sigma_y,
                    % sigma_u]
                    vars = textscan(line, '%f,%f,%f,%f,%f,%f,%f,%f');
                    id = vars{1};
                    node1 = obj.nodes(vars{2});
                    node2 = obj.nodes(vars{3});
                    diameter = vars{4};
                    thickness = vars{5};
                    E = vars{6};
                    sigma_y = vars{7};
                    sigma_u = vars{8};
                    tube = SpaceTube(id, node1, node2, diameter, thickness, ...
                        'E', E, 'sigma_y', sigma_y, 'sigma_u', sigma_u);
                    obj.addTube(tube);
                end
            end
            
            fclose(tubeFile); % close node file
        end
    end 
end

