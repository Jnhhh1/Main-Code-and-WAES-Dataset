function Draw1(T,min_spacing,inv_name,extent_UV,Fov,save_folder, resolution_dpi, fig_size_cm)

switch inv_name
      
    case 'hfft'
        
        ant_num = sqrt(length(T)-3/4)-1/2;
        max_arm = ant_num/3;
       
        %[extent_UV Fov] = GenerateUVCellofYShape(min_spacing,max_arm);
        r = abs(Fov(1)-Fov(2))/3;
        r1 = abs(Fov(1)-Fov(38))/2;
        r2 = abs(Fov(1)-Fov(2))/2;
        
        angle = pi/6:pi/3:11*pi/6;
        
       
        x = r*cos(angle);
        y = r*sin(angle);

        X = real(Fov);
        Y = imag(Fov);
       
        square_size1 = r1; 
        square_size2 = r2; 
        
        X_all = [];
        Y_all = [];
        for k = 1:length(T)
            if (X(k)^2+Y(k)^2<=1)
                %xaxis = X(k)+x1;
                %yaxis = Y(k)+y2;
                
                xaxis = [X(k) - square_size1, X(k) + square_size1, X(k) + square_size1, X(k) - square_size1];
                yaxis = [Y(k) - square_size2, Y(k) - square_size2, Y(k) + square_size2, Y(k) + square_size2];
                hold on
                %fill(xaxis,yaxis,T(k),'linestyle', 'none');
               
                X_all(end+1,:) = xaxis;
                Y_all(end+1,:) = yaxis;
            end
        end

        
        Y_all_flip = flipud(Y_all);

       
        X_rotated = -Y_all_flip;
        Y_rotated = X_all;
        
        
        fig=figure;
        hold on;
        colormap jet;
        
        for i=1:size(X_rotated,1)
            fill(X_rotated(i,:),Y_rotated(i,:), T(i),'linestyle','none');
        end
        axis off; 

       
        if nargin >= 8 && ~isempty(save_folder) && ~isempty(resolution_dpi) && ~isempty(fig_size_cm)
            
            if ~exist(save_folder, 'dir')
                mkdir(save_folder);
            end

           
            file_name = '1.jpg'; 
            full_file_path = fullfile(save_folder, file_name);

            
            set(fig, 'Units', 'centimeters', ...         
                     'PaperUnits', 'centimeters', ...   
                     'PaperSize', fig_size_cm, ...       
                     'PaperPosition', [0 0 fig_size_cm(1) fig_size_cm(2)]); 

           
            %print(fig, full_file_path, '-dpng', ['-r' num2str(resolution_dpi)]);
            exportgraphics(fig, full_file_path, 'Resolution', resolution_dpi); 
            fprintf('图片已保存至: %s\n', full_file_path);
        end
        
        
        end

        
        

        
        