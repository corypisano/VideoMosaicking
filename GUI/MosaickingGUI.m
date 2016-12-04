function varargout = MosaickingGUI(varargin)
% MOSAICKINGGUI MATLAB code for MosaickingGUI.fig
%      MOSAICKINGGUI, by itself, creates a new MOSAICKINGGUI or raises the existing
%      singleton*.
%
%      H = MOSAICKINGGUI returns the handle to a new MOSAICKINGGUI or the handle to
%      the existing singleton*.
%
%      MOSAICKINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOSAICKINGGUI.M with the given input arguments.
%
%      MOSAICKINGGUI('Property','Value',...) creates a new MOSAICKINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MosaickingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MosaickingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MosaickingGUI

% Last Modified by GUIDE v2.5 03-Dec-2016 17:35:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MosaickingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MosaickingGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MosaickingGUI is made visible.
function MosaickingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MosaickingGUI (see VARARGIN)

% Choose default command line output for MosaickingGUI
handles.output = hObject;

resetGUI(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MosaickingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MosaickingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

% read "Set Maximum Frame Resolution" check box
maxResToggleState = get(hObject, 'Value');

% enable/disable max resolution input field
if maxResToggleState < 1
    handles.edit1.Enable = 'off';
else
    handles.edit1.Enable = 'on';
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dirName = uigetdir('C:\Users\cory\OneDrive\Documents\MATLAB\VideoMosaicking\SequenceData\', ...
    'Choose image directory');

handles.text4.String = dirName;
try
    imds = imageDatastore(dirName);
catch
    errordlg('No image frames found');
    return;
end
% save for popping out the montage
handles.imgDataStore = imds;

% verify atleast one frame, display in edit4
handles.numFrames = length(imds.Files);
handles.edit4.String = num2str(handles.numFrames);

% populate GUI with image info
imgInfo = imfinfo(imds.Files{1})
%imgInfo.Filename
%imgInfo.Width
%imgInfo.Height
%imgInfo.BitDepth
%imgInfo.Format

% Display images to be stitched
try
    axes(handles.axes1);
    montage(imds.Files)
catch
    errordlg('Invalid Image Frames - must be same size');
    return;
end
    


guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear all; 

allPlots = findall(0, 'Type', 'figure', 'FileName', []);
delete(allPlots);

clc


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    imds = handles.imgDataStore;
catch
    errordlg('Invalid Image Directory!');
    return;
end
figure();
montage(imds.Files)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    panorama = handles.panorama;
catch
    errordlg('Panorama not created yet!');
    return;
end
figure();
imshow(panorama);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

status = validateInputFields(hObject, eventdata, handles);
if status == 0
    return;
end

assignValidatedInputs(hObject, eventdata, handles);

% run!

% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10

% Planar projection selected

% disable the focal length edit text field
handles.edit2.Enable = 'off';


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11

% Cylindrical projection selected

% enable the focal length edit text field
handles.edit2.Enable = 'on';



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7

% BLENDING METHOD: 
% Linear feathering selection 

% enable the window length edit field
handles.edit3.Enable = 'on';


% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8

% BLENDING METHOD: 
% Vision Alpha Blender selection 

% disable the window length edit field
handles.edit3.Enable = 'off';


% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9

% BLENDING METHOD: 
% Laplacian Pyramid selection 

% disable the window length edit field
handles.edit3.Enable = 'off';

function resetGUI(hObject, eventdata, handles)

% GUI variables
handles.imgDataStore = [];
handles.panorama = [];
handles.numFrames = 0;

% directory string
handles.text4.String = 'No directory chosen';

% clear input montage axes
axes(handles.axes1)
imshow([0 0 0 0; 0 0 0 0])

% clear output mosaic axes
axes(handles.axes2)
imshow([0 0 0 0; 0 0 0 0])

% clear number of frames
handles.edit4.String = '0';

% clear projection panel
handles.radiobutton10.Value = 1.0;
handles.edit2.String = '700';
handles.edit2.Enable = 'off';

% clear blending panel
handles.radiobutton7.Value = 1.0;
handles.edit3.String = '32';
handles.edit3.Enable = 'on';

% clear feature detection panel
handles.radiobutton5.Value = 1.0;

% clear panorama options
handles.checkbox2.Value = 0.0;
handles.edit1.Enable = 'off';
handles.edit1.String = '1080';
handles.popupmenu1.Value = 1.0;


function status = validateInputFields(hObject, eventdata, handles)

% only set status to 1 if everything passes
% return early if any input is invalid
status = 0;

% image input valid
if isempty('handles.imgDataStore')
    errordlg('Invalid Image Frame Directory');
    return;
end

% focal length
if handles.radiobutton11.Value == 1
    
    focalLength = num2str(handles.edit2.String)
    if ~(isnum(focalLength) && focalLength > 0 && focalLength < 3000)
        errordlg('Invalid Focal Length');
        return;
    end
end
    
    
status = 1;



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resetGUI(hObject, eventdata, handles);

function assignValidatedInputs(hObject, eventdata, handles)

% projection method
handles.projectionMethod = handles.uibuttongroup2.SelectedObject.String;
if strcmp(handles.projectionMethod, 'Cylindrical')
    handles.focalLength = num2str(handles.edit2.String);
end

% feature detection method
handles.featureDetector = handles.uibuttongroup1.SelectedObject.String;

% blending method
handles.blendingMethod = handles.uibuttongroup3.SelectedObject.String;

handles.warpToCenter = handles.checkbox1.Value;
handles.useMaxResolution = handles.checkbox2.Value;
if handles.useMaxResolution
    handles.maxResolution = str2num(handles.edit1.String);
end

% 0 -> none, 1-> 1, 2-> all
handles.showMatchedFeatures = handles.popupmenu1.Value;
