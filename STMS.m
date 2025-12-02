function T_dist = STMS(Fov,delta,STM_param,div)




if STM_param.idealpoint_simu==1
   
    place = STM_param.idealpoint_place;
    if size(place,1)==1 
        power = STM_param.idealpoint_power*delta/(Fov(2)-Fov(1));
        T_dist_point = [power;place];
    end
    if size(place,1)==2 
       
        disp(Fov(1,2)-Fov(1,1))
        disp(Fov(2,2)-Fov(2,1))
        power = STM_param.idealpoint_power*delta(1)*delta(2)/(Fov(1,2)-Fov(1,1))/(Fov(2,2)-Fov(2,1));
        %power = STM_param.idealpoint_power;
        T_dist_point = [power;place];
       
    end
else
    
    T_dist_point = [];
end


if STM_param.extentpoint_simu == 1
    
    if(size(Fov,1)==2)   
       
        T_dist_extent = [;;];
        
        division = SpaceDivisionSelect(div,delta);
        
       
        scope_m = linspace(-1,1,division(2)+1);  
        scope_l = linspace(-1,1,division(1)+1);
        
        for k = 1:size(STM_param.extentpoint_model,1)
            switch STM_param.extentpoint_model(k,:)
                case 'rectangular'
                    for rec_k = 1:length(STM_param.extentpoint_rec_power)
                        power = STM_param.extentpoint_rec_power(rec_k)*(scope_l(2)-scope_l(1))*(scope_m(2)-scope_m(1))/(Fov(1,2)-Fov(1,1))/(Fov(2,2)-Fov(2,1));
                        center = STM_param.extentpoint_rec_place_center(rec_k,:)
                        
                        hs = STM_param.extentpoint_rec_place_hs(rec_k,:);
                      
                        T_dist_source = SourceCutUp2D(scope_l,scope_m,power,center,hs);
                        T_dist_extent = [T_dist_extent T_dist_source];
                    end
            end
        end
        
        
    end
else
    
    T_dist_extent = [];

end
T_dist = [T_dist_point T_dist_extent];



function division = SpaceDivisionSelect(div,delta)
    


if (ischar(div)==1)  
    divcoef = str2num(div); 
    
    if (isempty(divcoef)==1) 
        if (length(delta)==1) 
            division = 2/delta; 
        else
            division = [2/delta(1) 2/delta(2)]; 
        end

    elseif (length(divcoef)==1) 
        division = 2/delta*divcoef; 
    else                   
        division = [2/delta(1)*divcoef(1) 2/delta(2)*divcoef(2)]; 
    end

   
else
    division = div; 
end


function T_dist_source = SourceCutUp2D(scope_l,scope_m,power,center,hs)


source_center_lc = sind(center(1))*cosd(center(2));   
source_center_mc = sind(center(1))*sind(center(2));  
source_center = [source_center_lc source_center_mc];

source_deltalm = [sind(hs(1)) sind(hs(2))];

scope_deltalm = [(scope_l(2)-scope_l(1)) (scope_m(2)-scope_m(1))]/2;   

delta_scope_source = abs(source_deltalm-scope_deltalm);


sum_scope_source = source_deltalm+scope_deltalm;


T_dist_source = [];

for laxis = 1:length(scope_l)
    for maxis = 1:length(scope_m)
        
        lspace = source_center_lc - scope_l(laxis); 
        mspace = source_center_mc - scope_m(maxis); 
       
        if (abs(lspace)<sum_scope_source(1)) && (abs(mspace)<sum_scope_source(2)) && ((scope_l(laxis)^2+scope_m(maxis)^2)<=1)
           
            if (lspace<delta_scope_source(1))
                l_coef = 1;
            else
                l_coef = (lspace-delta_scope_source(1))/(sum_scope_source(1)-delta_scope_source(1));
            end
           
            if (mspace<delta_scope_source(2))
                m_coef = 1;
            else
                m_coef = (mspace-delta_scope_source(2))/(sum_scope_source(2)-delta_scope_source(2));
            end
            
            area = l_coef*m_coef;
           
            theta = asind(sqrt(scope_l(laxis)^2+scope_m(maxis)^2));
           
            phy = angle(scope_l(laxis)+j*scope_m(maxis))*180/pi;
            
            T_dist_k = real([power*area;theta;phy]);
            T_dist_source  = [T_dist_source  T_dist_k];            
        end
    end
end

        
            
            

    
    

