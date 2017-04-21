clc;
%% Read from text file 
%  out = vidsample('VID0002.AVI');


%%
path = '/Users/caitycallahan/Documents/EC520-Digital Image Processing/Ghana/3_examples/RectPosition.txt';
posFile = fopen(path);
% for i = 1:feof(posFile)
[filename,M,D,Y,xmin,ymin,width,height] = textread(path,...
                                            '%s %d %d %d %d %d %d %d',6);
 %%                                       
% end
% xmin,ymin are top left corner of imrect, width and height descripe size
% of rectangle

% Set up rectangle position
%pos = [xmin, ymin, width, height];

% Read in background and video files
backgroundFiles = dir('/Volumes/MyPassportforMac/BACKGROUNDS/*.png');
videoFiles = dir('/Volumes/MyPassportforMac/hd1/Agona Nkran Islamic/Baseline/Video/Video 1/*.AVI');

% Select Videos
%v = VideoReader(filename{1});       % name of school = filename{1}
concatDay = strsplit(filename{1},{'_','.avi'});

%for D = concatDay{end-1} && M = concatDay{end-2}
% strsplit the date of videos -- videoFiles.date
% for i = 1:length(videoFiles)
%    if D == (concatDay{end-1})
%     videosForDay(i) = string(videoFiles.name);
%    else
%        videosForDay(i) = 0;
%    end
% end

%v = VideoReader(videoFiles);
v = VideoReader('/Volumes/MyPassportforMac/hd1/Agona Nkran Islamic/Baseline/Video/Video 1/VID0218.AVI');
% Select Background Image
background = im2double(imread('/Users/caitycallahan/Documents/EC520-Digital Image Processing/Ghana/BACKGROUNDS/Agona_Nkran_Islamic_feb_10.png'));


vout = VideoWriter('subtractedThreshVID0218.AVI');     %VID0216, VID0223

vout.open()
n=1;
 while v.hasFrame
    
    frame = im2double(readFrame(v));
    backframe = background;
    
    framecrop = (frame([ymin(6) : 1 : ymin(6)+height(6)-1],...
            [xmin(6) : 1 : xmin(6)+width(6) +1],:));
    backcrop = (backframe([ymin(6) : 1 : ymin(6)+height(6)-1],...
            [xmin(6) : 1 : xmin(6)+width(6) +1],:));
    
    frameGray = rgb2gray(framecrop);
    backGray = rgb2gray(backcrop);
%     
%     framecropLevel = graythresh(frameGray);
%     backcropLevel = graythresh(backGray);
%     
%     BWframe = imbinarize(frameGray, framecropLevel);
%     BWback = imbinarize(backGray, backcropLevel);
    
     subtract = abs(frameGray - backGray);
     
     % Threshold 1
     % 0.5 too high
     T = 0.25;
     subtract(subtract < T) = 0;
     subtract(subtract > T) = 1;
    
    %BWsubtract = abs(BWframe - BWback);
    vout.writeVideo(subtract);
    
    numberOfWhitePixels(n) = double(sum(sum(subtract)));
    
%     decision = zeros(length(v));
%         if numberOfWhitePixels > 600
%             decision(n) = [1];      
%         
%         end
   
    n=n+1;
%     numberOfWhitePixels = 0;
%     figure(1)
%     subplot(2,2,1)
%     imshow(framecrop)
%     subplot(2,2,2)
%     imshow(backcrop)
%     subplot(2,2,3)
%     imshow(subtract)
   
 end
 vout.close(); 
 
 numberOfWhitePixels(numberOfWhitePixels < 800) = 0;
 numberOfWhitePixels(numberOfWhitePixels >= 800) = 1;
 %%
figure(1)
plot(numberOfWhitePixels,'Linewidth',3)
ylim([0 1.1])
title('Agona Nkran Islamic Feb 10, VID0218, Threshold = 800')
xlabel('Frames')
set(gca,'fontsize',13)
 
 %%
%  v2 = VideoReader('subtractedHandThresh0.3.AVI');
%  
% nFrames = floor(v2.FrameRate*v2.Duration); %% v2.NumberOfFrames;
% vidHeight = v2.Height; % v2.Height;
% vidWidth = v2.Width; % v2.Width;
% 
% %// Read one frame at a time.
% for k = 1 :v2.NumberOfFrame
%     %IMG = read(v2, (k));
%     IMG = read(v2, (k-1)*30+1);
% 
%     %IMG = v2.readFrame(num2str(k));
%     numberOfWhitePixels = sum(sum(IMG));
%     decision = zeros(length(v2));
%         if numberOfWhitePixels > 5
%             decision(k) = 1;
%             
%         else 
%             decision(k) = 0;
%         end
%     numberOfWhitePixels = 0;
% end
%  
%  %%
%   v2 = VideoReader('subtractedHandThresh0.3.AVI');
% 
%  % Threshold 2
%  N = 1;
%  decision = zeros(length(v2));
%  while v2.hasFrame
%     F = readFrame(v2);     
%     numberOfWhitePixels = sum(sum(F));
%      
%      %for i = 1:(v2.FrameRate*v2.Duration) 
%         %v2.CurrentTime = i/v2.Duration;        
%         
%         if numberOfWhitePixels > 2
%             %decision(i) = 1;
%             decision(N) = 1;
%         else 
%             %decision(i) = 0;
%             decision(N) = 0;
%         end
%         N = N+1;
%      %end
%  end
%  % implay(vout)
% figure(1)
% stem(decision)
%  
