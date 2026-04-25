function [T,extent_UV,Fov] = IAMS(self_correlation_matrix,SRM_param,IAM_param)



norm_ant_pos = SRM_param.norm_ant_pos;
inverse_name = IAM_param.inverse_name;
min_spacing = SRM_param.norm_min_spacing;


switch inverse_name
    
    case 'hfft'
        
        max_arm = length(norm_ant_pos(1,:))/3;
       
        [visibility,extent_UV,Fov] = R2VY(self_correlation_matrix,norm_ant_pos,min_spacing,max_arm);
        
        
        T = HFFT(visibility,norm_ant_pos,Fov,extent_UV);
   
end

function [visibility,extent_UV,Fov] = R2VY(self_correlation_matrix,ant_pos,min_spacing,max_arm)



[extent_UV Fov] = GenerateUVCellofYShape(min_spacing,max_arm);

% [extent_UV,Hextend_UV,Fov,Hextend_Fov]= UVHeCellofYShape(min_spacing,max_arm);

UVplane = zeros(size(extent_UV));


counter = UVplane; 

visibility = UVplane;


small_num = 10^(-2);

for p = 1:size(ant_pos,2)
    for q = 1:size(ant_pos,2)
        
        delta_x = min_spacing*(ant_pos(1,p)-ant_pos(1,q));
        
        delta_y = min_spacing*(ant_pos(2,p)-ant_pos(2,q));
       
        
        position = find( real(extent_UV)>(delta_x-small_num) & real(extent_UV)<(delta_x+small_num) & imag(extent_UV)>(delta_y-small_num) & imag(extent_UV)<(delta_y+small_num) );
        
        counter(position) = counter(position)+1;
       
        UVplane(position) = UVplane(position)+self_correlation_matrix(q,p);
        
        
    end
end


for k = 1:length(counter)
    
    if 0 ~= counter(k)
        
        visibility(k) = UVplane(k)/counter(k);
    end
end


function T = HFFT(visibility,pos,Fov,extent_UV)


% disp(size(Fov))
% disp(size(visibility))
% disp(size(extent_UV))
for k = 1:length(Fov)
    l = real(Fov(k));
    m = imag(Fov(k));
    T(k) = 0;
    for pos = 1:length(extent_UV)
        u = real(extent_UV(pos));
        v = imag(extent_UV(pos));
        a  = exp(2*pi*j*(u*l+v*m));
        T(k) = T(k)+visibility(pos)*a;
    end
    T(k) = T(k)/length(Fov);
T = real(T);
end

function [extent_UV,Fov]= GenerateUVCellofYShape(min_spacing,max_arm)

scale_factor=3;

dx = min_spacing*sind(60) / scale_factor;  

dy = min_spacing*sind(30) / scale_factor;  
flag = 0;

pmmatrix = [-1 1 1];
q_num = max_arm * scale_factor; 

for p = 1:3*max_arm*scale_factor+1  
    q_num = q_num + pmmatrix(mod(p+1,3)+1);
    for q = 1:q_num
        flag = flag + 1;
        xaxis = -1-q_num+q*2;
        xaxis = xaxis*dx;
        yaxis = 3*max_arm*scale_factor+1-p; 
        yaxis = yaxis*dy;
        extent_UV(flag) = xaxis+1i*yaxis;
    end
end


pmmatrix = [1 -1 -1];
for p = 1:3*max_arm*scale_factor  
    q_num = q_num + pmmatrix(mod(p,3)+1);
    for q = 1:q_num
        flag = flag + 1;
        xaxis = -1-q_num+q*2;
        xaxis = xaxis*dx;
        yaxis = -p;
        yaxis = yaxis*dy;
        extent_UV(flag) = xaxis+1i*yaxis;
    end
end

Fov = 2*extent_UV*exp(1i*pi/6)/sqrt(3)/(3*max_arm+1)/min_spacing/min_spacing;


% figure()
% plot(real(extent_UV),imag(extent_UV),'o');
% figure()
% plot(real(Fov),imag(Fov),'o');
% axis square