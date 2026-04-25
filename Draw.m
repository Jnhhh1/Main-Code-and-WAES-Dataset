function Draw(T,min_spacing,inv_name,extent_UV,Fov)

switch inv_name
      
    case 'hfft'
        
        ant_num = sqrt(length(T)-3/4)-1/2;
        max_arm = ant_num/3;
       
        %[extent_UV Fov] = GenerateUVCellofYShape(min_spacing,max_arm);
        r = abs(Fov(1)-Fov(2))/3;
        %r1 = abs(Fov(1)-Fov(26))/4;
        r1 = abs(Fov(1)-Fov(2))/2;
        % r2 = abs(Fov(1)-Fov(2))/2;
        %r1 = abs(Fov(1)-Fov(38))/2;
        r2 = abs(Fov(1)-Fov(2))/2;
        % size(extent_UV)
        % size(Fov)
        angle = pi/6:pi/3:11*pi/6;
        % angle = pi/4:pi/2:7*pi/4;
        %angle = angle + pi/6;  
       
        x = r*cos(angle);
        y = r*sin(angle);

        X = real(Fov);
        disp(size(Fov))
        Y = imag(Fov);
        
        square_size1 = r1; 
        square_size2 = r2; 
        % figure()
        % 
        % colormap jet;
        % 
        % for k = 1:length(T)
        %     if (X(k)^2+Y(k)^2<=1)
        %     xaxis = X(k)+x;
        %     yaxis = Y(k)+y;
        %     hold on
        %     fill(xaxis,yaxis,T(k),'linestyle', 'none');
        %     end
        % end
        
        % xlabel('\xi');
        % ylabel('\eta');
        % axis square     

         
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
        


        figure('Position', [500 300 800 600]);
        %figure();
        hold on;
        colormap jet;
        
        for i=1:size(X_rotated,1)
            fill(X_rotated(i,:),Y_rotated(i,:), T(i),'linestyle','none');
        end

        
        xlabel('-\eta','FontSize', 50);
        ylabel('\xi','FontSize', 50);
        % xlabel('\xi','FontSize', 100);
        % ylabel('\eta','FontSize', 100);
       
        set(gca, 'YDir', 'normal'); 
        ax = gca; 
        ax.YAxisLocation = 'right'; 
        axis equal;      
        %set(gca, 'FontSize', 18);
        
        
        
        % ax.XLabel.FontSize = 50;  
        % ax.YLabel.FontSize = 50;  
        
        
        ax.XAxis.FontSize = 18;   
        ax.YAxis.FontSize = 18;  


        
        c = colorbar('location', 'west'); 

        
        c.Label.String = '[K]'; 
        c.Label.FontSize = 20; 
        
        c.Label.Rotation = 0; 
         
        pos = c.Label.Position;
        
        
        pos(1) = pos(1)-2.2;  
        %pos(2) = pos(2)+0.092;  
        pos(2) = pos(2)+max(T)/2;  
        
        c.Label.Position = pos;

       
        c.YAxisLocation = 'left'; 
        
        c.FontSize = 18; 
        
        ax.XLabel.FontSize = 25;
        ax.YLabel.FontSize = 25;
        
        set(ax.XLabel, 'FontSize', 25);
        set(ax.YLabel, 'FontSize', 25);

        
        xlabel_pos = ax.XLabel.Position;
        xlabel_pos(2) = xlabel_pos(2) + 0.04;  
        ax.XLabel.Position = xlabel_pos;
        
        
        ylabel_pos = ax.YLabel.Position;
        ylabel_pos(1) = ylabel_pos(1) - 0.06;   
        ax.YLabel.Position = ylabel_pos;
     
        end

        
        

        
        