function varargout = deteksi_logo(varargin)
% DETEKSI_LOGO MATLAB code for deteksi_logo.fig
%      DETEKSI_LOGO, by itself, creates a new DETEKSI_LOGO or raises the existing
%      singleton*.
%
%      H = DETEKSI_LOGO returns the handle to a new DETEKSI_LOGO or the handle to
%      the existing singleton*.
%
%      DETEKSI_LOGO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETEKSI_LOGO.M with the given input arguments.
%
%      DETEKSI_LOGO('Property','Value',...) creates a new DETEKSI_LOGO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before deteksi_logo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to deteksi_logo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help deteksi_logo

% Last Modified by GUIDE v2.5 06-Jun-2023 13:17:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @deteksi_logo_OpeningFcn, ...
                   'gui_OutputFcn',  @deteksi_logo_OutputFcn, ...
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


% --- Executes just before deteksi_logo is made visible.
function deteksi_logo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to deteksi_logo (see VARARGIN)

% Choose default command line output for deteksi_logo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes deteksi_logo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = deteksi_logo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[rawname, rawpath] = uigetfile({'*.Jpg'}, 'Select Image Data');
fullname = [rawpath rawname];

im = imread(fullname);
ukuran = [512,910];
image = imresize(im, ukuran);

% Inversi citra
image=imcomplement(image);

% Konversi ke skala abu-abu
image = rgb2gray(image);
image = medfilt2(image);

% Menentukan ambang batas (threshold)
thres = graythresh(image);

% membuat gambar baru dengan citra biner
image_baru = imbinarize(image,thres);

%---------------------------------------
%menghilangkan noise dan melakukan dilasi
image_baru = bwareaopen(image_baru,100);
square=strel('square',30);
image_dilasi=imdilate(image_baru,square);

%---------------------------------------
% Hitung gradien citra
dx = [-1 0 1; -1 0 1; -1 0 1];
dy = dx';
Ix = conv2(double(image_dilasi), dx, 'same');
Iy = conv2(double(image_dilasi), dy, 'same');

% Hitung matriks struktur Harris
windowSize = 3; % Ukuran jendela
sigma = 0.5; % Variansi Gaussian
k = 0.07; % Faktor responsivitas Harris 0.04
Ix2 = conv2(Ix .^ 2, fspecial('gaussian', windowSize, sigma), 'same');
Iy2 = conv2(Iy .^ 2, fspecial('gaussian', windowSize, sigma), 'same');
Ixy = conv2(Ix .* Iy, fspecial('gaussian', windowSize, sigma), 'same');
R = (Ix2 .* Iy2 - Ixy .^ 2) - k * (Ix2 + Iy2) .^ 2;

% Ambang batas respons Harris
threshold = 0.01 * max(R(:));

% Cari piksel sudut
corners = R > threshold;

total_sudut = sum(corners(:));

if total_sudut < 100
    aax='Mobil MITSUBISI terlihat';
elseif total_sudut > 100 && total_sudut < 150 
    aax='Mobil SUZUKI terlihat';
else
    aax='Mobil TOYOTA terlihat';
end

set(handles.edit1, 'String', fullname);
set(handles.text2, 'String', aax);
axis(handles.axes1);
imagesc(image_dilasi);
hold on;

% Tandai sudut dengan lingkaran merah
[row, col] = find(corners);
plot(col, row, 'ro');

% Plot dengan latar belakang transparan
% hPlot = plot(col, row, 'ro');
% hPlot.Parent.Color = 'none'; % Menghilangkan warna latar belakang
% hPlot.Parent.Color = 'none'; % Menghilangkan warna latar belakang
% hPlot.Parent.Box = 'off'; % Menghilangkan kotak batas
hold off;



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
