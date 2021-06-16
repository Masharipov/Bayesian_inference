%% ========================================================================
% BayInf: Graphical User Interface (GUI) for Bayesian inference based on
% Statistical Parametric Mapping (SPM12, v6906).
%
% The GUI is comprised of several parts:
%
% 1) Bayesian Parameter Inference (BPI) (bayinf_bpi.m)
% 1.1) calculation of Posterior Probability Maps (PPMs) of finding the
% effect within or outside the Region Of Practical Equivalence (ROPE)
% 1.2) calculation of Log Posterior Odds maps (LPOs) based on PPMs
% 1.3) The 'ROPE-only' decision rule: saves unthresholded PPMs and LPOs
% 1.4) The 'HDI+ROPE' decision rule: saves thresholded PPMs and LPOs
%      (keeps only voxels with confident decision
%       where 95% HDI do not overlap with the ROPE)

% 2) ROPE maps (bayinf_rope_maps.m)
% Calculating the ROPE maps based on the 'ROPE-only' or 'HDI+ROPE' rule

% 3) Visualise
% Visualisation of statistical maps (PPMs, LPOs, ROPE maps)

% =========================================================================
% Masharipov Ruslan, Ogai Andrey, May, 2021
% Institute of Human Brain of RAS, St. Petersburg, Russia
% Neuroimaging lab
% masharipov@ihb.spb.ru

% Version 1.0
%% ========================================================================

% GUI INITIALISATION
function bayinf(varargin)
clear
close all

handles.fig = figure('units','norm','position',[.1875,.5,.15,.35],'name','BayInf','menubar','none','numbertitle','off','color','w');
handles.bpi = uicontrol('units','norm','position',[.05,.77, .9,.165],'style','pushbutton','string','BPI','fontsize',12,'callback',{@bayinf_gui,'bpi'});
handles.rop = uicontrol('units','norm','position',[.05,.59, .9,.165],'style','pushbutton','string','ROPE Maps','fontsize',12,'callback',{@bayinf_gui,'rope'});
handles.vis = uicontrol('units','norm','position',[.05,.41, .9,.165],'style','pushbutton','string','Visualise','fontsize',12,'callback',{@bayinf_gui,'vis'});
handles.hlp = uicontrol('units','norm','position',[.05,.050, .4425,.165],'style','pushbutton','string','Help','fontsize',12,'callback',{@bayinf_gui,'help'});
handles.ext = uicontrol('units','norm','position',[.5075,.050, .4425,.165],'style','pushbutton','string','Exit','fontsize',12,'callback',{@bayinf_gui,'exit'});
		
spm_ver = spm('ver','',1);
if ~strcmpi(spm_ver,'spm12')
    disp(['Warning! Wrong SPM version (' spm_ver '). Please use SPM12(v6906).']);
end
return

% CALLBACK FUNCTION FOR GUI
function bayinf_gui(varargin)

global pos_path
global null_path
global neg_path

global pos_thr
global null_thr
global neg_thr

global pos_int
global null_int
global neg_int

pos_path = '';
null_path = '';
neg_path = '';

pos_thr = 3;
null_thr = 3;
neg_thr = 3;

pos_int = 27;
null_int = 27;
neg_int = 27;

option = varargin{3};
switch(option)
    case 'bpi'
        [pos_file_path, null_file_path, neg_file_path, mask_path] = bayinf_bpi;
		if ~isempty(mask_path)
            bayinf_vis('start_pos', pos_file_path, 'start_null', null_file_path, 'start_neg', neg_file_path);
        end               
    case 'vis'
        bayinf_vis();    
    case 'rope'
        [pos_file_path, null_file_path, neg_file_path, mask_path, pos_max, null_max, neg_max] = bayinf_rope_maps;
		if ~isempty(mask_path)
            bayinf_vis('start_pos', pos_file_path, 'start_null', null_file_path, 'start_neg', neg_file_path, ...
            'start_pos_thresh', [0 pos_max], 'start_null_thresh', [0 null_max], 'start_neg_thresh', [0 neg_max]);
        end
    case 'help'
		open('manual.pdf')
    case 'exit'
		close all    
end
return



