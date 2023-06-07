clear; close all; clc;

% Baca citra dan merisize nya
image = imread('mobil/t1.jpg');
ukuran = [512,910];
image = imresize(image, ukuran);

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

%mengisi lubang dan melakukan erosi
% image_baru = imfill(image_baru, 'holes');
% disk=strel('disk',10);
% image_erosi = imerode(image_baru, disk);
% figure;imshow(image_erosi);

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

figure;
imshow(image_dilasi);
hold on;

% Tandai sudut dengan lingkaran merah
[row, col] = find(corners);
plot(col, row, 'ro');

total_sudut = sum(corners(:));

if total_sudut < 100
    aax='mitsubisi';
elseif total_sudut > 100 && total_sudut < 150 
    aax='suzuki';
else
    aax='toyota';
end

hold off;
title(aax);
