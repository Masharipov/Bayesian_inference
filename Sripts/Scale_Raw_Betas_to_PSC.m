%======================================================================== 
%Scale Raw Beta-values to Percent Signal Change (Poldrack, Mumford, Nichols, 2011, p.186)

%Masharipov Ruslan, october, 2019
%Institute of Human Brain of RAS, St. Petersburg, Russia
%Neuroimaging lab
%masharipov@ihb.spb.ru
%======================================================================== 

%This is an example of scaling for a single subject

% 1) estimate GLM for single subject using SPM12
% 2) load SPM.mat 

%set path
path = SPM.swd;
cd(path)

%scaling factor based on reference trial (single event HRF)
SF=max(SPM.xBF.bf(:,1))/SPM.xBF.dt; %(for zero-duration events)

%define indexes of 'constant term' columns
%e.g. two sessions:
constant_term_sess1=size(SPM.xX.X,2)-1;
constant_term_sess2=size(SPM.xX.X,2);
 
%beta image for constant term
name_beta_constant_term_sess1 = ['beta_00' num2str(constant_term_sess1) '.nii'];
name_beta_constant_term_sess2 = ['beta_00' num2str(constant_term_sess2) '.nii'];
 
C1 = spm_vol([path '\' name_beta_constant_term_sess1]);
C2 = spm_vol([path '\' name_beta_constant_term_sess2]);
beta_constant_term_sess1 = spm_read_vols(C1);
beta_constant_term_sess2 = spm_read_vols(C2);
 
bmean_sess1 = mean(beta_constant_term_sess1(beta_constant_term_sess1>0));
bmean_sess2 = mean(beta_constant_term_sess2(beta_constant_term_sess2>0));
 
%convert beta for conditions of interest in PSC
%define indexes for choosen conditions: beta_****.nii
%e.g. [Condition 1 > Baseline] and [Condition 2 > Baseline]
%for session 1
B1 = spm_vol([path '\beta_****.nii']); 
B2 = spm_vol([path '\beta_****.nii']); 
beta1 = spm_read_vols(B1); 
beta2 = spm_read_vols(B2);
PSC(1).values = (beta1.*SF.*100)./bmean_sess1;
PSC(2).values = (beta2.*SF.*100)./bmean_sess1;
%for session 2
B3 = spm_vol([path '\beta_****.nii']);
B4 = spm_vol([path '\beta_****.nii']);
beta3 = spm_read_vols(B3); 
beta4 = spm_read_vols(B4); 
PSC(3).values = (beta3.*SF.*100)./bmean_sess2;
PSC(4).values = (beta4.*SF.*100)./bmean_sess2;

%make linear contrasts
%the sum of positive weights must be 1
%the sum of negative weights must be -1
%e.g. [Condition 1 - Condition 2]
%for session 1
PSC(5).values = PSC(1).values - PSC(2).values;
%for session 2
PSC(6).values = PSC(3).values - PSC(4).values;
%for both sessions
PSC(7).values = 0.5.*PSC(1).values - 0.5.*PSC(2).values + ...
    0.5.*PSC(3).values - 0.5.*PSC(4).values;
 
%save
header(1:7)=B1;
for j = [1:7]
       header(j).fname = [path '\PSC_' num2str(j, '%04d') '.nii'];
       header(j).descrip = 'Percent signal change image';    
       header(j).private.descrip = 'Percent signal change image';
end
 
for k = [1:7]
    spm_write_vol(header(k),PSC(k).values);
end
 
clear
