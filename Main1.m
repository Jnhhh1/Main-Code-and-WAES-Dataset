clear all; clc; tic;
%All code will be made publicly available upon the acceptance of the paper.

data=load('E:\50.mat');

sys_param.integral_time = 10^(-1);    

sys_param.array_type = 'Y_shape';        

sys_param.ant_num = 36;               
        
sys_param.band = 500*10^6;
sys_param.div = 'auto'; 

sys_param.center_freq = 2e9;

sys_param.inverse_name = 'hfft'; 


SRM_param.norm_min_spacing = 1;    

SRM_param.channel_info.T_rec = 100;


  STM_param.idealpoint_simu = 1;      
  STM_param.idealpoint_place = [0;0]; 
  STM_param.idealpoint_power = [300]; 
  
  
  STM_param.extentpoint_simu = 0;                  
  STM_param.extentpoint_model = 'rectangular';     

 
  STM_param.extentpoint_rec_power = [400 300 500];    
  STM_param.extentpoint_rec_place_center = [0 0;-30 -30;30 30];  
  STM_param.extentpoint_rec_place_hs = [3 3;4 4;2 2];         

SRM_param.channel_info.error_amp_type = 'uniform';

SRM_param.channel_info.error_amp_quantity = [1 1];

SRM_param.channel_info.error_Iphase_type = 'uniform';

SRM_param.channel_info.error_Iphase_quantity  = [0 0];

SRM_param.channel_info.error_Qphase_type = 'uniform';

SRM_param.channel_info.error_Qphase_quantity  = [0 0];

SRM_param.ant_pos_info = struct;  

SRM_param.ant_pos_info.ant_pos_error_type = 'uniform';

SRM_param.ant_pos_info.ant_pos_error_quantity = [0 0];

SRM_param.mutual_info = struct;  

SRM_param.mutual_info.mutual_error_type = 'uniform';



SRM_param.mutual_info.mutual_error_quantity = [0 0];


SRM_param.antenna_pattern_info.antenna_type = 'isotropic';             

SRM_param.antenna_pattern_info.antenna_size = 0.07;                 

SRM_param.antenna_pattern_info.pattern_error_type = 'normal';

SRM_param.antenna_pattern_info.pattern_error_quantity = 1;


% save_folder = 'E:\xxx'; 
% resolution_dpi = 200;         
% fig_size_cm = [12, 10];         



scenario_counter = 0;
total_scenarios = numel(data.results); 

for row_idx = 1:size(data.results, 1) % 1 - 40
    for col_idx = 1:size(data.results, 2) % 1 - 6
        scenario_counter = scenario_counter + 1;
        % fprintf('\n--- ）---\n', scenario_counter, total_scenarios);
        % fprintf(' )\n', row_idx, col_idx);

       
        current_data_matrix = data.results{row_idx, col_idx};

       
        if ~isequal(size(current_data_matrix), [3, 50])
           
            continue; 
        end

       
        STM_param.idealpoint_power = current_data_matrix(1, :);
        STM_param.idealpoint_place = [current_data_matrix(2, :); current_data_matrix(3, :)]; % 使用分号连接第二行和第三行
                   

       
        [SRM_param.norm_ant_pos,sys_param.ant_num] = SRMA(sys_param.array_type,sys_param.ant_num);
        
       
        STM_param.array_type = sys_param.array_type; 
       
        [Fov,delta] = STMR(SRM_param.norm_min_spacing,SRM_param.norm_ant_pos);
        
       
        T_dist = STMS(Fov,delta,STM_param,sys_param.div);
        
       
        self_correlation_matrix = SRMS(T_dist,sys_param,SRM_param,1);  %All code will be made publicly available upon the acceptance of the paper.
        
        
        IAM_param.inverse_name = IA(sys_param.inverse_name,sys_param.array_type); 
      
        
        [inv_T1,extent_UV1,Fov1] = IAMS(self_correlation_matrix,SRM_param,IAM_param);
        
        
        inv_T = TAbsC(inv_T1,IAM_param.inverse_name);
  
       
        DrawInvPic1(inv_T,SRM_param.norm_min_spacing,IAM_param.inverse_name,extent_UV1,Fov1,save_folder, resolution_dpi, fig_size_cm,scenario_counter);
        if exist('error_module.mat','file')
        delete error_module.mat
        end
    end
end

% fprintf('\n all finish\n', total_scenarios);
toc;






