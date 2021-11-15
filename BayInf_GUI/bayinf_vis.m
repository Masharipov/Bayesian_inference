%% ========================================================================
% GUI for visualising structural MRI images & overlaying statistical maps.

% start_struct: path to structural image that will be used in GUI. 
%               if empty, the default structural image is used.
% start_pos:    path to positive overlay that will be used in GUI. 
%               if empty, no overlay is used.
% start_null:   path to null overlay that will be used in GUI. 
%               if empty, no overlay is used.
% start_neg:    path to negative overlay that will be used in GUI. 
%               if empty, no overlay is used.

% start_pos_thresh:  minimum and maximum threshold for positive overlay
%                    input as matrix [min max] ([3 27] by default)
% start_null_thresh: minimum and maximum threshold for null overlay
%                    input as matrix [min max] ([3 27] by default)
% start_neg_thresh:  minimum and maximum threshold for negative overlay
%                    input as matrix [min max] ([3 27] by default)

% =========================================================================
% Masharipov Ruslan, Ogai Andrey, May, 2021
% Institute of Human Brain of RAS, St. Petersburg, Russia
% Neuroimaging lab
% masharipov@ihb.spb.ru

%% ========================================================================
function bayinf_vis(varargin)
global handles
global struct_path
global struct_img

global pos_path
global null_path
global neg_path

global pos_thr
global null_thr
global neg_thr

global pos_int
global null_int
global neg_int
     
global resized_pos
global resized_null
global resized_neg

options=struct('start_struct','',...
               'start_pos','',...
               'start_null','',...
               'start_neg','',...
               'start_pos_thresh',[3 27],... 
               'start_null_thresh',[3 27],...
               'start_neg_thresh',[3 27]);      
               
% read the acceptable names
optionNames = fieldnames(options);

% count arguments
if round(nargin/2)~=nargin/2
   error('Incorrect parameters.')
end

for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
   inpName = lower(pair{1}); % make case insensitive
   if any(strcmp(inpName,optionNames))
      % overwrite options. 
      options.(inpName) = pair{2};
   else
      error('%s is not a recognized parameter name',inpName)
   end
end

if isempty(options.('start_struct'))
    struct_path = strcat(fileparts(mfilename('fullpath')),[filesep 'mni152_2009_256.nii']);
else
    struct_path = options.('start_struct');
end
struct_img = spm_read_vols(spm_vol(struct_path));
resized_pos = zeros(size(struct_img));
resized_null = zeros(size(struct_img));
resized_neg = zeros(size(struct_img));


pos_path = options.('start_pos');
null_path = options.('start_null');
neg_path = options.('start_neg');

pos_thr = options.('start_pos_thresh')(1);
null_thr = options.('start_null_thresh')(1);
neg_thr = options.('start_neg_thresh')(1);

pos_int = options.('start_pos_thresh')(2);
null_int = options.('start_null_thresh')(2);
neg_int = options.('start_neg_thresh')(2);


handles.vis_fig = bayinf_figure('GetWin','Graphics');

spm_image('Reset');
spm_orthviews('Interp',0);

%Buttons for selecting images & producing slices
handles.vis_img=uicontrol('units','norm','position',[.0125,.8024, .475,.1856],'style','pushbutton','string','Background Image','FontSize',14,'callback',{@vis_gui,'img'});
handles.vis_pos_ovl=uicontrol('units','norm','position',[.0125,.6048, .475,.1856],'style','pushbutton','string','Positive Overlay','FontSize',14,'callback',{@overlay_gui,'pos'});
handles.vis_null_ovl=uicontrol('units','norm','position',[.0125,.4072, .475,.1856],'style','pushbutton','string','Null Overlay','FontSize',14,'callback',{@overlay_gui,'null'});
handles.vis_neg_ovl=uicontrol('units','norm','position',[.0125,.2096, .475,.1856],'style','pushbutton','string','Negative Overlay','FontSize',14,'callback',{@overlay_gui,'neg'});
handles.vis_sli=uicontrol('units','norm','position',[.0125,.012, .475,.1856],'style','pushbutton','string','Slices','FontSize',14,'callback',{@vis_gui,'sli'});

%Buttons for coordinates & intensity
handles.vis_pos=uicontrol('units','norm','position',[.73,.45, .26,.075],'style','text','string','Position');
handles.vis_mm=uicontrol('units','norm','position',[.73,.365, .06,.075],'style','text','string','mm','fontsize',12);
handles.vis_mm_edit=uicontrol('units','norm','position',[.8,.365, .19,.075],'style','edit','string','','fontsize',12,'callback',{@coordinate_edit_mm});
handles.vis_int=uicontrol('units','norm','position',[.73,.27, .26,.085],'style','text','string','Intensity');
handles.vis_pos=uicontrol('units','norm','position',[.73,.18, .12,.075],'style','text','string','Positive','fontsize',12);
handles.vis_pos_edit=uicontrol('units','norm','position',[.85,.18, .145,.075],'style','edit','string','','fontsize',12);
handles.vis_null=uicontrol('units','norm','position',[.73,.095, .12,.075],'style','text','string','Null','fontsize',12);
handles.vis_null_edit=uicontrol('units','norm','position',[.85,.095, .145,.075],'style','edit','string','','fontsize',12);
handles.vis_neg=uicontrol('units','norm','position',[.73,.01, .12,.075],'style','text','string','Negative','fontsize',12);
handles.vis_neg_edit=uicontrol('units','norm','position',[.85,.01, .145,.075],'style','edit','string','','fontsize',12);

redraw_img(false);

return

%CALLBACK FUNCTIONS
 
%Visualisation GUI
function vis_gui(varargin)
global struct_path
global handles
global struct_img
option = varargin{3};

switch(option)
    case 'img'
		struct_path = spm_select(1,'.nii');
		if isempty(struct_path)
            struct_path = strcat(fileparts(mfilename('fullpath')),[filesep 'mni152_2009_256.nii']);
        end
        struct_img = spm_read_vols(spm_vol(struct_path));
        redraw_img(false);
    case 'sli' 
        if isempty(struct_path),
            warndlg('No working image.');
        else
            handles.sli_fig=figure('units','norm','position',[.425,.45,.17,.1],'name','Create Slice','menubar','none','numbertitle','off','color','w');
            handles.sli_pos=uicontrol('units','norm','position',[.025,.75625, .4675,.21875],'style','text','string','Positions');
            handles.sli_pos_edit=uicontrol('units','norm','position',[.4925,.75625, .4675,.21875],'style','edit','string','52 32 12 -16 -25','callback',{@numeric_edit});

            handles.sli_dir=uicontrol('units','norm','position',[.025,.5125, .4675,.21875],'style','text','string','Direction');
            handles.sli_dir_edit=uicontrol('units','norm','position',[.4925,.5125, .4675,.21875],'style','pop','string',{'Axial', 'Coronal', 'Sagittal'});

            handles.sli_rws=uicontrol('units','norm','position',[.025,.26875, .4675,.21875],'style','text','string','Rows');
            handles.sli_rws_edit=uicontrol('units','norm','position',[.4925,.26875, .4675,.21875],'style','edit','string','1','callback',{@numeric_edit});

            handles.sli_res=uicontrol('units','norm','position',[.025,.025, .94,.21875],'style','pushbutton','string','Create','callback',{@sli_gui});
        end     
end
return

%Slide Generation GUI
function sli_gui(varargin)
global struct_path

global pos_path
global null_path
global neg_path

global pos_int
global null_int
global neg_int

global handles

sli_pos_strings = strsplit(handles.sli_pos_edit.String);
sli_pos_numbers = {};
for i = 1:length(sli_pos_strings)
    sli_pos_numbers = [sli_pos_numbers, str2double(sli_pos_strings(i))];
end
sli_direction = 4 - handles.sli_dir_edit.Value;
sli_rows = str2double(handles.sli_rws_edit.String);

true_columns = max(sli_rows, 1);
true_columns = min(true_columns, length(sli_pos_numbers));
true_rows = ceil(length(sli_pos_numbers) / true_columns);

%size of individual cell
[zero_slice] = create_slice(struct_path, sli_direction, 50, 0, 0, false, false);

sli_width = size(zero_slice, 1);
sli_height = size(zero_slice, 2);

sli_image = zeros(sli_width * true_columns, sli_height * true_rows, 3) + 255;
sli_column = 1;
sli_row = 1;
for i = 1:length(sli_pos_numbers)
    if isempty(pos_path),
        red_path = 0;
    else
        red_path = strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_red.nii']);
    end
    if isempty(null_path),
        green_path = 0;
    else
        green_path = strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_green.nii']);
    end
    if isempty(neg_path),
        blue_path = 0;
    else
        blue_path = strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_blue.nii']);
    end
    temp_sli = slice_with_overlays(struct_path, red_path, green_path, blue_path, pos_int, null_int, neg_int, sli_direction, cell2mat(sli_pos_numbers(i)), false);
    sli_image((sli_column - 1) * sli_width + 1:sli_column * sli_width,(sli_row - 1) * sli_height + 1:sli_row * sli_height,:) = temp_sli;
    sli_row = sli_row + 1;
    if sli_row > true_rows,
        sli_row = 1;
        sli_column = sli_column + 1;
    end
end
sli_image = im2uint8(mat2gray(sli_image));
handles.sli_sli=figure('units','norm','position',[.5 - sli_width * true_columns / 2,.7 - sli_height * true_rows / 2,sli_width * true_columns,sli_height * true_rows],'name','Slice','menubar','none','numbertitle','off','color','k');
handles.sli_sli_img = imshow(sli_image);
handles.sli_sli_cm = uicontextmenu(handles.sli_sli);
handles.sli_sli_save = uimenu(handles.sli_sli_cm,'Label','Save','callback',{@save_slice,sli_image});
set(handles.sli_sli_img, 'uicontextmenu',handles.sli_sli_cm);
return

%Overlay Generation GUI
function overlay_gui(varargin)

global pos_path
global null_path
global neg_path

global pos_thr
global null_thr
global neg_thr

global pos_int
global null_int
global neg_int

global handles

option = varargin{3};
name = '';
switch(option)
    case 'pos'
        path = pos_path;
        thr = pos_thr;
        int = pos_int;
        name = 'Positive Overlay';
    case 'null'
        path = null_path;
        thr = null_thr;
        int = null_int;
        name = 'Null Overlay';
    case 'neg'
        path = neg_path;
        thr = neg_thr;
        int = neg_int;
        name = 'Negative Overlay';
end

handles.overlay_fig=figure('units','norm','position',[.2,.5,.15,.2],'name',name,'menubar','none','numbertitle','off','color','w');
handles.overlay_path=uicontrol('units','norm','position',[.025,.8024, .4675,.1856],'style','pushbutton','string','Path', 'fontsize', 12,'callback',{@overlay_callback,'path',option});

if ~isempty(path)
    handles.overlay_text=uicontrol('units','norm','position',[.4925,.8024, .4675,.1856],'style','text','string',path, 'fontsize', 6,'foregroundcolor','b');
else
    handles.overlay_text=uicontrol('units','norm','position',[.4925,.8024, .4675,.1856],'style','text','string','not selected', 'fontsize', 12,'foregroundcolor','r');
end

handles.overlay_thr=uicontrol('units','norm','position',[.025,.6398, .4675,.1256],'style','text','string','Minimum', 'fontsize', 12);
handles.overlay_thr_edit=uicontrol('units','norm','position',[.4925,.6048, .4675,.1856],'style','edit','string',thr, 'fontsize', 12,'callback',{@numeric_edit});

handles.overlay_int=uicontrol('units','norm','position',[.025,.4372, .4675,.1256],'style','text','string','Maximum', 'fontsize', 12);
handles.overlay_int_edit=uicontrol('units','norm','position',[.4925,.4072, .4675,.1856],'style','edit','string',int, 'fontsize', 12,'callback',{@numeric_edit});

handles.overlay_res=uicontrol('units','norm','position',[.025,.2096, .4675,.1856],'style','pushbutton','string','Reset', 'fontsize', 12,'callback',{@overlay_callback,'res',option});
handles.overlay_save=uicontrol('units','norm','position',[.4925,.2096, .4675,.1856],'style','pushbutton','string','Save', 'fontsize', 12,'callback',{@overlay_callback,'save',option});

handles.overlay_fin=uicontrol('units','norm','position',[.025,.012, .945,.1856],'style','pushbutton','string','Done', 'fontsize', 12,'callback',{@overlay_callback,'gen',option});


return

%Auxiliary functions

%Generation of overlay
function overlay_callback(varargin)

global overlay_path

global pos_path
global null_path
global neg_path

global pos_thr
global null_thr
global neg_thr

global pos_int
global null_int
global neg_int

global handles

option=varargin{3};
mode = varargin{4};

switch(option)
    case 'path'
		overlay_path = spm_select(1);
        if ~isempty(overlay_path)
            handles.overlay_text=uicontrol('units','norm','position',[.4925,.8024, .4675,.1856],'style','text','string',overlay_path, 'fontsize', 6,'foregroundcolor','b');
        else
            handles.overlay_text=uicontrol('units','norm','position',[.4925,.8024, .4675,.1856],'style','text','string','not selected', 'fontsize', 12,'foregroundcolor','r');
        end
    case 'res'
        overlay_path = '';
        thr = 3;
        int = 27;
        handles.overlay_text=uicontrol('units','norm','position',[.4925,.8024, .4675,.1856],'style','text','string','not selected', 'fontsize', 12,'foregroundcolor','r');
        handles.overlay_thr_edit=uicontrol('units','norm','position',[.4925,.6048, .4675,.1856],'style','edit','string',thr, 'fontsize', 12,'callback',{@numeric_edit});
        handles.overlay_int_edit=uicontrol('units','norm','position',[.4925,.4072, .4675,.1856],'style','edit','string',int, 'fontsize', 12,'callback',{@numeric_edit});
    case 'save'
        thr = str2num(get(handles.overlay_thr_edit,'String'));
        temp_path = get(handles.overlay_text,'String');
        if strcmp(temp_path,'not selected')
            temp_path = '';
        end
        if isempty(thr) || isempty(temp_path) 
            warndlg('Wrong input.');
        else    
            [overlay_save_name,overlay_save_path,~] = uiputfile('*.nii','Save overlay','overlay.png');
            thresh(temp_path, thr, strcat(overlay_save_path, overlay_save_name));	
        end
    case 'gen'
        int = str2num(get(handles.overlay_int_edit,'String'));
        thr = str2num(get(handles.overlay_thr_edit,'String'));
        temp_path = get(handles.overlay_text,'String');
        if strcmp(temp_path,'not selected')
            temp_path = '';
        end
        if isempty(thr) || isempty(int) 
            warndlg('Wrong input.');
        else
            switch(mode)
                case 'pos'
                    pos_path = temp_path;
                    pos_int = int;
                    pos_thr = thr;
                case 'null'
                    null_path = temp_path;
                    null_int = int;
                    null_thr = thr;
                case 'neg'
                    neg_path = temp_path;
                    neg_int = int;
                    neg_thr = thr;
            end
            close
            redraw_img(true);
        end
     
end
return

%Saving slice image as png
function save_slice(varargin)
[sli_name,sli_path,sli_file] = uiputfile('*.png','Save slice','slice.png');
imwrite(cell2mat(varargin(3)), strcat(sli_path, sli_name));	
return

%Removing non-numeric data from editboxes that only take in numbers
function numeric_edit(src,~)
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0');
    warndlg('Input must be numerical');
end
return

%Moving the image if the coordinates are changed; for mm and vx respectively
function coordinate_edit_mm(src,~)
str=get(src,'String');
if isempty(str2num(str))
    set(src,'string','0 0 0');
    warndlg('Input must be numerical');
else
    pos = sscanf(str, '%g %g %g');
    if length(pos)~=3
        pos = spm_orthviews('pos',1);
    end
    spm_orthviews('Reposition',pos);
end
return

%3D IMAGE MODIFICATION AND CREATION

%Setting the threshold for overlay, removing insufficiently intense data.
function [new_img, r] = thresh(path, threshold, temp_name)
orig_overlay = spm_vol(path);			
orig_img = spm_read_vols(orig_overlay);

new_img = orig_img;
new_img(orig_img<threshold) = NaN;

orig_overlay.fname = temp_name;  
orig_overlay.private.dat.fname = orig_overlay.fname; 
spm_write_vol(orig_overlay,new_img);

r = spm_vol(temp_name);			
return

%Making a threshold "background"
function r = thresh_background(path, threshold, temp_name)
orig_overlay = spm_vol(path);			
orig_img = spm_read_vols(orig_overlay);
new_img = zeros(size(orig_img));
new_img(orig_img>=threshold) = 1;
orig_overlay.fname = temp_name;  
orig_overlay.private.dat.fname = orig_overlay.fname; 
spm_write_vol(orig_overlay,new_img); 

r = spm_vol(temp_name);			
return
function [new_bottom, new_bottom_background] = clear_thresh_intersections(bottom_path, bottom_background_path, top_backround_path)
bottom_vol = spm_vol(bottom_path);			
bottom_img = spm_read_vols(bottom_vol);

bottom_background_vol = spm_vol(bottom_background_path);			
bottom_background_img = spm_read_vols(bottom_background_vol);

top_background_vol = spm_vol(top_backround_path);			
top_background_img = spm_read_vols(top_background_vol);

bottom_img(top_background_img>0) = NaN;
bottom_background_img(top_background_img>0) = NaN;

new_bottom = spm_write_vol(bottom_vol,bottom_img); 
new_bottom_background = spm_write_vol(bottom_background_vol,bottom_background_img); 
return

%Redrawing the 3D image after changes in overlay, structural image, etc.
function redraw_img(keep_pos)

global st

global pos_path
global null_path
global neg_path

global pos_thr
global null_thr
global neg_thr

global pos_int
global null_int
global neg_int

global pos_img
global null_img
global neg_img

global struct_path
global handles

if keep_pos
    pos = spm_orthviews('pos',1);
    tmp = st.vols{1}.premul*st.vols{1}.mat;
    pos = tmp(1:3,:)*[pos ; 1];
end
spm_orthviews('delete',1);

if ~isempty(struct_path)
    struct_hdr = spm_vol(struct_path);
    struct_hdr = struct_hdr(1);
    handles.vis_result = spm_orthviews('image',struct_hdr, [0.5 -2 .5 5.15], handles.vis_fig);        
    pos_img = zeros([65 77 49]);
    null_img = zeros([65 77 49]);
    neg_img = zeros([65 77 49]);

    
    
    if ~isempty(pos_path)
        pos_background = thresh_background(pos_path,pos_thr,strcat(fileparts(mfilename('fullpath')),[filesep 'background_red.nii']));	%red		
        [pos_img, pos_overlay] = thresh(pos_path,pos_thr,strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_red.nii']));	%red		
        pos_max = max(pos_img(:));
        pos_int_true = max(0, pos_max / pos_int);
        spm_orthviews('AddColouredImage',1,pos_background, [1 0 0]);
        spm_orthviews('AddColouredImage',1,pos_overlay, [pos_int_true pos_int_true 0]);
    else
        pos_img = zeros(size(pos_img));
    end


    if ~isempty(neg_path)
        neg_background = thresh_background(neg_path,neg_thr,strcat(fileparts(mfilename('fullpath')),[filesep 'background_blue.nii']));	%blue		
        [neg_img, neg_overlay] = thresh(neg_path,neg_thr,strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_blue.nii']));	%blue		
        neg_max = max(neg_img(:));
        neg_int_true = max(0, neg_max / neg_int);
        spm_orthviews('AddColouredImage',1,neg_background, [0 0 1]);
        spm_orthviews('AddColouredImage',1,neg_overlay, [0 neg_int_true neg_int_true]);
    else
        neg_img = zeros(size(neg_img));
    end
    

    if ~isempty(null_path)
        null_background = thresh_background(null_path,null_thr,strcat(fileparts(mfilename('fullpath')),[filesep 'background_green.nii']));	%green		
        [null_img, null_overlay] = thresh(null_path,null_thr,strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_green.nii']));	%green
        null_max = max(null_img(:));
        null_int_true = max(0, null_max / null_int);
        if ~isempty(pos_path)
            [null_overlay, null_background] = clear_thresh_intersections(strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_green.nii']), strcat(fileparts(mfilename('fullpath')),[filesep 'background_green.nii']), strcat(fileparts(mfilename('fullpath')),[filesep 'background_red.nii']));
        end    
        if ~isempty(neg_path)
            [null_overlay, null_background] = clear_thresh_intersections(strcat(fileparts(mfilename('fullpath')),[filesep 'overlay_green.nii']), strcat(fileparts(mfilename('fullpath')),[filesep 'background_green.nii']), strcat(fileparts(mfilename('fullpath')),[filesep 'background_blue.nii']));
        end
        spm_orthviews('AddColouredImage',1,null_background, [0 0.5 0]);
        spm_orthviews('AddColouredImage',1,null_overlay, [null_int_true null_int_true 0]);
    else
        null_img = zeros(size(null_img));
    end    
else
    struct_path = strcat(fileparts(mfilename('fullpath')),[filesep 'mni152_2009_256.nii']);
end

st.callback = 'bayinf_coord();';
spm_orthviews('Redraw');
if keep_pos
    spm_orthviews('Reposition',pos);
end
return

%SLICE CREATION
%Creating a slice of a 3D image, scaling it to RL size so that the structural image/mask and overlays would match.

function dist = calculate_dist(path, ori_dist, dim)

switch dim;
case 1
    vox_dist = round(mm2vox([ori_dist 20 20], path));
    vox_dist = vox_dist(1);
case 2
    vox_dist = round(mm2vox([20 ori_dist 20], path));
    vox_dist = vox_dist(2);
case 3
    vox_dist = round(mm2vox([20 20 ori_dist], path));
    vox_dist = vox_dist(3);
otherwise
end

img_vol = spm_vol(path);	
img_matrix= img_vol.mat;

dist = round(vox_dist * img_matrix(dim, dim));
return

function [img_slice, img_size, img_center, img_vis] = create_slice(path, dim, dist, crop_center, crop_size, vis, to_image)


img_vol = spm_vol(path);	
initial_img = spm_read_vols(img_vol);

vox_center = mm2vox([0 0 0], path);

img_matrix= img_vol.mat;
img_matrix(1:3,4) = 0;


img_center = round([vox_center(1) * abs(img_matrix(1,1)) vox_center(2) * abs(img_matrix(2,2)) vox_center(3) * abs(img_matrix(3,3))]);

img_affine = affine3d(img_matrix);
initial_img(isnan(initial_img)) = 0;

initial_img = imwarp(initial_img, img_affine, 'nearest');
img_size = size(initial_img);
img_vis = initial_img;

if crop_size == 0
   crop_size = img_size; 
end


if img_size > crop_size
   img_start = img_center - crop_center;
   initial_img = initial_img(img_start(1):img_start(1) - 1 + crop_size(1),img_start(2):img_start(2) - 1 + crop_size(2),img_start(3):img_start(3) - 1 + crop_size(3));
   
   %disp(img_start);
   %disp(crop_size);
   %disp(img_size);
   
   if isequal(crop_size, size(initial_img))
        %disp('keeping the same')
        img_img = initial_img;
   else
        %disp('expanding')
        img_img = zeros(crop_size);
        img_img(1:size(initial_img,1),1:size(initial_img,2),1:size(initial_img,3)) = initial_img;
    end
elseif img_size < crop_size
   img_img = zeros(crop_size);
   img_start = crop_center - img_center;
   %disp(img_start);
   %disp(crop_size);
   %disp(img_size);
   img_img(img_start(1):img_start(1) - 1 + img_size(1),img_start(2):img_start(2) - 1 + img_size(2),img_start(3):img_start(3) - 1 + img_size(3)) = initial_img;
elseif isequal(img_size, crop_size)
   img_img = initial_img;
else
   %disp('cocc');
   %disp(crop_size);
   %disp(img_size);
   img_img = zeros(crop_size);
   img_start = img_center - crop_center;
   %disp(img_start);
   shrunk_size = [min(crop_size(1), img_size(1)), min(crop_size(2), img_size(3)), min(crop_size(3), img_size(3))];
   %disp(shrunk_size);
   initial_img = initial_img(1:shrunk_size(1), 1:shrunk_size(2), 1:shrunk_size(3));
   %disp(size(initial_img));
   img_img(img_start(1):img_start(1) - 1 + shrunk_size(1),img_start(2):img_start(2) - 1 + shrunk_size(2),img_start(3):img_start(3) - 1 + shrunk_size(3)) = initial_img;

end


if img_matrix(1,1) < 0
    img_img = flip(img_img, 1);
    img_img = flip(img_img, 2);
end
if img_matrix(2,2) < 0
    img_img = flip(img_img, 2);
    img_img = flip(img_img, 3);
end
if img_matrix(3,3) < 0
    img_img = flip(img_img, 1);
    img_img = flip(img_img, 3);
end
dist = abs(dist);
img_pos = size(img_img,dim);
switch dim;
case 1
    img_slice = img_img(dist,:,:);
    img_slice = reshape(img_slice,[size(img_img,2),size(img_img,3)]);
case 2
    img_slice = img_img(:,dist,:);
    img_slice = reshape(img_slice,[size(img_img,1),size(img_img,3)]);
case 3
    img_slice = img_img(:,:,dist);
otherwise
disp('error');
end
img_slice = rot90(img_slice);
if to_image == true,
    img_slice = im2uint8(mat2gray(img_slice));
    if vis == true,
        imwrite(img_slice, strcat(path, '.png'));	
    end 
end
return

%Combining the structural image/mask and various overlays.
function r = slice_with_overlays(path, red, green, blue, pos_int, null_int, neg_int, dim, ori_dist, vis)
global pos_img
global null_img
global neg_img

global pos_thr
global null_thr
global neg_thr


%function [img_slice, img_size, img_center, img_vis] = create_slice(path, dim, dist, center, new_size, vis, to_image)

dist = calculate_dist(path, ori_dist, dim);
[start_slice, start_size, start_center, ~] = create_slice(path, dim, dist, 0, 0, vis, true);

red_sl = start_slice;
blue_sl = start_slice;
green_sl = start_slice;

pos_max = max(0, pos_int);
null_max = max(0, null_int);
neg_max = max(0, neg_int);

%disp(mm2vox([0 0 0], path))
if red ~= 0
    [red_slice, ~] = create_slice(red, dim, dist, start_center, start_size, vis, false);
    red_sl(red_slice>0) = 255;
    green_sl(red_slice>0) = min(255, ((red_slice(red_slice>0) - pos_thr) / (pos_max - pos_thr)) * 255);
    blue_sl(red_slice>0) = 0;
end
if green ~= 0
    [green_slice, ~] = create_slice(green, dim, dist, start_center, start_size, vis, false);
    red_sl(green_slice>0) = min(255, ((green_slice(green_slice>0) - null_thr) / (null_max - null_thr)) * 128);
    green_sl(green_slice>0) = 128 + min(127, ((green_slice(green_slice>0) - null_thr) / (null_max - null_thr)) * 127);
    blue_sl(green_slice>0) = 0;
end
if blue ~= 0
    [blue_slice, ~] = create_slice(blue, dim, dist, start_center, start_size, vis, false);	
    green_sl(blue_slice>0) = min(255, ((blue_slice(blue_slice>0) - neg_thr) / (neg_max - neg_thr)) * 255); 
    red_sl(blue_slice>0) = 0;
    blue_sl(blue_slice>0) = 255;
end   

r = cat(3,red_sl,green_sl,blue_sl);
if vis == true
    imwrite(r, strcat(path, '.overlay.png'));	
end
return


