%% ========================================================================
% ROPE map:
% For “(de)activated” voxels, the ROPE map contains maximum ES thresholds
% allowing to classify voxels as “(de)activated” based on the “ROPE-only”
% or “HDI+ROPE” decision rules.
% For “not activated” voxels, it contains minimum effect size thresholds 
% allowing to classify voxels as “not activated.” 

% The "ROPE-only" and "HDI+ROPE" decision rules (Kruschke, 2018)

% Masharipov Ruslan, May, 2021
% Institute of Human Brain of RAS, St. Petersburg, Russia
% Neuroimaging lab
% masharipov@ihb.spb.ru
% =========================================================================

% Before running the script use SPM12 (v6906) to:
% 1) Create GLM for one sample test or two sample test
% 2) Estimate model using method: Classical
% 3) Estimate model using method: Bayesian 2nd-level
%% ========================================================================
clear
close all
tic
% Load SPM.mat
[spmmatfile] = spm_select(1,'^SPM\.mat$','Select SPM.mat');
load(spmmatfile);
% Set path
path = SPM.swd;
cd(path)

% One or two sample
switch char(SPM.xX.name(1))
    case 'mean'
        c = spm_input('Select contrast:','+1','+1|-1',[1,-1],1);
    case 'Group_{1}'
        c1 = [1;-1]; c2 = [-1;1];
        c = spm_input('Select contrast:','+1','[1 -1]|[-1 1]',[c1,c2],1);
        c = c';
    otherwise
    error('Error: Choose GLM for One smaple or Two sample test')
end

% Read Posterior Beta
XYZ  = SPM.xVol.XYZ;
switch char(SPM.xX.name(1))
    case 'mean'
        cB = spm_data_read(SPM.VCbeta,'xyz',XYZ);
        cB = c*cB;
    case 'Group_{1}'
        cB1 = spm_data_read(SPM.VCbeta(1),'xyz',XYZ);
        cB2 = spm_data_read(SPM.VCbeta(2),'xyz',XYZ);
        cB = c'*[cB1;cB2];   
end

% Compute Posterior Variance
VcB   = c'*SPM.PPM.Cby*c;
for j = 1:length(SPM.PPM.l)
    l   = spm_data_read(SPM.VHp(j),'xyz',XYZ);              % hyperparameter
    VcB = VcB + (c'*SPM.PPM.dC{j}*c)*(l - SPM.PPM.l(j));    % Taylor approximation
end

% Decision rule
rule = spm_input('Decision rule:','+1','ROPE-only|HDI+ROPE',[1,2],1);

% Effect size threshold
ES = 0:0.001:(max(cB)+sqrt(max(VcB)));

switch rule
    case 1 %ROPE only
        f = waitbar(0,'Step 1: Computing LPOs');
        for thr=1:length(ES)
            LPO_pos(thr,:) = log((normcdf(-ES(thr),-cB,sqrt(VcB)))./normcdf(ES(thr),cB,sqrt(VcB)));
            LPO_neg(thr,:) = log((normcdf(-ES(thr),cB,sqrt(VcB)))./(1 - normcdf(-ES(thr),cB,sqrt(VcB))));
            LPO_null(thr,:) = log((normcdf(ES(thr),cB,sqrt(VcB)) - normcdf(-ES(thr),cB,sqrt(VcB)))...
                            ./(1 - normcdf(ES(thr),cB,sqrt(VcB)) + normcdf(-ES(thr),cB,sqrt(VcB))));
            waitbar(thr/length(ES),f,'Step 1: Computing LPOs')
        end
        delete(f)
        LPO_pos(LPO_pos == -inf) = -745;
        LPO_neg(LPO_neg == -inf) = -745;
        LPO_null(LPO_null == -inf) = -745;
        LPO_null(LPO_null == inf) = 745;
        f = waitbar(0,'Step 2: Computing ROPE maps');
        for i=1:length(cB)
            ind_minES_null(i) = find(LPO_null(:,i)>=3,1);
            ind_maxES_pos(i) = find(LPO_pos(:,i)<=3,1);
            ind_maxES_neg(i) = find(LPO_neg(:,i)<=3,1);
            waitbar(i/length(cB),f,'Step 2: Computing ROPE maps')
        end
        delete(f)
        ind_maxES_pos(LPO_pos(1,:)<=3) = length(ES)+1;
        ind_maxES_neg(LPO_neg(1,:)<=3) = length(ES)+1;
        f = waitbar(0,'Step 3: Computing ROPE maps');
        for i=1:length(cB)
            map_null(i) = ES(ind_minES_null(i));
            if ind_maxES_pos(i)>ind_minES_null(i) && ind_maxES_neg(i)>ind_minES_null(i)
               %map_null(i) = ES(ind_minES_null(i));
               map_pos(i) = NaN;
               map_neg(i) = NaN;
            elseif ind_maxES_pos(i)<ind_minES_null(i) && ind_maxES_neg(i)>ind_minES_null(i)
               %map_null(i) = 0;
               map_pos(i) = ES(ind_maxES_pos(i)-1);
               map_neg(i) = NaN;
            else
               %map_null(i) = 0;
               map_pos(i) = NaN;
               map_neg(i) = ES(ind_maxES_neg(i)-1);        
            end
            waitbar(i/length(cB),f,'Step 3: Computing ROPE maps')
        end
        delete(f)
        rule_name = 'ROPE_only'
    case 2 %HDI+ROPE
        HDImax = spm_invNcdf(0.975,cB,VcB);
        HDImin = spm_invNcdf(0.025,cB,VcB);
        f = waitbar(0,'Computing ROPE maps (Step 1/3)');
        for thr=1:length(ES)
            ROPE_max = ES(thr);
            ROPE_min = -ES(thr);
            HDI_ROPE_null(thr,:) = (HDImin>=ROPE_min & HDImax<=ROPE_max);
            HDI_ROPE_pos(thr,:) = (HDImin>ROPE_max);
            HDI_ROPE_neg(thr,:) = (HDImax<ROPE_min);
            waitbar(thr/length(ES),f,'Computing ROPE maps (Step 1/3)')
        end
        delete(f)
        f = waitbar(0,'Computing ROPE maps (Step 2/3)');
        for i=1:length(cB)
            ind_minES_null(i) = find(HDI_ROPE_null(:,i)>0,1);
            ind_maxES_pos(i) = find(HDI_ROPE_pos(:,i)==0,1);
            ind_maxES_neg(i) = find(HDI_ROPE_neg(:,i)==0,1);
            waitbar(i/length(cB),f,'Computing ROPE maps (Step 2/3)')
        end
        delete(f)
        ind_maxES_pos(HDI_ROPE_pos(1,:)==0) = length(ES)+1;
        ind_maxES_neg(HDI_ROPE_neg(1,:)==0) = length(ES)+1;
        f = waitbar(0,'Computing ROPE maps (Step 3/3)');
        for i=1:length(cB)
            map_null(i) = ES(ind_minES_null(i));
            if ind_maxES_pos(i)>ind_minES_null(i) && ind_maxES_neg(i)>ind_minES_null(i)
               %map_null(i) = ES(ind_minES_null(i));
               map_pos(i) = 0;
               map_neg(i) = 0;
            elseif ind_maxES_pos(i)<ind_minES_null(i) && ind_maxES_neg(i)>ind_minES_null(i)
               %map_null(i) = 0;
               map_pos(i) = ES(ind_maxES_pos(i)-1);
               map_neg(i) = 0;
            else
               %map_null(i) = 0;
               map_pos(i) = 0;
               map_neg(i) = ES(ind_maxES_neg(i)-1);        
            end
            waitbar(i/length(cB),f,'Computing ROPE maps (Step 3/3)')
        end
        delete(f)
        rule_name = 'HDI_ROPE'
end

status = exist('ROPE_maps');
if status ~= 7
    mkdir 'ROPE_maps'; 
end

name_1 = {['01_Positive_effect']}; 
name_2 = {['02_Null_effect']}; 
name_3 = {['03_Negative_effect']}; 
descr_1 = {['01_Positive_effect']}; 
descr_2 = {['02_Null_effect']}; 
descr_3 = {['03_Negative_effect']};

info=struct ('name', [name_1 name_2 name_3],...
            'description', [descr_1 descr_2 descr_3]);
        
all=[map_pos; map_null; map_neg];

%hdr
hdr = spm_vol([path '\Cbeta_0001.nii']);

%mask
mask = spm_read_vols(hdr);
mask(~isnan(mask)) = 0;

%iXYZ
iXYZ = cumprod([1,SPM.xVol.DIM(1:2)'])*XYZ - sum(cumprod(SPM.xVol.DIM(1:2)'));

%save images
for j=1:3
    hdr.fname = [path '\ROPE_maps\' rule_name '_' info(j).name '.nii'];  
    hdr.descrip = [info(j).description];    
    hdr.private.descrip = [info(j).description];
    tmp           = mask;
    tmp(iXYZ)     = all(j,:);
    spm_write_vol(hdr,tmp);
    clear tmp 
end

time = toc;
fprintf(['===============================\n' 'Done in ' num2str(time) ' s\n' '===============================\n']);
clear
close all

