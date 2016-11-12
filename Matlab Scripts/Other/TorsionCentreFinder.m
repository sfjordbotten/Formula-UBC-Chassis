close all;

d1 = 2.186/1000;
x1 = 0.5257927;
y1 = 0.24116792;

d2 = 2.23/1000;
x2 = 0.17;
y2 = 0.619;

d3 = 0.607/1000;
x3 = 0.1732407;
y3 = 0.11571732;

%boundaries of rearward projection of bulkhead
xmin = -6.375;
xmax = 6.375;
ymin = 4.6;
ymax = 16.5765;
ymax = 1000;
xmin = -1000;
min = 5000000;
cx = [];
cy = [];

hold on
for x = xmin : 0.1 : xmax
    for y = ymin : 0.1 : ymax
        t1 = acos(1-d1^2/2/((x1-x)^2+(y1-y)^2));
        t2 = acos(1-d2^2/2/((x2-x)^2+(y2-y)^2));
        t3 = acos(1-d3^2/2/((x3-x)^2+(y3-y)^2));
        
        ave = (t1 + t2 + t3)/3;
        test = abs(ave - t1) + abs(ave - t2) + abs(ave - t3);
        if test < min
            min = test;
            cx = [cx x];
            cy = [cy y];
        end
    end
end

plot(cx,cy)

        