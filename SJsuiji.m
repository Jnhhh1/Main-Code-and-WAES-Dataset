clear all; clc;
tic;

%rng(123); % 


% startTime = datetime(2025,6,30);% seconds
% stopTime = startTime+seconds(500);
% sampleTime = 100; 

startTime = datetime(2025,6,30)+seconds(500);% seconds
stopTime = startTime+seconds(1500);
sampleTime = 200;                                    % seconds
sc = satelliteScenario(startTime,stopTime,sampleTime);


leosat = satellite(sc,"E:\MATLAB2024\mcr\toolbox\shared\orbit\orbitdata\leoSatelliteConstellation.tle");
sat = leosat(1:40);

numSatellites = numel(sat) 

taiwanShapefile = 'F:\World_countries.shp'; 
WorldBoundary = shaperead(taiwanShapefile, 'UseGeoCoords', true);

% % 
% function randomPoints = generateRandomPoints(polygon, numPoints)
%     minLat = min(polygon.Lat);
%     maxLat = max(polygon.Lat);
%     minLon = min(polygon.Lon);
%     maxLon = max(polygon.Lon);
% 
%     randomPoints = zeros(numPoints, 2); 
%     for i = 1:numPoints
%         lat = minLat + (maxLat - minLat) * rand();
%         lon = minLon + (maxLon - minLon) * rand();
% 
%         %  
%         while ~inpolygon(lon, lat, polygon.Lon, polygon.Lat) || isequal([lon, lat], [0, 0])
%             lat = minLat + (maxLat - minLat) * rand();
%             lon = minLon + (maxLon - minLon) * rand();
%         end
%         randomPoints(i, :) = [lon, lat]; 
%     end
% end

numPoints = 5000; 
numRegions = 248;

% % 
% randomPoints = [];
% 
% % 
% areas = zeros(numRegions, 1);
% for i = 1:numRegions
%     boundingBox = WorldBoundary(i).BoundingBox;
%     area = abs((boundingBox(2) - boundingBox(1)) * (boundingBox(4) - boundingBox(3))); 
%     areas(i) = area; 
% end
% 
% % 
% totalArea = sum(areas);
% 
% % 
% pointsPerRegion = round((areas / totalArea) * numPoints); 
% 
% % 
% southPoleRegionIndex = 100; 
% pointsPerRegion(southPoleRegionIndex) = max(1, pointsPerRegion(southPoleRegionIndex) - 70); 
% 
% % 
% pointsPerRegion(pointsPerRegion < 1) = 1;
% 
% % 
% remainingPoints = numPoints - sum(pointsPerRegion);
% 
% % 
% while remainingPoints > 0
%     
%     regionIndex = randi(numRegions);
% 
%    
%     pointsPerRegion(regionIndex) = pointsPerRegion(regionIndex) + 1;
% 
%     
%     remainingPoints = remainingPoints - 1;
% end
% 
% 

% for i = 1:numRegions
%     
%     currentRegionBoundary = WorldBoundary(i); 
%     regionPoints = generateRandomPoints(currentRegionBoundary, pointsPerRegion(i));
% 
%    
%     randomPoints = [randomPoints; regionPoints]; 
% 
%    
%     %remainingPoints = remainingPoints - pointsInRegion; 
% 
% end


% currentRegionBoundary = WorldBoundary(numRegions);
% regionPoints = generateRandomPoints(currentRegionBoundary, remainingPoints); 
% randomPoints = [randomPoints; regionPoints]; 

randomPoints = load('randompoints.mat');
randomPoints=randomPoints.randomPoints;

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


% frequency = 2e9;
% amplitude = 1;  
% integrationTime = 0.1; )
% samplingFrequency = 1e8; 
% numSamples = round(integrationTime * samplingFrequency); 
% t = (0:numSamples-1) / samplingFrequency; 
% signal = amplitude * cos(2*pi*frequency*t); 


% % Fs = 5e8;         
% % T = 0.1;            
% % t = 0:1/Fs:T-1/Fs;   
% % 
% % Fc = 2e9;         
% % Fb = 1e6;            
% % 
% % SNR = 10;           
% % 
% % 
% % baseband_signal = sin(2*pi*Fb*t);
% % zaibopower=100; 
% % 
% % 
% % modulation_index = 0.5; 
% % modulated_signal = (1 + modulation_index*baseband_signal) .* zaibopower.*cos(2*pi*Fc*t);
% % 
% % 
% % signal_power = sum(modulated_signal.^2/50) / length(modulated_signal);
% % noise_power = signal_power / (10^(SNR/10));
% % noise = sqrt(noise_power*100) * randn(size(t));  
% % received_signal = modulated_signal + noise;
% % 
% % 
% % rectified_signal = abs(received_signal);
% % 
% % 
% % window_size = round(Fs / (2*Fb));  
% % if window_size > 1
% %   demodulated_signal = movmean(rectified_signal, window_size);
% % else
% %   demodulated_signal = rectified_signal; 
% % end
% % 
% % 
% % signal = demodulated_signal - mean(demodulated_signal);
% % 
% % 
% % timeVector = startTime:seconds(sampleTime):stopTime;
% % numTimeSteps = length(timeVector);
% % 
% % 
% % results = cell(numSatellites, numTimeSteps);
% % 
% % for i = 1:numSatellites
% %     for t = 1:numTimeSteps
% %         results{i, t} = zeros(3, numPoints); 
% %     end
% % end
% % 
% % 
% % timeVector = startTime:seconds(sampleTime):stopTime;
% % numTimeSteps = length(timeVector);


% hWaitbar = waitbar(0, 'please waiting...0');
% for timeIndex = 1:numTimeSteps
%     currentTime = timeVector(timeIndex); % Get the current time
% 
%     for satIndex = 1:numSatellites
% 
%         azimuth = zeros(1, numPoints); 
%         elevation = zeros(1, numPoints); 
%         receivedPower = zeros(1, numPoints); 
% 
% 
%         for sourceIndex = 1:numPoints
%             [az, ele, distance] = aer(sat(satIndex),groundSources(sourceIndex),currentTime,coordinateFrame='ned');
%             [azimuth_query, elevation_query, distance1] = aer(groundSources(sourceIndex),sat(satIndex),currentTime,coordinateFrame='ned');
% 
% 
% 
% 
%             elevation_deg = 0:0.1:90; 
% 
%             azimuth_deg = 0:0.1:360; 
% 
%             [Az, El] = meshgrid(azimuth_deg, elevation_deg);
% 
%             Az_rad = deg2rad(Az);
%             El_rad = deg2rad(El);
% 
% 
%             mainBeamPitch_deg = randi([0, 90]);
% 
%             mainBeamYaw_deg = randi([0, 359]);
% 
%             beamwidth_deg = randi([20, 80]);
% 
% 
% 
%             mainBeamPitch_rad = deg2rad(mainBeamPitch_deg);
%             mainBeamYaw_rad = deg2rad(mainBeamYaw_deg);
%             beamwidth_rad = deg2rad(beamwidth_deg);
% 
% 
%             sigma_rad = (beamwidth_rad / 2) / sqrt(2 * log(2));
% 
% 
%             X_grid = sin(El_rad) .* cos(Az_rad);
%             Y_grid = sin(El_rad) .* sin(Az_rad);
%             Z_grid = cos(El_rad);
% 
% 
%             X_mb = sin(pi/2-mainBeamPitch_rad) * cos(mainBeamYaw_rad);
%             Y_mb = sin(pi/2-mainBeamPitch_rad) * sin(mainBeamYaw_rad);
%             Z_mb = cos(pi/2-mainBeamPitch_rad);
% 
% 
%             dot_product = X_grid * X_mb + Y_grid * Y_mb + Z_grid * Z_mb;
% 
% 
%             dot_product = min(max(dot_product, -1), 1);
% 
% 
%             angular_separation_rad = acos(dot_product);
% 
% 
%             main_lobe_pattern = exp(-(angular_separation_rad.^2) / (2 * sigma_rad^2));
% 
% 
%             num_sidelobes = 8; 
%             sidelobe_beamwidth_deg = 30; 
%             sidelobe_sigma_rad = (deg2rad(sidelobe_beamwidth_deg) / 2) / sqrt(2 * log(2)); % sigma
%             max_sidelobe_offset_deg = 150; 
%             min_sidelobe_level_dB = -15; 
%             max_sidelobe_level_dB = -6; 
% 
%             combined_pattern = main_lobe_pattern; 
% 
% 
%             for i = 1:num_sidelobes
% 
%                 sidelobe_level_dB = min_sidelobe_level_dB + (max_sidelobe_level_dB - min_sidelobe_level_dB) * rand();
%                 sidelobe_level_linear = 10^(sidelobe_level_dB/10); 
% 
% 
%                 sidelobe_pitch_offset_deg = (rand() - 0.5) * 2 * max_sidelobe_offset_deg; %  -50 - 50
%                 sidelobe_yaw_offset_deg = (rand() - 0.5) * 2 * max_sidelobe_offset_deg;   %  -50 - 50
% 
% 
%                 sidelobe_pitch_deg = mainBeamPitch_deg + sidelobe_pitch_offset_deg;
%                 sidelobe_yaw_deg = mainBeamYaw_deg + sidelobe_yaw_offset_deg;
% 
% 
%                 sidelobe_pitch_deg = max(0, min(sidelobe_pitch_deg, 90));
% 
% 
%                 sidelobe_yaw_deg = mod(sidelobe_yaw_deg, 360);
% 
% 
%                 sidelobe_pitch_rad = deg2rad(sidelobe_pitch_deg);
%                 sidelobe_yaw_rad = deg2rad(sidelobe_yaw_deg);
% 
% 
%                 X_sl = sin(pi/2-sidelobe_pitch_rad) * cos(sidelobe_yaw_rad);
%                 Y_sl = sin(pi/2-sidelobe_pitch_rad) * sin(sidelobe_yaw_rad);
%                 Z_sl = cos(pi/2-sidelobe_pitch_rad);
% 
% 
%                 dot_product_sl = X_grid * X_sl + Y_grid * Y_sl + Z_grid * Z_sl;
% 
% 
%                 dot_product_sl = min(max(dot_product_sl, -1), 1);
% 
% 
%                 angular_separation_rad_sl = acos(dot_product_sl);
% 
% 
%                 sidelobe_pattern = sidelobe_level_linear * exp(-(angular_separation_rad_sl.^2) / (2 * sidelobe_sigma_rad^2));
% 
% 
%                 combined_pattern = combined_pattern + sidelobe_pattern;
%             end
% 
% 
%             normalized_pattern = combined_pattern / max(combined_pattern(:));
% 
% 
%             pattern_dB = 10 * log10(normalized_pattern);
% 
% 
%             min_dB_display = -30; % 
%             pattern_dB(pattern_dB < min_dB_display) = min_dB_display;
            
             
            % figure;
            % set(gcf, 'Color', 'w'); 
            % 
            % X_plot = normalized_pattern .* sin(El_rad) .* cos(Az_rad); 
            % Y_plot = normalized_pattern .* sin(El_rad) .* sin(Az_rad); 
            % Z_plot = normalized_pattern .* cos(El_rad);
            % 
            % surf(X_plot, Y_plot, Z_plot, pattern_dB, 'EdgeColor', 'none');
            % colormap('jet'); 
            % colorbar;
            % caxis([min_dB_display, 0]); 
            % 
            % axis equal; 
            % grid on;
            % hold on;
          
            % X_mb_vec = sin(pi/2-mainBeamPitch_rad) * cos(mainBeamYaw_rad);
            % Y_mb_vec = sin(pi/2-mainBeamPitch_rad) * sin(mainBeamYaw_rad);
            % Z_mb_vec = cos(pi/2-mainBeamPitch_rad);
            % 
            % % 
            % plot3([0 X_mb_vec], [0 Y_mb_vec], [0 Z_mb_vec], 'r--', 'LineWidth', 2, 'DisplayName', 'main beam pointing');
            % 
            % % 
            % xlabel('North (X)'); % 
            % ylabel('East(Y)'); % 
            % zlabel('Zenith(Z)'); % 
            
         
            % view(3); 
            
            % set(gca, 'YDir', 'reverse');
            
            
            
            % camorbit(30, 0); 
            % camzoom(1.2);   
            
            % pattern_value = getAntennaPatternValue(azimuth_query, elevation_query, Az_rad, El_rad, normalized_pattern);
           

            
            % if ele > 0
            %     continue; 
            % 
            % elseif ele < 0
            %     ele = 90 - abs(ele);
            % end
            % 
            % 
            % if ele > 40.92
            % 
            % 
            %     continue; 
            % end
            % 
            % 
            % if distance > 1200000
            %     continue; 
            % end
            % 
            % azimuth(sourceIndex) = az; 
            % elevation(sourceIndex) = ele; 
            % 
            % distance_km = distance / 1000;  
            % frequency_MHz = Fc / 1e6;       
            % FSPL_dB = 20*log10(distance_km) + 20*log10(frequency_MHz) + 32.44;
            % 
            % PtGAin=30*pattern_value;   %(dB)
            % PrGAin=10;   %(dB)
            % AllGain=FSPL_dB-PtGAin-PrGAin;
            % 
            % %signalEnergy = abs(signal(1));
            % %signalEnergy = sum(((abs(signal).^2)*(10.^(-AllGain/10))))/5e7;
            % signalEnergy = sum(((abs(signal).^2)*(10.^(-AllGain/10))))/5e7/2/1e8/1.38e-23/50;
            % %signalEnergy = sum((abs(signal)*(10.^(-AllGain/10))));
            
            
    %         results{satIndex,timeIndex}(1, sourceIndex) = signalEnergy;
    %         results{satIndex,timeIndex}(2, sourceIndex) = elevation(sourceIndex);
    %         results{satIndex,timeIndex}(3, sourceIndex) = azimuth(sourceIndex);
    % 
    %     end
    % end
%     disp(['Processing time step: ', num2str(timeIndex), ' of ', num2str(numTimeSteps)]);
%     waitbar(timeIndex/numTimeSteps, hWaitbar, sprintf(' %d / %d', timeIndex, numTimeSteps));
% end

% function patternValue = getAntennaPatternValue(azimuth_deg, elevation_deg, Az, El, normalized_pattern)
% 
%                 azimuth_rad = deg2rad(azimuth_deg);
%                 elevation_rad = deg2rad(elevation_deg);
% 
% 
%                 X = sin(pi/2-elevation_rad) .* cos(azimuth_rad);
%                 Y = sin(pi/2-elevation_rad) .* sin(azimuth_rad);
%                 Z = cos(pi/2-elevation_rad);
% 
% 
%                 distances = (sin(El) .* cos(Az) - X).^2 + (sin(El) .* sin(Az) - Y).^2 + (cos(El) - Z).^2;
%                 [~, index] = min(distances(:));
% 
% 
%                 patternValue = normalized_pattern(index);
% end
toc;