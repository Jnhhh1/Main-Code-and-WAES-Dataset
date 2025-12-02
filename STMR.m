function [Fov,delta] = STMR(min_spacing,ant_pos)


if (size(ant_pos,1)==1)
  
    lastant = ant_pos(length(ant_pos));  
    firstant = ant_pos(1);               
    Tnum = 2*(lastant-firstant)+1;       
    
    Fov = [-1 1]/2/min_spacing;          

    delta = (Fov(2)-Fov(1))/Tnum;        
    
else
  
     if trace([mod(ant_pos,1)*mod(ant_pos,1)'])<=0.0001
       
        lastantx = max(ant_pos(1,:));                                     
        lastanty = max(ant_pos(2,:));                                    
        firstantx = min(ant_pos(1,:));                                   
        firstanty = min(ant_pos(2,:));                                   
        Tnum = [2*(lastantx-firstantx)+1 2*(lastanty-firstanty)+1];       

        Fov = [[-1 1]/2/min_spacing;[-1 1]/2/min_spacing];                
        delta = [(Fov(1,2)-Fov(1,1))/Tnum(1);(Fov(2,2)-Fov(2,1))/Tnum(2)];
    else
       
        min_spacing = [sqrt(3)/2 1/2]*min_spacing;
        lastantx = max(ant_pos(1,:));                                     
        lastanty = max(ant_pos(2,:));                                    
        firstantx = min(ant_pos(1,:));                                    
        firstanty = min(ant_pos(2,:));                                    
        Tnum = [2*(lastantx-firstantx)+1 2*(lastanty-firstanty)+1]./[sqrt(3)/2 1/2];       
        Tnum = floor(Tnum);
     
        Fov = [[-1 1]/2/min_spacing(1);[-1 1]/2/min_spacing(2)]                
        
        delta = [(Fov(1,2)-Fov(1,1))/Tnum(1);(Fov(2,2)-Fov(2,1))/Tnum(2)] 
    end
    
end