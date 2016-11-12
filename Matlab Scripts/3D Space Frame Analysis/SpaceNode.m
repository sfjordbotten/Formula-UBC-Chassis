classdef SpaceNode < handle
    % Represents a node in a 3D space frame
    
    % Method comments duplicated so they are visible both when functions are
    % collapsed and when viewing class documentation via typing doc SpaceFrame
    % in the MATLAB console
    properties
        id % number to identify the node
        position % [m] the nodes position in cartesian co-ordinate, as a vector
        load % [N] external force on the node as a vector
        fixtures % vector defining whether or not there are reaction forces 0 = free, 1 = force
        reactions % [N] reaction force on the node as a vector
        tubes % list of tubes that end at the node
    end
    
    methods
        % constructs a node with the given ID and position
        % Parameters:
        %   -id (required): the id number for the node
        %   - position (required): [m] vector defining the cartesian
        %           co-ordiates of the node
        function obj = SpaceNode(id, position, fixtures)
        % constructs a node with the given ID and position
        % Parameters:
        %   -id (required): the id number for the node
        %   - position (required): [m] vector defining the cartesian
        %           co-ordiates of the node
            obj.id = id;
            obj.position = position;
            obj.load = [0, 0, 0];
            obj.reactions = [0, 0, 0];
            obj.fixtures = fixtures;
            obj.tubes = [];
        end
        
        % Adds a load to the node
        % Parameters:
        %   - obj (required): the node to which the load will be added
        %   - load (required): [N] a vector defining the load to add to the
        %           node
        function addLoad(obj, load)
        % Adds a load to the node
        % Parameters:
        %   - obj (required): the node to which the load will be added
        %   - load (required): [N] a vector defining the load to add to the
        %           node
            obj.load = obj.load + load;
        end
    end
    
end

