clc;clear;close all;

I=imread('lena.bmp');
test=4;
switch test
    case 1 %fixed deocomposition level
        level=6;
        Ex=[1:16];
        Ma=8;
        I0=cell(1,16);
        ps=zeros([1,16]);
        se=zeros([1,16]);
        for i=1:16
            I0(i)={jp2quant(I,level,Ex(i),Ma)};
            imshow(cell2mat(I0(i)));drawnow
            ps(i)=psnr(cell2mat(I0(i)),I);
            se(i)=immse(cell2mat(I0(i)),I);
        end
        figure;[hAx,hLine1,hLine2]=plotyy(Ex,ps,Ex,se);
        ylabel(hAx(1),'PSNR(dB)');
        ylabel(hAx(2),'MSE');
        hLine1.Marker = 'o';
        hLine2.Marker = 's';
        legend('PSNR','MSE');
    case 2  %relation for level and exponet, if psnr>40
        level=1:8;
        Ex=zeros([1,8]);
        Ma=8;
        for i=1:8
            for j=1:16
                I0=jp2quant(I,level(i),j,Ma);
                if psnr(I0,I)>40
                    Ex(i)=j;
                    break;
                end
            end
        end
        figure;plot(level,Ex,'-o');grid on;xlabel('level');ylabel('\epsilon');title('Selection of \epsilon for psnr>40');
    case 3  %observe quantization
        level=6;
        Ex=[1:16];
        Ma=8;
        c0=cell(1,17);
        for i=16:-1:1
            c=jp2quant(I,level,Ex(i),Ma,1);
            if i==16
                c0(1)=c(1);
                imagesc(cell2mat(c(1)));caxis([-1 1]);colorbar;colormap(jet);drawnow
            end
            c0(18-i)=c(2);
            imagesc(cell2mat(c(2)));caxis([-1 1]);colorbar;colormap(jet);drawnow;pause
        end
    case 4  %presence of noise using jpeg2000 compression with different compression ratio
        I=imread('lena.bmp');
        Ie=imnoise(I,'gaussian');
        I0=cell([1,29]);
        Ie0=cell([1,29]);
        ps=zeros([1,29]);
        pse=zeros([1,29]);
        cmprt=[1:9,10:10:200];
        for i=1:29
            imwrite(I,'I.jp2','jp2','Mode','Lossy','CompressionRatio',cmprt(i),'ReductionLevels',6);
            imwrite(Ie,'Ie.jp2','jp2','Mode','Lossy','CompressionRatio',cmprt(i),'ReductionLevels',6);
            I0(i)={imread('I.jp2')};
            Ie0(i)={imread('Ie.jp2')};
            ps(i)=psnr(cell2mat(I0(i)),I);
            pse(i)=psnr(cell2mat(Ie0(i)),I);
        end
        figure;plot(cmprt,ps,'-ro',cmprt,pse,'-bx',cmprt,ones([1,29])*psnr(Ie,I),'-k');axis([0,200,15,50]);grid on;
        legend('lossy compression of origin image','lossy compression of noisy image','noisy image');
        xlabel('compression ratio');ylabel('psnr');
        %%%%%%%%%%%%%%%%%
    case 5   %presence of noise using jpeg2000 quantization with different exponent
        level=6;
        Ex=[2:15];
        Ma=8;
        I0=cell(1,14);
        Ie0=cell(1,14);
        Ie=imnoise(I,'gaussian');
        ps=zeros([1,14]);
        pse=zeros([1,14]);
        for i=1:14
            I0(i)={jp2quant(I,level,Ex(i),Ma)};
            Ie0(i)={jp2quant(Ie,level,Ex(i),Ma)};
            ps(i)=psnr(cell2mat(I0(i)),I);
            pse(i)=psnr(cell2mat(Ie0(i)),I);
        end
        figure;plot(Ex,ps,'-ro',Ex,pse,'-bx',Ex,ones([1,14])*psnr(Ie,I),'-k');grid on;
        legend('quantization of origin image','quantization of noisy image','noisy image');
        xlabel('\epsilon');ylabel('psnr');
        
end



%generate gif
% nImages=16;
% figure;
% for idx = 1:nImages
%     imagesc(cell2mat(c0(idx)));caxis([-1 1]);colorbar;colormap(jet);
%     if idx==1
%         title(['lena, wavelet transform']);
%     else
%         title(['quantizer,level=6,\mu=8,\epsilon=',num2str(18-idx)]);
%     end
%     drawnow;
%     frame = getframe(1);
%     im{idx} = frame2im(frame);
% end
% close;
% figure;
% for idx = 1:nImages
%     subplot(1,nImages,idx)
%     imshow(im{idx});
% end
% filename = 'lena_quant_obs.gif';
% for idx = 1:nImages
%     [A,map] = rgb2ind(im{idx},256);
%     if idx == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
%     end
% end

