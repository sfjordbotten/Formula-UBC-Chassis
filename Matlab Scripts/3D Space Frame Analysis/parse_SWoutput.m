function [nodes, tubes] = parse_SWoutput(fileName)
% parses data from solidworks macro to create spreadsheet for defining a
% space frame and its loads

maxFileLines = 100000; % maximum number of file lines to scan

file = fopen(fileName, 'r'); % open file
fgets(file); % skip header line

% tracks existing node positions
nodePos = [];
nodes = [];
tubes = [];

% search file, up to max 100000 lines
for iii = 1 : maxFileLines
    line = fgets(file);
    if line == -1
        % found end of file
        break
    else
        % format of solidworks macro output is
        % [tube id, Node1 X, Node1 Y, Node1 Z, Node2 X, Node2 Y, Node2 Z]
        vars = textscan(line, '%f,%f,%f,%f,%f,%f,%f');
        tubeid = vars(1);
        tubeid = tubeid{1} + 1;
        node1 = vars(2 : 4);
        node1 = [node1{:}];
        node2 = vars(5 : 7);
        node2 = [node2{:}];
        if ~isempty(nodePos)
            ind = (nodePos(:, 1) == node1(1) & nodePos(:, 2) == node1(2) ...
                    & nodePos(:, 3) == node1(3));
            if max(ind) == 0
                node1ID = length(nodes) + 1;
                nodes = [nodes, SpaceNode(node1ID , node1, [0, 0, 0])];
                nodePos = [nodePos; node1];
            else
                node1ID = find(ind);
            end
            
            ind = (nodePos(:, 1) == node2(1) & nodePos(:, 2) == node2(2) ...
                    & nodePos(:, 3) == node2(3));
            if max(ind) == 0
                node2ID = length(nodes) + 1;
                nodes = [nodes, SpaceNode(node2ID , node2, [0, 0, 0])];
                nodePos = [nodePos; node2];
            else
                node2ID = find(ind);
            end
        else
            node1ID = 1;
            node2ID = 2;
            nodes = [SpaceNode(node1ID , node1, [0, 0, 0]), SpaceNode(node2ID , node2, [0, 0, 0])];
            nodePos = [node1; node2];
        end
        
        tubes = [tubes, SpaceTube(tubeid, nodes(node1ID), nodes(node2ID), -1, -1)];
    end
end

fclose(file);
fileName = strrep(fileName, '.csv', '');
nodeFile = fopen([fileName, '_nodes.csv'], 'w');
fprintf(nodeFile, ['ID, X (m), Y (m), Z (m), Load X (N), Load Y (N), Load Z (N), '...
    'Fixture X (0/1), Fixture Y (0/1), Fixture Z (0/1)\n']);

for iii = 1 : length(nodes)
    node = nodes(iii);
    fprintf(nodeFile, '%i, %f, %f, %f, , , , , , ,', node.id, ...
        node.position(1), node.position(2), node.position(3));
    fprintf(nodeFile, '\n');
end
fclose(nodeFile);

tubeFile = fopen([fileName, '_tubes.csv'], 'w');
fprintf(tubeFile, ['ID, Node1, Node2, diameter (in), thickness (in), E (Pa), '...
    'sigma_y (Pa), sigma_u (Pa)\n']);
for iii = 1 : length(tubes)
    tube = tubes(iii);
    fprintf(tubeFile, '%i, %i, %i, , , , , ,\n', tube.id, tube.node1.id, ...
        tube.node2.id);
end
fclose(tubeFile);

frame = SpaceFrame();
for iii = 1 : length(nodes)
    frame.addNode(nodes(iii));
end

for iii = 1 : length(tubes)
    frame.addTube(tubes(iii));
end

frame.plotFrame();
end

