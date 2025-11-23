clear all; clc;


elevation_deg = 0:0.1:90;

azimuth_deg = 0:0.1:360; 

[Az, El] = meshgrid(azimuth_deg, elevation_deg);

Az_rad = deg2rad(Az);
El_rad = deg2rad(El);

mainBeamPitch_deg = 0;

mainBeamYaw_deg = 0;

beamwidth_deg = randi([5, 30]);

mainBeamPitch_rad = deg2rad(mainBeamPitch_deg);
mainBeamYaw_rad = deg2rad(mainBeamYaw_deg);
beamwidth_rad = deg2rad(beamwidth_deg);


sigma_rad = (beamwidth_rad / 2) / sqrt(2 * log(2));


X_grid = sin(El_rad) .* cos(Az_rad);
Y_grid = sin(El_rad) .* sin(Az_rad);
Z_grid = cos(El_rad);


X_mb = sin(pi/2-mainBeamPitch_rad) * cos(mainBeamYaw_rad);
Y_mb = sin(pi/2-mainBeamPitch_rad) * sin(mainBeamYaw_rad);
Z_mb = cos(pi/2-mainBeamPitch_rad);


dot_product = X_grid * X_mb + Y_grid * Y_mb + Z_grid * Z_mb;


dot_product = min(max(dot_product, -1), 1);


angular_separation_rad = acos(dot_product);


main_lobe_pattern = exp(-(angular_separation_rad.^2) / (2 * sigma_rad^2));


num_sidelobes = 8; 
sidelobe_beamwidth_deg = 30; 
sidelobe_sigma_rad = (deg2rad(sidelobe_beamwidth_deg) / 2) / sqrt(2 * log(2)); 
max_sidelobe_offset_deg = 150; 
min_sidelobe_level_dB = -15; 
max_sidelobe_level_dB = -6; 

combined_pattern = main_lobe_pattern; 


for i = 1:num_sidelobes
    
    sidelobe_level_dB = min_sidelobe_level_dB + (max_sidelobe_level_dB - min_sidelobe_level_dB) * rand();
    sidelobe_level_linear = 10^(sidelobe_level_dB/10);

   
    sidelobe_pitch_offset_deg = (rand() - 0.5) * 2 * max_sidelobe_offset_deg; 
    sidelobe_yaw_offset_deg = (rand() - 0.5) * 2 * max_sidelobe_offset_deg;   

 
    sidelobe_pitch_deg = mainBeamPitch_deg + sidelobe_pitch_offset_deg;
    sidelobe_yaw_deg = mainBeamYaw_deg + sidelobe_yaw_offset_deg;

    
    sidelobe_pitch_deg = max(0, min(sidelobe_pitch_deg, 90));

    
    sidelobe_yaw_deg = mod(sidelobe_yaw_deg, 360);

    
    sidelobe_pitch_rad = deg2rad(sidelobe_pitch_deg);
    sidelobe_yaw_rad = deg2rad(sidelobe_yaw_deg);

  
    X_sl = sin(pi/2-sidelobe_pitch_rad) * cos(sidelobe_yaw_rad);
    Y_sl = sin(pi/2-sidelobe_pitch_rad) * sin(sidelobe_yaw_rad);
    Z_sl = cos(pi/2-sidelobe_pitch_rad);

   
    dot_product_sl = X_grid * X_sl + Y_grid * Y_sl + Z_grid * Z_sl;

    
    dot_product_sl = min(max(dot_product_sl, -1), 1);

    
    angular_separation_rad_sl = acos(dot_product_sl);

   
    sidelobe_pattern = sidelobe_level_linear * exp(-(angular_separation_rad_sl.^2) / (2 * sidelobe_sigma_rad^2));

    
    combined_pattern = combined_pattern + sidelobe_pattern;
end


normalized_pattern = combined_pattern / max(combined_pattern(:));


pattern_dB = 10 * log10(normalized_pattern);


min_dB_display = -30; 
pattern_dB(pattern_dB < min_dB_display) = min_dB_display;


figure;
set(gcf, 'Color', 'w'); 

X_plot = normalized_pattern .* sin(El_rad) .* cos(Az_rad); 
Y_plot = normalized_pattern .* sin(El_rad) .* sin(Az_rad); 
Z_plot = normalized_pattern .* cos(El_rad);

surf(X_plot, Y_plot, Z_plot, pattern_dB, 'EdgeColor', 'none');
colormap('jet'); 
colorbar;
caxis([min_dB_display, 0]); 

axis equal; 
grid on;
hold on;


X_mb_vec = sin(pi/2-mainBeamPitch_rad) * cos(mainBeamYaw_rad);
Y_mb_vec = sin(pi/2-mainBeamPitch_rad) * sin(mainBeamYaw_rad);
Z_mb_vec = cos(pi/2-mainBeamPitch_rad);


plot3([0 X_mb_vec], [0 Y_mb_vec], [0 Z_mb_vec], 'r--', 'LineWidth', 2, 'DisplayName', 'main beam pointing');


xlabel('North (X)'); 
ylabel('East (Y)'); 
zlabel('Zenith (Z)'); 


view(3); 

set(gca, 'YDir', 'reverse');

function patternValue = getAntennaPatternValue(azimuth_deg, elevation_deg, Az, El, normalized_pattern)
   
    azimuth_rad = deg2rad(azimuth_deg);
    elevation_rad = deg2rad(elevation_deg);

   
    X = sin(pi/2-elevation_rad) .* cos(azimuth_rad);
    Y = sin(pi/2-elevation_rad) .* sin(azimuth_rad);
    Z = cos(pi/2-elevation_rad);

   
    distances = (sin(El) .* cos(Az) - X).^2 + (sin(El) .* sin(Az) - Y).^2 + (cos(El) - Z).^2;
    [~, index] = min(distances(:));

    
    patternValue = normalized_pattern(index);
end


azimuth_query = 90;
elevation_query = 0;
pattern_value = getAntennaPatternValue(azimuth_query, elevation_query, Az_rad, El_rad, normalized_pattern);

fprintf('in (%.1f °, %.1f °) : %.4f\n', azimuth_query, elevation_query, pattern_value);
