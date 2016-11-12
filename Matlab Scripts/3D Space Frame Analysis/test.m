clear all
frame = SpaceFrame();
a = Node(1, [0,1,0], [0,0,0]);
a.addLoad([0,1,1]);
b = Node(2, [1,1,1], [0, 0, 1]);
%b.addLoad([1,0,0]);
c = Node(3, [2,2,1], [1,1,1]);
d = Node(4, [2,0,1], [1,0,1]);

frame.addNode(a);
frame.addNode(b);
frame.addNode(c);
frame.addNode(d);

frame.createTube(a, b, 1, 1);
frame.createTube(b, c, 1, 1);
frame.createTube(b, d, 1, 1);
frame.createTube(a, d, 1, 1);
% frame.createTube(a, c, 1, 1);
%frame.createTube(c, d, 1, 1);
frame.plotFrame();
[A, x, y] = frame.solveFrame();