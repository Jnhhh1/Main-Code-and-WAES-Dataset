function self_correlation_matrix = SRMS(T_dist,sys_param,SRM_param,save_error)

if nargin<=3
    save_error = 0;
end


norm_min_spacing = SRM_param.norm_min_spacing;           
norm_ant_pos = SRM_param.norm_ant_pos;                   
antenna_pattern_info = SRM_param.antenna_pattern_info;   
T_rec = SRM_param.channel_info.T_rec;                    
channel_info = SRM_param.channel_info;                  

sampling_num = floor(sys_param.band*sys_param.integral_time); 

if(size(norm_ant_pos,1)==1)      
    array_type = 1;
elseif(size(norm_ant_pos,1)==2)   
    array_type = 0;
end

ant_pos_error_type = SRM_param.ant_pos_info.ant_pos_error_type;         
ant_pos_error_quantity = SRM_param.ant_pos_info.ant_pos_error_quantity;  
antenna_num = sys_param.ant_num ;                                        

norm_ant_pos = SRMAntPosErrorGenerate(norm_min_spacing,norm_ant_pos,ant_pos_error_quantity,ant_pos_error_type);


c = 3*10^8;                                                
antenna_pattern_info.wavelength = c/sys_param.center_freq; 

switch size(T_dist,1)
    case 2      
        coef_matrix = SRMPatternGenerate(antenna_pattern_info,T_dist(2,:),array_type);
    case 3     
        coef_matrix = SRMPatternGenerate(antenna_pattern_info,T_dist([2:3],:),array_type);
        
end


pattern_error_quantity = SRM_param.antenna_pattern_info.pattern_error_quantity;   
pattern_error_type = SRM_param.antenna_pattern_info.pattern_error_type;           

real_coef_matrix = SRMPatternErrorGenerate(coef_matrix,pattern_error_quantity,antenna_num,pattern_error_type);

%disp(coef_matrix);£¨1£¬24£©
%disp(real_coef_matrix);£¨1£¬24£¬41£©

mutual_error_quantity = SRM_param.mutual_info.mutual_error_quantity;   
mutual_error_type = SRM_param.mutual_info.mutual_error_type;           

mutual = SRMMutualErrorGenerate(norm_min_spacing,norm_ant_pos,mutual_error_quantity,mutual_error_type);


if exist('error_module.mat','file')
load error_module.mat
else 
[error_amp,error_Iphase,error_Qphase] = SRMChannelErrorGenerate(antenna_num,channel_info);

end

if save_error == 1;
   
    save error_module error_amp error_Iphase error_Qphase
end

if save_error ==2;
    delete error_module.mat
end

 
   
self_correlation_matrix = SRMSignalOutput(T_dist,norm_ant_pos,norm_min_spacing,real_coef_matrix,mutual,T_rec,error_amp,error_Iphase,error_Qphase);


self_correlation_matrix = SRMCorrelationSim(self_correlation_matrix,sampling_num,error_Qphase);



function real_ant_pos = SRMAntPosErrorGenerate(norm_min_spacing,norm_ant_pos,ant_pos_error_quantity,ant_pos_error_type);


if(isvector(norm_ant_pos) == 1)
    flag = 1; 
else
    flag = 0; 
end


if(flag ==1)
    
    switch lower(ant_pos_error_type)
        case 'normal'    
            real_ant_pos = norm_ant_pos + norm_min_spacing*ant_pos_error_quantity*randn(size(norm_ant_pos));
        case 'constant' 
            real_ant_pos = norm_ant_pos + ant_pos_error_quantity;
        case 'uniform'   
            real_ant_pos = norm_ant_pos + ((ant_pos_error_quantity(2)-ant_pos_error_quantity(1))*rand(size(norm_ant_pos))+ant_pos_error_quantity(1));
        otherwise        
            real_ant_pos = norm_ant_pos + ant_pos_error_type;    
    end
    real_ant_pos = sort(real_ant_pos); 
    real_ant_pos = real_ant_pos - real_ant_pos(1);
end

if(flag ==0)
    
    switch lower(ant_pos_error_type)
        case 'normal'    
            real_ant_pos = norm_ant_pos + norm_min_spacing*ant_pos_error_quantity*randn(size(norm_ant_pos));
        case 'constant'  
            real_ant_pos = norm_ant_pos + ant_pos_error_quantity;
        case 'uniform'   
            real_ant_pos = norm_ant_pos + ((ant_pos_error_quantity(2)-ant_pos_error_quantity(1))*rand(size(norm_ant_pos))+ant_pos_error_quantity(1));
        otherwise        
            real_ant_pos = norm_ant_pos + ant_pos_error_type;
    end
    real_ant_pos(1,:) = real_ant_pos(1,:) - real_ant_pos(1,1);
    real_ant_pos(2,:) = real_ant_pos(2,:) - real_ant_pos(2,1);
end


function coef_matrix = SRMPatternGenerate(antenna_pattern_info,angle_info,array_type);


antenna_type = antenna_pattern_info.antenna_type;
antenna_size = antenna_pattern_info.antenna_size;
wavelength = antenna_pattern_info.wavelength;    


if(ischar(antenna_type)==0) 
    coef_matrix = antenna_type; 
    array_type = 2;              
end



if(array_type==1) 
  
    switch lower(antenna_type)
        case 'rectangle'
            lx = pi*antenna_size(1)/wavelength;
            for k = 1:length(angle_info)
                coef_matrix(k) = abs(cosd(angle_info(k))*sinc(lx*sind(angle_info(k))));
            end
            

        case'isotropic'
            coef_matrix = ones(size(angle_info));
           

        case'circle'
            Ba = 2*pi*antenna_size/wavelength;
            for k = 1:length(angle_info)
                if (abs(sind(angle_info(k)))<=0.0001)
                    coef_matrix(k) = 1;
                else
                    coef_matrix(k) = abs(2*real(besselj(1,Ba*sind(angle_info(k))))/(Ba*sind(angle_info(k))));
                end
            end
            
    end
end


if(array_type==0)  

    switch lower(antenna_type)   
        case 'rectangle'
            lx = pi*antenna_size(1)/wavelength; 
            ly = pi*antenna_size(2)/wavelength;  
            source_num = length(angle_info(1,:));  
            
            for k = 1:source_num
                u = sind(angle_info(1,k))*cosd(angle_info(2,k)); 
                v = sind(angle_info(1,k))*sind(angle_info(2,k));  
                coef_matrix(k) = abs(sinc(lx*u)*sinc(ly*v));  
           
            end
            

        case'isotropic'
            coef_matrix = ones(1,length(angle_info(1,:)));  
            

        case'circle'
            Ba = 2*pi*antenna_size/wavelength;   
            source_num = length(angle_info(1,:)); 
            for k = 1:source_num
                if(sind(angle_info(1,k))<=0.0001)  
                    coef_matrix(k) = 1;
                else
                    
                    coef_matrix(k) = abs(2*real(besselj(1,Ba*sind(angle_info(1,k))))/(Ba*sind(angle_info(1,k))));
                end
            end
         
    end
end


function real_coef_matrix = SRMPatternErrorGenerate(coef_matrix,pattern_error_quantity,antenna_num,pattern_error_type);

for antenna_seria = 1:antenna_num
    switch lower(pattern_error_type)
        case 'normal'
            error_coef_matrix = coef_matrix + pattern_error_quantity*randn(size(coef_matrix));
        case 'constant'
            error_coef_matrix = coef_matrix + pattern_error_quantity;
        case 'uniform'
            error_coef_matrix = coef_matrix + (pattern_error_quantity(2)-pattern_error_quantity(1))*rand(size(coef_matrix))+pattern_error_quantity(1);
    end
   
    for p = 1:size(error_coef_matrix,1)
        for q = 1:size(error_coef_matrix,2)
            if(error_coef_matrix(p,q)>1)
                error_coef_matrix(p,q) = 1;
            elseif(error_coef_matrix(p,q)<0)
                error_coef_matrix(p,q) = 0;
            end
        end
    end
    
    real_coef_matrix(antenna_seria) = {error_coef_matrix};
    % matrix_value = real_coef_matrix{antenna_seria};
    % disp(matrix_value);
end


function mutual_matrix = SRMMutualErrorGenerate(min_spacing,ant_pos,mutual_error_quantity,mutual_error_type);

if(ischar(mutual_error_type)==0)       
    mutual_matrix = mutual_error_type;
else
    
    ata_num = length(ant_pos(1,:));
    
   
    if(isvector(ant_pos) == 1)
        ant_pos(2,:) = zeros(1,ata_num);
    end

    
    distance_matrix = zeros(ata_num,ata_num);
    for p = 1:ata_num
        for q = 1:ata_num
            if(q>p)
                distance_matrix(p,q) = abs((ant_pos(1,q)-ant_pos(1,p))+j*(ant_pos(2,q)-ant_pos(2,p)));
            end
        end
    end
    
    mutual_matrix = zeros(ata_num,ata_num);
    for p = 1:ata_num
        for q = 1:ata_num
            if(q>p)
                switch lower(mutual_error_type)
                    case 'normal'
                        
                        mutual_matrix(p,q) = randn(1,1)*mutual_error_quantity/(min_spacing*distance_matrix(p,q));
                        mutual_matrix(p,q) = abs(mutual_matrix(p,q));
                    case 'constant'
                        mutual_matrix(p,q) = mutual_error_quantity/(min_spacing*distance_matrix(p,q));
                    case 'uniform'
                        
                        mutual_matrix(p,q) = (rand(1,1)*(mutual_error_quantity(2)-mutual_error_quantity(1))+mutual_error_quantity(1))/(min_spacing*distance_matrix(p,q));
                end
            end
        end
    end
    
    mutual_matrix = mutual_matrix+mutual_matrix.';            
    mutual_matrix_diag = ones(1,ata_num)-sum(mutual_matrix);  
    mutual_matrix = mutual_matrix+diag(mutual_matrix_diag);   
end


function [error_amp,error_Iphase,error_Qphase] = SRMChannelErrorGenerate(antenna_num,channel_info);


switch lower(channel_info.error_amp_type)
    case 'normal'
       error_amp  = ones(1,antenna_num) + channel_info.error_amp_quantity*randn(1,antenna_num);
    case 'constant'
       error_amp  = ones(1,antenna_num) + channel_info.error_amp_quantity;
    case 'uniform'
       error_amp  = (channel_info.error_amp_quantity(2)-channel_info.error_amp_quantity(1))*rand(1,antenna_num) + channel_info.error_amp_quantity(1);
end

switch lower(channel_info.error_Iphase_type)
    case 'normal'
       error_Iphase  = zeros(1,antenna_num) + channel_info.error_Iphase_quantity*randn(1,antenna_num);
    case 'constant'
       error_Iphase  = zeros(1,antenna_num) + channel_info.error_Iphase_quantity;
    case 'uniform'
       error_Iphase  = (channel_info.error_Iphase_quantity(2)-channel_info.error_Iphase_quantity(1))*rand(1,antenna_num) + channel_info.error_Iphase_quantity(1);
end

switch lower(channel_info.error_Qphase_type)
    case 'normal'
       error_Qphase  = zeros(antenna_num,antenna_num) + channel_info.error_Qphase_quantity*randn(antenna_num,antenna_num);
    case 'constant'
       error_Qphase  = zeros(antenna_num,antenna_num) + channel_info.error_Qphase_quantity;
    case 'uniform'
       error_Qphase  = (channel_info.error_Qphase_quantity(2)-channel_info.error_Qphase_quantity(1))*rand(antenna_num,antenna_num) + channel_info.error_Qphase_quantity(1);
end


error_Qphase = triu(error_Qphase,1)-triu(error_Qphase,1)'; 


function self_correlation_matrix = SRMSignalOutput(T_dist,ant_pos,min_spacing,pattern_coef,mutual,T_rec,error_amp,error_Iphase,error_Qphase);


antenna_num = length(ant_pos(1,:));

ant_pos =  min_spacing*ant_pos; 

error_amp_phase = exp(j*error_Iphase).*error_amp;


if(isvector(ant_pos) == 1)
    flag = 1; 
else
    flag = 0; 
end


if(flag==1)
    
    scene_power = T_dist(1,:); 
    scene_theta = T_dist(2,:); 
    
    for k = 1:antenna_num 
        coef_matrix(k,:) = cell2mat(pattern_coef(k));
    end
    
 
    for k=1:length(scene_power)
        A(:,k)=sqrt(coef_matrix(:,k)).*[exp(2*pi*j*ant_pos*sind(scene_theta(k)))].';       
    end
    
   
    A = diag(error_amp_phase)*A;
    
    
    A = mutual*A;   
   
    self_correlation_matrix = A*diag(scene_power)*A';
   
    self_correlation_matrix = self_correlation_matrix + diag(error_amp)*diag(error_amp)*T_rec;   
end

if(flag ==0)    
    scene_power = T_dist(1,:); 
    scene_theta = T_dist(2,:); 
    scene_phy = T_dist(3,:);   
    
    for k = 1:antenna_num
        coef_matrix(k,:) = cell2mat(pattern_coef(k));
    end
    
   
    for k=1:length(scene_power)
        A(:,k)=sqrt(coef_matrix(:,k)).*[exp(2*pi*j*sind(scene_theta(k))*(ant_pos(1,:)*cosd(scene_phy(k))+ant_pos(2,:)*sind(scene_phy(k))))].';
    end
    
    
    A = diag(error_amp_phase)*A;
   
   
    A = mutual*A;
   
    N=10;
    scenepixel_num=size(scene_power,2);
    channels_num=size(A,1);
    self_correlation_matrix=zeros(channels_num,channels_num);
    scenepixel_div = round(scenepixel_num/N); 
    
    for n=1:N-1
    S1=diag(scene_power(:,(n-1)*scenepixel_div+1:n*scenepixel_div));
    A1=A(:,(n-1)*scenepixel_div+1:n*scenepixel_div);
    self_correlation_matrix=self_correlation_matrix+A1*S1*A1';
   
    end
    
    
    S1=diag(scene_power(:,(N-1)*scenepixel_div+1:scenepixel_num));
    A1=A(:,(N-1)*scenepixel_div+1:scenepixel_num);
    self_correlation_matrix=self_correlation_matrix+A1*S1*A1';
    
   
    self_correlation_matrix = self_correlation_matrix + diag(error_amp)*diag(error_amp)*T_rec;
    
end

function re_self_correlation_matrix = SRMCorrelationSim(self_correlation_matrix,sampling_num,error_Qphase)


antenna_num = length(self_correlation_matrix(1,:));

for p = 1:antenna_num
    for q = 1:antenna_num
        correlation_matrix_var(p,q) = self_correlation_matrix(p,p)*self_correlation_matrix(q,q)/sampling_num;
    end
end

error_matrix = zeros(antenna_num,antenna_num);

for p = 2:antenna_num
    for q = 1:p-1
        error_matrix(p,q) = (randn(1,1)+j*randn(1,1))/sqrt(2);
    end
end

error_matrix = error_matrix+error_matrix';

for k = 1:antenna_num  
    error_matrix(k,k) = randn(1,1);
end


error_matrix = error_matrix.*sqrt(correlation_matrix_var);
self_correlation_matrix = self_correlation_matrix + error_matrix;


error_Qphase_matrix = error_Qphase;

angle_matrix = angle(self_correlation_matrix);

amp_matrix = abs(self_correlation_matrix);

re_self_correlation_matrix = amp_matrix.*cos(angle_matrix) + j*amp_matrix.*sin(angle_matrix-error_Qphase_matrix);

