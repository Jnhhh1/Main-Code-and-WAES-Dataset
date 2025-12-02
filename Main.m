clear all; clc; tic;
% profile on
%All code will be made publicly available upon the acceptance of the paper.
       
sys_param.integral_time = 10^(-1);    
%sys_param.integral_time = 10;    

sys_param.array_type = 'Y_shape';        

sys_param.ant_num = 36;               
                
sys_param.band = 500*10^6;

sys_param.div = 'auto'; 
%sys_param.div = ['3 3']; 
 
sys_param.center_freq = 2e9;

sys_param.inverse_name = 'hfft'; 


SRM_param.norm_min_spacing = 1;    %*

SRM_param.channel_info.T_rec = 100;


  STM_param.idealpoint_simu = 1;      
  %STM_param.idealpoint_place = [0 15; 0 15]; %[0 30;0 90]; 
  %STM_param.idealpoint_power = [300 300];
  
 
  %STM_param.idealpoint_place = [5.48535825358897	4.18206449934506	6.58507687882010	3.21719428591422	3.01229934157911	4.53580747799228	5.58986854892326	3.11367938030541	4.80639551230048	3.92369244024953	2.50903060484144	3.67107932498791	4.90022222651261	4.06291736575101	3.18236517963381	3.04304459490790	4.52860849479409	6.53562574198328	4.11340248352391	4.20758988492115;317.428513909687	285.655595871634	247.694760656557	302.796804517831	5.73343290351570	334.604980008670	266.745681127911	279.446973200776	275.481234997502	257.107005314078	309.409418406675	315.467991945061	263.484709387288	327.468875047834	334.900237621492	343.001043485434	296.587219063136	1.97637977079971	255.533796401953	23.4656922196148]; 
  %STM_param.idealpoint_power = [6499.30167581751	6527.72481182342	6469.46569119926	6543.84971559989	6546.72808039604	6520.74672612172	6496.71555249300	6545.33462654909	6515.06582494715	6532.45381561858	6553.02071647961	6536.77976029207	6513.01235406236	6529.92968441088	6544.34709727051	6546.30776623534	6520.90949076272	6470.87871311341	6529.01079912412	6527.22471545626]; 
  
  STM_param.idealpoint_place = [22.6104615218199	17.7295256663881	21.5740304383377	15.3502859248219	32.0129226572452	16.4448987293870	10.6920480272549	21.2372785627307	27.9997697986097	19.6379834207357	24.7609522019656	28.3789143631738	24.0614220113563	23.5620540469759	14.3634731710386	14.7021618795084	26.3425800211526	15.6368999897559	14.4692297093631	12.2637753216647;262.231567730307	261.868699888786	239.966685783476	199.994701144752	232.911142941058	235.077318555470	256.058488852161	263.990296812174	239.790431593887	229.283189354945	240.036033063529	259.717974532810	227.299127872994	277.100252254484	225.886339924050	242.024137252523	235.183349015253	208.842354889123	282.081643597627	248.150701377713]; 
  STM_param.idealpoint_power = [5369.71548137510	5773.03666682659	5461.93385430731	5938.64035322294	4392.25014691524	5865.11483739385	6199.74563528082	5491.31917385953	4837.40981610920	5624.87985919797	5167.24926587812	4797.18958640937	5234.46226457232	5281.94493814614	6001.23196332716	5980.27874802682	5009.69813039419	5919.81635724139	5994.82646700531	6121.46901342096]; 

 
  STM_param.extentpoint_simu = 0;                 
  STM_param.extentpoint_model = 'rectangular';      


  STM_param.extentpoint_rec_power = [400 400 400];    
  STM_param.extentpoint_rec_place_center = [0 0;-30 -30;30 30]; 
  STM_param.extentpoint_rec_place_hs = [3 3;4 4;2 2];       



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

SRM_param.antenna_pattern_info.pattern_error_type = 'uniform';

SRM_param.antenna_pattern_info.pattern_error_quantity = [0 0];


  CAS_param.idealpoint_simu = 1;      
  CAS_param.idealpoint_place = [0;0];  
  CAS_param.nomipoint_place = [0;0];    
  CAS_param.idealpoint_power = [1000]; 


  CAS_param1.idealpoint_simu = 1;      
  CAS_param1.idealpoint_place = [0 30;0 0];   
  CAS_param1.nomipoint_place = [0 30;0 0];    
  CAS_param1.idealpoint_power = [1000 1000]; 
                  

[SRM_param.norm_ant_pos,sys_param.ant_num] = SRMA(sys_param.array_type,sys_param.ant_num);


STM_param.array_type = sys_param.array_type; 

[Fov,delta] = STMR(SRM_param.norm_min_spacing,SRM_param.norm_ant_pos);


T_dist = STMS(Fov,delta,STM_param,sys_param.div);


self_correlation_matrix = SRMS(T_dist,sys_param,SRM_param,1);   %All code will be made publicly available upon the acceptance of the paper.


IAM_param.inverse_name = IA(sys_param.inverse_name,sys_param.array_type); 


[inv_T1,extent_UV1,Fov1] = IAMS(self_correlation_matrix,SRM_param,IAM_param);


inv_T = TAbsC(inv_T1,IAM_param.inverse_name);


% filepath = 'E:\wucha\1.mat';

% save(filepath, 'inv_T');



save_folder = 'G:SJJ'; 
resolution_dpi = 200;         
fig_size_cm = [12, 10];         


%Draw1(inv_T,SRM_param.norm_min_spacing,IAM_param.inverse_name,extent_UV1,Fov1,save_folder, resolution_dpi, fig_size_cm);
Draw(inv_T,SRM_param.norm_min_spacing,IAM_param.inverse_name,extent_UV1,Fov1);

%All code will be made publicly available upon the acceptance of the paper.
% Cal_T_dist = CASsimulate(Fov,delta,CAS_param,sys_param.div);

% Cal_self_correlation_matrix = SRMS(Cal_T_dist,sys_param,SRM_param,0);

% Calculated_error = CASJROneSourceCalibration(Cal_self_correlation_matrix,SRM_param.norm_ant_pos,CAS_param.nomipoint_place);

% Calibrated_self_correlation_matrix = CASC(self_correlation_matrix,Calculated_error);


% IAM_param.inverse_name = IA(sys_param.inverse_name,sys_param.array_type); 

% [inv_T2,extent_UV2,Fov2] = IAMS(Calibrated_self_correlation_matrix,SRM_param,IAM_param);


% inv_TT = TAbsC(inv_T2,IAM_param.inverse_name);


% filepath = 'E:\wucha\2.mat';

% save(filepath, 'inv_TT');

% DrawInvPic(inv_TT,SRM_param.norm_min_spacing,IAM_param.inverse_name,extent_UV2,Fov2);

% 
% 

% Cal_T_dist = CASsimulate(Fov,delta,CAS_param1,sys_param.div);

% Cal_self_correlation_matrix = SRMS(Cal_T_dist,sys_param,SRM_param,2);

% Calculated_error = CASJROneSourceCalibration(Cal_self_correlation_matrix,SRM_param.norm_ant_pos,CAS_param1.nomipoint_place);

% Calibrated_self_correlation_matrix = CASCalibration(self_correlation_matrix,Calculated_error);

% IAM_param.inverse_name = IA(sys_param.inverse_name,sys_param.array_type); 

% [inv_T2,extent_UV2,Fov2] = IAMS(Calibrated_self_correlation_matrix,SRM_param,IAM_param);

% inv_TT = TAbsC(inv_T2,IAM_param.inverse_name);

% filepath = 'E:\wucha\3.mat';

% save(filepath, 'inv_TT');

% Draw(inv_TT,SRM_param.norm_min_spacing,IAM_param.inverse_name,extent_UV2,Fov2);

toc;
% 
% figure()
% min_spacing = SRM_param.norm_min_spacing;
% ant_pos = SRM_param.norm_ant_pos;
% if size(ant_pos,1) == 1
%     ant_pos(2,:) = 0;
% end
% 
% plot(min_spacing*ant_pos(1,:),min_spacing*ant_pos(2,:),'o');

% 
% toc; 
% figure()
% min_spacing = SRM_param.norm_min_spacing;
% ant_pos = SRM_param.norm_ant_pos;
% if size(ant_pos,1) == 1
%     ant_pos(2,:) = 0;
% end
% 

% num_antennas = size(ant_pos, 2);
% mid_index = round(num_antennas/3); % Approximate midpoint for splitting
% 

% arm1_indices = 1:mid_index;
% x1 = min_spacing*ant_pos(1, arm1_indices);
% y1 = min_spacing*ant_pos(2, arm1_indices);
% plot(x1, y1, 'o', 'MarkerFaceColor', '#00B9FF');
% hold on;

% arm2_indices = mid_index+1:2*mid_index;
% x2 = min_spacing*ant_pos(1, arm2_indices);
% y2 = min_spacing*ant_pos(2, arm2_indices);
% plot(x2, y2, 'o', 'MarkerFaceColor', '#FFB300');
% hold on;
% 

% arm3_indices = 2*mid_index+1:num_antennas;
% x3 = min_spacing*ant_pos(1, arm3_indices);
% y3 = min_spacing*ant_pos(2, arm3_indices);
% plot(x3, y3, 'o', 'MarkerFaceColor', '#BF1F61');
% hold off;
% 

% set(gca, 'FontSize', 16);
% profile off
% profile viewer
memInfo = memory;
disp(memInfo);

