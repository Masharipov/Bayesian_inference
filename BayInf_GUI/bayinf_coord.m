%% ========================================================================
% Auxiliary function for bayinf_vis.m that tracks coordinates and overlay
% intensities.

% =========================================================================
% Masharipov Ruslan, Ogai Andrey, May, 2021
% Institute of Human Brain of RAS, St. Petersburg, Russia
% Neuroimaging lab
% masharipov@ihb.spb.ru

%% ========================================================================

function bayinf_coord()
global handles

global pos_img
global null_img
global neg_img

XYZmm = round(spm_orthviews('Pos'));

XYZmm = mat2str(XYZmm, 2);
XYZmm = strrep(XYZmm,';',' ');
XYZmm = XYZmm(2:end-1);

set(handles.vis_mm_edit, 'String', XYZmm);      
if exist('overlay_red.nii','file') == 2
    pos_xyz = round(mm2vox(spm_orthviews('Pos'), strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_red.nii'])));
    if any(pos_xyz < 0)
        pos_int = 0;
    else
        pos_int = pos_img(min(size(pos_img, 1), pos_xyz(1)), min(size(pos_img, 2), pos_xyz(2)), min(size(pos_img, 3), pos_xyz(3)));
    end
    if isnan(pos_int)
        pos_int = 0;
    end
else
    pos_int = 0;
end
set(handles.vis_pos_edit, 'String', pos_int);  

if exist('overlay_green.nii','file') == 2
    null_xyz = round(mm2vox(spm_orthviews('Pos'), strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_green.nii'])));
    if any(null_xyz < 0)
        null_int = 0;
    else
        null_int = null_img(min(size(null_img, 1), null_xyz(1)), min(size(null_img, 2), null_xyz(2)), min(size(null_img, 3), null_xyz(3)));
    end
    if isnan(null_int)
        null_int = 0;
    end
else
    null_int = 0;
end

set(handles.vis_null_edit, 'String', null_int);  

if exist('overlay_blue.nii','file') == 2
    neg_xyz = round(mm2vox(spm_orthviews('Pos'), strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_blue.nii'])));

    if any(neg_xyz < 0)
        neg_int = 0;
    else
        neg_int = neg_img(min(size(neg_img, 1), neg_xyz(1)), min(size(neg_img, 2), neg_xyz(2)), min(size(neg_img, 3), neg_xyz(3)));
    end
    if isnan(neg_int)
        neg_int = 0;
    end
else
    neg_int = 0;
end

set(handles.vis_neg_edit, 'String', neg_int);  
    
return