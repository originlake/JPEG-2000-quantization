function [Io]=jp2quant(I,level,Ex,Ma,method)
%JPEG 2000 lossy compression quantizer 
%
%Accept I for input image, mtd for methods of wavelet transform, mtd=1
%using FWT, mtd=2 using lifting-based implementation, default is 1, 
%and level for transform level, default is 1, Ex as exponet and Ma as
%mantissa, default is 8. Note that 0<=Ex<=2e5, 0<=Ma<=2e11
%method=0, apply quantizer and dequantizer, output reconstructed image
%method=1, apply quantizer, outout coefficients and quantized coefficients
%method=2, apply dequantizer, output reconstructed image
%Using Pascal Getreuer's waveletcdf97.m for CDF9/7 wavelet transform
%
%Shuo Zhong
%11/26/2017
if nargin<1, I=imread('../image/lena.bmp'); end
if nargin<2, level=6; end
if nargin<3, Ex=11; Ma=8; end
if nargin<5, method=0; end
if ndims(I) > 3
    error('Input must be a 2D or 3D array.'); 
end

if ndims(I)==3
    I=rgb2ycbcr(I);
    f=I(:,:,1);
else
    f=I;
end

if method==0
    f=double(f)-128; %DC level shifting
    y=waveletcdf97(f,level);
    %quantizer
    c=quant(y,Ex,Ma,level);
    %dequantizer
    y=dequant(c,Ex,Ma,level);
    f=waveletcdf97(y,-level);
    Io=uint8(f+128);
end
if method==1
    f=double(f)-128; %DC level shifting
    y=waveletcdf97(f,level);
    %quantizer
    c=quant(y,Ex,Ma,level);
    Io={y,c};
end
if method==2
    y=dequant(I,Ex,Ma,level);
    f=waveletcdf97(y,-level);
    Io=uint8(f+128);
end
% figure;imshow(I);
% figure;imshow(Io);
% disp('mse:');
% immse(I,Io)
% disp('psnr:');
% psnr(Io,I)
% 
% p=NaN;
end

function y=quant(x,Ex,Ma,l)
R=8; %bit depth
G=1; %guard bits
Rb=R+[0,1,2]; %nominal dynamic range, Rb(1) for LL, Rb(2) for LH, HL, Rb(3) for HH
% step=2.^(Rb-Ex).*(1+Ma/2e11);
[sx sy]=size(x);
%%from level NL to level 1
for i=l:-1:1
    tempex=Ex+i-l;  %derived exponet
    step=2.^(Rb-tempex).*(1+Ma/2e11);   %step size
    if i==l
        temp1=x(1:(sx/(2^l)),1:(sy/(2^l)));
        temp1=sign(temp1).*floor(abs(temp1)./step(1));
    end
    temp2=x(1:sx/(2^i),sy/(2^i)+1:(sy/(2^(i-1))));
    temp3=x(sx/(2^i)+1:(sx/(2^(i-1))),1:sy/(2^i));
    temp4=x(sx/(2^i)+1:(sx/(2^(i-1))),sy/(2^i)+1:(sy/(2^(i-1))));
    temp2=sign(temp2).*floor(abs(temp2)./step(2));
    temp3=sign(temp3).*floor(abs(temp3)./step(2));
    temp4=sign(temp4).*floor(abs(temp4)./step(3));
%%     keep coefficients in range
%     for j=['2' '3' '4']
%         eval(['temp',j,'(temp',j,'>(2^(G+tempex-1)-1))=2^(G+tempex-1)-1;']);
%         eval(['temp',j,'(temp',j,'<-2^(G+tempex-1))=-2^(G+tempex-1);']);
%     end
    temp1=[temp1,temp2;temp3,temp4];
end
y=temp1;
end

function y=dequant(x,Ex,Ma,l)
R=8; %bit depth
Rb=R+[0,1,2]; %nominal dynamic range, Rb(1) for LL, Rb(2) for LH, HL, Rb(3) for HH

% step=2.^(Rb-Ex).*(1+Ma/2e11);
[sx sy]=size(x);

for i=l:-1:1
    tempex=Ex+i-l;
    step=2.^(Rb-tempex).*(1+Ma/2e11);
    if i==l
        temp1=x(1:(sx/(2^l)),1:(sy/(2^l)));
        temp1=sign(temp1).*(abs(temp1)+1/2).*step(1);
    end
    temp2=x(1:sx/(2^i),sy/(2^i)+1:(sy/(2^(i-1))));
    temp3=x(sx/(2^i)+1:(sx/(2^(i-1))),1:sy/(2^i));
    temp4=x(sx/(2^i)+1:(sx/(2^(i-1))),sy/(2^i)+1:(sy/(2^(i-1))));
    temp2=sign(temp2).*(abs(temp2)+1/2).*step(2);
    temp3=sign(temp3).*(abs(temp3)+1/2).*step(2);
    temp4=sign(temp4).*(abs(temp4)+1/2).*step(3);
    temp1=[temp1,temp2;temp3,temp4];
end
y=temp1;
end











