%Input the image
HighImage = double(imread('great.png'));
LowImage = double(imread('tiger.png'));

%Set the number of layers
iternum = 6;

[rows, cols, channels] = size(HighImage);

% Create he Gaussian and Laplacian pyramid
high_laplacian_pyramid = laplacianPyramid(HighImage, iternum);
low_laplacian_pyramid = laplacianPyramid(LowImage, iternum);
high_gaussian_pyramid = gaussianPyramid(HighImage, iternum);
low_gaussian_pyramid = gaussianPyramid(LowImage,iternum);

%%
%Gaussian pyramid

figure;

for i = 1:iternum
    
    subplot(2,iternum,i);
    imshow(uint8(low_gaussian_pyramid{i}))
    title('The '+string(i)+' layer');
    subplot(2,iternum,i+iternum)
    imshow(uint8(high_gaussian_pyramid{i}))
    title('The '+string(i)+' layer');
    
end
%%
%Laplacian pyramid

figure;
gamma = 0.8;
for i = 1:iternum
    
    subplot(2,iternum,i);
    imshow(imadjust(uint8(low_laplacian_pyramid{i}),[],[],gamma)+64)
    title('The '+string(i)+' layer');
    subplot(2,iternum,i+iternum)
    imshow(imadjust(uint8(high_laplacian_pyramid{i}),[],[],gamma)+64)
    title('The '+string(i)+' layer');
    
end

%%
% Hybrid image

cut_frequency = 4;

% high-pass pyramid and low-pass pyramid
high_pyramid = laplacianPyramid(HighImage, iternum);
low_pyramid = laplacianPyramid(LowImage, iternum);

% TODO: get blend laplacian pyramid
blend_pyramid = cell(iternum, 1);
for i = 1:cut_frequency
    blend_pyramid{i} = high_pyramid{i};
end

for i = cut_frequency+1:iternum
    blend_pyramid{i} = low_pyramid{i};
end

blendImage = LaplacianReconstruct(blend_pyramid);
blendImage = uint8(blendImage);
vis = vis_hybrid_image(blendImage);
figure;
subplot(2,2,1);imshow(uint8(HighImage));title('High f original Image');
subplot(2,2,2);imshow(uint8(LowImage));title('Low f original Image');
subplot(2,2,3);imshow(vis);title('HybridImage');
imwrite(vis, 'hybrid_image_2.jpg', 'quality', 95);
%%
%Pyramid blending

% Create the mask
mask = double(zeros(rows, cols, channels));
mask(:, 1:floor(cols/2), :) = ones(rows, floor(cols/2), channels);
mask_pyramid = gaussianPyramid(mask, iternum);

blend_pyramid = cell(iternum, 1);
for i = 1:iternum
    blend_pyramid{i} = high_laplacian_pyramid{i} .* mask_pyramid{i} + low_laplacian_pyramid{i} .* (1 - mask_pyramid{i});
end

% reconstruct the blend image
blendImage = LaplacianReconstruct(blend_pyramid);
imwrite(uint8(blendImage), 'blendImage.png');

figure;
subplot(1,3,1);imshow(uint8(HighImage));title('LeftImage');
subplot(1,3,2);imshow(uint8(LowImage));title('RightImage');
subplot(1,3,3);imshow('blendImage.png');title('BlendImage');
%%
%Region blending

mask1 = double(imread("mask.png"));
mask1 = im2gray(mask1);
mask1 = imbinarize(mask1);
mask_pyramid = gaussianPyramid(mask1, iternum);


% leftImage pyramid and rightImage pyramid
left_pyramid = laplacianPyramid(HighImage, iternum);
right_pyramid = laplacianPyramid(LowImage, iternum);

% TODO: get blend laplacian pyramid
blend_pyramid = cell(iternum, 1);
for i = 1:iternum
    blend_pyramid{i} = left_pyramid{i} .* mask_pyramid{i} + right_pyramid{i} .* (1 - mask_pyramid{i});
end

blendImage = LaplacianReconstruct(blend_pyramid);
imwrite(uint8(blendImage), 'region_blendImage.png');

figure;
subplot(1,4,1);imshow(mask1);title('MaskImage');
subplot(1,4,2);imshow(uint8(HighImage));title('RegionImage');
subplot(1,4,3);imshow(uint8(LowImage));title('BackgroundImage');
subplot(1,4,4);imshow('region_blendImage.png');title('RegionBlendImage');