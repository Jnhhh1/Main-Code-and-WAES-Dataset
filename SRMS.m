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

%disp(coef_matrix);（1，24）
%disp(real_coef_matrix);（1，24，41）

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
            real_ant_pos = norm_ant_pos + norm_min_spacing*ant_pos_error_quantity*randn(size(norm_ant_pos));%误差产生
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%平面阵列的情况%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag ==0)
    % 得到新的基线排列：
    switch lower(ant_pos_error_type)
        case 'normal'    %误差呈正太分布
            real_ant_pos = norm_ant_pos + norm_min_spacing*ant_pos_error_quantity*randn(size(norm_ant_pos));%误差产生
        case 'constant'  %误差呈常数分布
            real_ant_pos = norm_ant_pos + ant_pos_error_quantity;
        case 'uniform'   %误差呈均匀分布
            real_ant_pos = norm_ant_pos + ((ant_pos_error_quantity(2)-ant_pos_error_quantity(1))*rand(size(norm_ant_pos))+ant_pos_error_quantity(1));
        otherwise        %误差为手动输入
            real_ant_pos = norm_ant_pos + ant_pos_error_type;
    end
    real_ant_pos(1,:) = real_ant_pos(1,:) - real_ant_pos(1,1);%使第一个基线始终为0，作为参考点
    real_ant_pos(2,:) = real_ant_pos(2,:) - real_ant_pos(2,1);%使第一个基线始终为0，作为参考点
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function coef_matrix = SRMPatternGenerate(antenna_pattern_info,angle_info,array_type);

% 参数读入：
antenna_type = antenna_pattern_info.antenna_type; %天线类型从结构体中获取
antenna_size = antenna_pattern_info.antenna_size; %天线尺寸从结构体中获取
wavelength = antenna_pattern_info.wavelength;     %天线工作波长从结构体中获取

%%%%%%%%%%%%%%%%%方向图为手动输入%%%%%%%
if(ischar(antenna_type)==0) 
    coef_matrix = antenna_type;  %直接读取
    array_type = 2;              %避免下面程序的运行
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%一维阵情况%%%%%%%%%%%%%%%%%%%%%

if(array_type==1) %一维阵情况
    %天线形式：
    switch lower(antenna_type)
        case 'rectangle'% 矩形口面
            lx = pi*antenna_size(1)/wavelength;
            for k = 1:length(angle_info)
                coef_matrix(k) = abs(cosd(angle_info(k))*sinc(lx*sind(angle_info(k))));
            end
            %矩形天线结束

        case'isotropic'%理想，各个方向均为1
            coef_matrix = ones(size(angle_info));
            %理想天线结束

        case'circle'%圆形口面
            Ba = 2*pi*antenna_size/wavelength;
            for k = 1:length(angle_info)
                if (abs(sind(angle_info(k)))<=0.0001) %避免分母为0时出错
                    coef_matrix(k) = 1;
                else
                    coef_matrix(k) = abs(2*real(besselj(1,Ba*sind(angle_info(k))))/(Ba*sind(angle_info(k))));
                end
            end
            %圆形天线结束
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%平面阵情况%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(array_type==0)  %平面阵情况
    %天线形式：
    switch lower(antenna_type)    % 将天线类型转换为小写，方便匹配
        case 'rectangle'% 矩形口面
            lx = pi*antenna_size(1)/wavelength;  % 计算矩形天线在x方向的归一化尺寸
            ly = pi*antenna_size(2)/wavelength;  % 计算矩形天线在y方向的归一化尺寸
            source_num = length(angle_info(1,:));  % 获取角度信息的数量（即信号源数量）
            
            for k = 1:source_num
                u = sind(angle_info(1,k))*cosd(angle_info(2,k));  % 计算u值（x方向的投影）
                v = sind(angle_info(1,k))*sind(angle_info(2,k));  % 计算v值（y方向的投影）
                coef_matrix(k) = abs(sinc(lx*u)*sinc(ly*v));  % 计算矩形天线的方向图系数
           
            end
            %矩形天线结束

        case'isotropic'%理想，各个方向均为1
            coef_matrix = ones(1,length(angle_info(1,:)));   % 理想天线在所有方向上的系数均为1
            %理想天线结束

        case'circle'%圆形口面
            Ba = 2*pi*antenna_size/wavelength;   % 计算圆形天线的归一化尺寸
            source_num = length(angle_info(1,:));  % 获取角度信息的数量（即信号源数量）
            for k = 1:source_num
                if(sind(angle_info(1,k))<=0.0001)  %避免分母为0时出错
                    coef_matrix(k) = 1;
                else
                    % 计算圆形天线的方向图系数
                    coef_matrix(k) = abs(2*real(besselj(1,Ba*sind(angle_info(1,k))))/(Ba*sind(angle_info(1,k))));
                end
            end
            %圆形天线结束
    end
end


function real_coef_matrix = SRMPatternErrorGenerate(coef_matrix,pattern_error_quantity,antenna_num,pattern_error_type);

for antenna_seria = 1:antenna_num%对每个天线都做如下操作
    switch lower(pattern_error_type)
        case 'normal'
            error_coef_matrix = coef_matrix + pattern_error_quantity*randn(size(coef_matrix));%随机噪声注入
        case 'constant'
            error_coef_matrix = coef_matrix + pattern_error_quantity;%随机噪声注入
        case 'uniform'
            error_coef_matrix = coef_matrix + (pattern_error_quantity(2)-pattern_error_quantity(1))*rand(size(coef_matrix))+pattern_error_quantity(1);%随机噪声注入
    end
    % 注入随机噪声之后需要对方向图重新归一化
    %使得方向图总是在[0 1]范围内：
    for p = 1:size(error_coef_matrix,1)
        for q = 1:size(error_coef_matrix,2)
            if(error_coef_matrix(p,q)>1)
                error_coef_matrix(p,q) = 1;
            elseif(error_coef_matrix(p,q)<0)
                error_coef_matrix(p,q) = 0;
            end
        end
    end
    
    real_coef_matrix(antenna_seria) = {error_coef_matrix};%封装在cell中
    % matrix_value = real_coef_matrix{antenna_seria};
    % disp(matrix_value);
end


function mutual_matrix = SRMMutualErrorGenerate(min_spacing,ant_pos,mutual_error_quantity,mutual_error_type);

if(ischar(mutual_error_type)==0)       %互耦误差为手动输入,如果不是字符串类型
    mutual_matrix = mutual_error_type;
else
    %天线个数:24
    ata_num = length(ant_pos(1,:));
    
    %互耦误差模型与其它误差不同，应遵守天线距离越远，互耦越小的原则
    if(isvector(ant_pos) == 1)%如果是一维阵列
        ant_pos(2,:) = zeros(1,ata_num);%将其转换为纵向位置均为0的平面阵列，以便统一处理,将 1xata_num 的零矩阵赋值给 ant_pos 的第二行
    end

    % 得到距离矩阵distance_matrix,其第i行第j列的元素表示第i个天线与第j个天线的距离差
    distance_matrix = zeros(ata_num,ata_num);%初始化
    for p = 1:ata_num
        for q = 1:ata_num
            if(q>p)
                distance_matrix(p,q) = abs((ant_pos(1,q)-ant_pos(1,p))+j*(ant_pos(2,q)-ant_pos(2,p)));
            end
        end
    end
    % 产生上三角互耦矩阵，互耦大小与距离成反比
    mutual_matrix = zeros(ata_num,ata_num);%初始化
    for p = 1:ata_num
        for q = 1:ata_num
            if(q>p)
                switch lower(mutual_error_type)
                    case 'normal'
                        %随机产生互耦系数，其大小与mutual_error_quantity成正比，与距离成反比
                        mutual_matrix(p,q) = randn(1,1)*mutual_error_quantity/(min_spacing*distance_matrix(p,q));
                        mutual_matrix(p,q) = abs(mutual_matrix(p,q));
                    case 'constant'
                        mutual_matrix(p,q) = mutual_error_quantity/(min_spacing*distance_matrix(p,q));
                    case 'uniform'
                        %随机产生互耦系数，其大小与mutual_error_quantity成正比，与距离成反比
                        mutual_matrix(p,q) = (rand(1,1)*(mutual_error_quantity(2)-mutual_error_quantity(1))+mutual_error_quantity(1))/(min_spacing*distance_matrix(p,q));
                end
            end
        end
    end
    % 产生互耦矩阵
    mutual_matrix = mutual_matrix+mutual_matrix.';             %非对角线部分应为对称的
    mutual_matrix_diag = ones(1,ata_num)-sum(mutual_matrix);   %对角线部分应减去互耦损失掉的能量
    mutual_matrix = mutual_matrix+diag(mutual_matrix_diag);    %上面两部分结合获得互耦矩阵
end


function [error_amp,error_Iphase,error_Qphase] = SRMChannelErrorGenerate(antenna_num,channel_info);

%%%%%%%%%%%%%%%%%%通道幅度误差%%%%%%%%%%%%%%%%%%%%%%%%%
switch lower(channel_info.error_amp_type)
    case 'normal'
       error_amp  = ones(1,antenna_num) + channel_info.error_amp_quantity*randn(1,antenna_num);
    case 'constant'
       error_amp  = ones(1,antenna_num) + channel_info.error_amp_quantity;
    case 'uniform'
       error_amp  = (channel_info.error_amp_quantity(2)-channel_info.error_amp_quantity(1))*rand(1,antenna_num) + channel_info.error_amp_quantity(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%通道同相相位误差%%%%%%%%%%%%%%%%%%%%%%%%%
switch lower(channel_info.error_Iphase_type)
    case 'normal'
       error_Iphase  = zeros(1,antenna_num) + channel_info.error_Iphase_quantity*randn(1,antenna_num);
    case 'constant'
       error_Iphase  = zeros(1,antenna_num) + channel_info.error_Iphase_quantity;
    case 'uniform'
       error_Iphase  = (channel_info.error_Iphase_quantity(2)-channel_info.error_Iphase_quantity(1))*rand(1,antenna_num) + channel_info.error_Iphase_quantity(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%通道正交相位误差%%%%%%%%%%%%%%%%%%%%%%%%%
switch lower(channel_info.error_Qphase_type)
    case 'normal'
       error_Qphase  = zeros(antenna_num,antenna_num) + channel_info.error_Qphase_quantity*randn(antenna_num,antenna_num);
    case 'constant'
       error_Qphase  = zeros(antenna_num,antenna_num) + channel_info.error_Qphase_quantity;
    case 'uniform'
       error_Qphase  = (channel_info.error_Qphase_quantity(2)-channel_info.error_Qphase_quantity(1))*rand(antenna_num,antenna_num) + channel_info.error_Qphase_quantity(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error_Qphase = triu(error_Qphase,1)-triu(error_Qphase,1)'; %对角线处为0


function self_correlation_matrix = SRMSignalOutput(T_dist,ant_pos,min_spacing,pattern_coef,mutual,T_rec,error_amp,error_Iphase,error_Qphase);

%天线个数
antenna_num = length(ant_pos(1,:));
%阵列的基线排列等于基线的最小尺寸乘基线排列
ant_pos =  min_spacing*ant_pos; 
%通道幅相误差
error_amp_phase = exp(j*error_Iphase).*error_amp;

%判断是一维阵列还是平面阵列
if(isvector(ant_pos) == 1)
    flag = 1; %一维阵列
else
    flag = 0; %平面阵列
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%一维阵列的情况%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag==1)
    %分析场景信息
    scene_power = T_dist(1,:); %源的功率向量
    scene_theta = T_dist(2,:); %源的位置向量
    
    for k = 1:antenna_num %读取单元天线方向图
        coef_matrix(k,:) = cell2mat(pattern_coef(k));
    end
    
    % 定义引导向量A：
    for k=1:length(scene_power)
        A(:,k)=sqrt(coef_matrix(:,k)).*[exp(2*pi*j*ant_pos*sind(scene_theta(k)))].';       
    end
    
    % 考虑通道幅相误差情况下的引导向量A:
    A = diag(error_amp_phase)*A;
    
    % 考虑互藕情况下的引导向量A:
    A = mutual*A;   
    % 求出信号自相关矩阵
    self_correlation_matrix = A*diag(scene_power)*A';
    % 考虑通道噪声对自相关矩阵的影响
    self_correlation_matrix = self_correlation_matrix + diag(error_amp)*diag(error_amp)*T_rec;   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%平面阵列的情况%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag ==0)    
    scene_power = T_dist(1,:); %源的功率向量
    scene_theta = T_dist(2,:); %源的位置向量theta
    scene_phy = T_dist(3,:);   %源的位置向量phy
    
    for k = 1:antenna_num%读取单元天线方向图
        coef_matrix(k,:) = cell2mat(pattern_coef(k));
    end
    
    %coef_matrix (24,41)
    % 定义引导向量A：(24,41)矩阵 A 被称为引导矩阵（Steering Matrix），
    % 它是阵列信号处理中的一个核心概念。引导矩阵 A 的作用是将信号源的空间信息（如方向、位置等）与天线阵列的几何结构联系起来，从而描述信号在不同天线单元上的响应。
    for k=1:length(scene_power)
        A(:,k)=sqrt(coef_matrix(:,k)).*[exp(2*pi*j*sind(scene_theta(k))*(ant_pos(1,:)*cosd(scene_phy(k))+ant_pos(2,:)*sind(scene_phy(k))))].';
    end
    
    % 考虑通道幅相误差情况下的引导向量A:
    %diag(error_amp_phase) (24,24)
    A = diag(error_amp_phase)*A;
    size(A)
    % 考虑互藕情况下的引导向量A:
    A = mutual*A;
    % 求出信号自相关矩阵
%      self_correlation_matrix = A*diag(scene_power)*A';
    %当矩阵规模太大时，用矩阵分块算法
    N=10;
    scenepixel_num=size(scene_power,2);
    channels_num=size(A,1);
    self_correlation_matrix=zeros(channels_num,channels_num);
    scenepixel_div = round(scenepixel_num/N); %4
    
    for n=1:N-1
    S1=diag(scene_power(:,(n-1)*scenepixel_div+1:n*scenepixel_div));
    A1=A(:,(n-1)*scenepixel_div+1:n*scenepixel_div);
    self_correlation_matrix=self_correlation_matrix+A1*S1*A1';
   
    end
    
    
    S1=diag(scene_power(:,(N-1)*scenepixel_div+1:scenepixel_num));
    A1=A(:,(N-1)*scenepixel_div+1:scenepixel_num);
    self_correlation_matrix=self_correlation_matrix+A1*S1*A1';
    
    % 考虑通道本底对自相关矩阵的影响 (24,24)
    self_correlation_matrix = self_correlation_matrix + diag(error_amp)*diag(error_amp)*T_rec;
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function re_self_correlation_matrix = SRMCorrelationSim(self_correlation_matrix,sampling_num,error_Qphase)

%天线个数
antenna_num = length(self_correlation_matrix(1,:));
% 计算自相关矩阵的方差:
for p = 1:antenna_num
    for q = 1:antenna_num
        correlation_matrix_var(p,q) = self_correlation_matrix(p,p)*self_correlation_matrix(q,q)/sampling_num;
    end
end

% 产生标准随机误差矩阵：
% 随机矩阵初始化
error_matrix = zeros(antenna_num,antenna_num);
% 随机矩阵生成
for p = 2:antenna_num
    for q = 1:p-1
        error_matrix(p,q) = (randn(1,1)+j*randn(1,1))/sqrt(2);
    end
end
% 保证随机矩阵的hermite特性
error_matrix = error_matrix+error_matrix';
% 保证随机矩阵的对角线为实数
for k = 1:antenna_num  
    error_matrix(k,k) = randn(1,1); %对角线上为实随机过程
end

% 产生随机误差矩阵：
error_matrix = error_matrix.*sqrt(correlation_matrix_var);
self_correlation_matrix = self_correlation_matrix + error_matrix;

%%%% 最后添加正交误差：
error_Qphase_matrix = error_Qphase;

angle_matrix = angle(self_correlation_matrix);

amp_matrix = abs(self_correlation_matrix);

re_self_correlation_matrix = amp_matrix.*cos(angle_matrix) + j*amp_matrix.*sin(angle_matrix-error_Qphase_matrix);

