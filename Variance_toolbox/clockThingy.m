

function clockThingy(center, radius, color, edgeColor, handColor, range, currentTime)

circleFill(center,radius,color,2,edgeColor);

startLoc = center;
endLoc = center + radius*[ sin(currentTime/range * 2*pi), cos(currentTime/range * 2*pi) ];

h = plot([startLoc(1), endLoc(1)], [startLoc(2), endLoc(2)]);
set(h, 'linewidth', 3, 'color', handColor);

