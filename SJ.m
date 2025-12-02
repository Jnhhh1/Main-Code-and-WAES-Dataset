clear all; clc;
tic;

rng(123); 

% startTime = datetime(2025,6,30);% seconds
% stopTime = startTime+seconds(500);
% sampleTime = 100; 

startTime = datetime(2025,6,30)+seconds(500);% seconds
stopTime = startTime+seconds(1500);
sampleTime = 200; 

sc = satelliteScenario(startTime,stopTime,sampleTime);


leosat = satellite(sc,"E:\MATLAB2024\mcr\toolbox\shared\orbit\orbitdata\leoSatelliteConstellation.tle");
sat = leosat(1:40);

numSatellites = numel(sat);

taiwanShapefile = 'E:\World_countries.shp'; 
WorldBoundary = shaperead(taiwanShapefile, 'UseGeoCoords', true);


function randomPoints = generateRandomPoints(polygon, numPoints)
    minLat = min(polygon.Lat);
    maxLat = max(polygon.Lat);
    minLon = min(polygon.Lon);
    maxLon = max(polygon.Lon);

    randomPoints = zeros(numPoints, 2); 
    for i = 1:numPoints
        lat = minLat + (maxLat - minLat) * rand();
        lon = minLon + (maxLon - minLon) * rand();

        
        while ~inpolygon(lon, lat, polygon.Lon, polygon.Lat) || isequal([lon, lat], [0, 0])
            lat = minLat + (maxLat - minLat) * rand();
            lon = minLon + (maxLon - minLon) * rand();
        end
        randomPoints(i, :) = [lon, lat]; 
    end
end

numPoints = 5000; 
numRegions = 248; 


randomPoints = [];


areas = zeros(numRegions, 1);
for i = 1:numRegions
    boundingBox = WorldBoundary(i).BoundingBox;
    area = abs((boundingBox(2) - boundingBox(1)) * (boundingBox(4) - boundingBox(3))); 
    areas(i) = area; 
end


totalArea = sum(areas);


pointsPerRegion = round((areas / totalArea) * numPoints); 


southPoleRegionIndex = 100; 
pointsPerRegion(southPoleRegionIndex) = max(1, pointsPerRegion(southPoleRegionIndex) - 70); 


pointsPerRegion(pointsPerRegion < 1) = 1;


remainingPoints = numPoints - sum(pointsPerRegion);


while remainingPoints > 0
   
    regionIndex = randi(numRegions);

    
    pointsPerRegion(regionIndex) = pointsPerRegion(regionIndex) + 1;

   
    remainingPoints = remainingPoints - 1;
end



for i = 1:numRegions

    currentRegionBoundary = WorldBoundary(i);
    regionPoints = generateRandomPoints(currentRegionBoundary, pointsPerRegion(i)); 


    randomPoints = [randomPoints; regionPoints]; 


    %remainingPoints = remainingPoints - pointsInRegion; 

end


currentRegionBoundary = WorldBoundary(numRegions);
regionPoints = generateRandomPoints(currentRegionBoundary, remainingPoints);
randomPoints = [randomPoints; regionPoints];

%randomPoints = load('randompoints.mat');
%randomPoints=randomPoints.randomPoints;

groundSources = groundStation(sc, randomPoints(:,2), randomPoints(:,1));
v = satelliteScenarioViewer(sc);
%play(sc)


figure;
geoshow(WorldBoundary, 'FaceColor', 'none', 'EdgeColor', 'red');
hold on;
plot(randomPoints(:,1), randomPoints(:,2), 'o', 'MarkerFaceColor', 'b', "MarkerSize",4);
title('Random Points within Taiwan Boundary (excluding [0,0])');
xlabel('Longitude');
ylabel('Latitude');
grid on;
hold off;



toc;