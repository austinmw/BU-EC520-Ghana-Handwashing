clc; clear all;
tic
%%
ROIpath = '/Volumes/MyPassportforMac/SAMPLING_DIR/COMBINED_SUBSAMPLES/ROI_data.txt';
%ROIpath = '/project/vipcnns/Ghana-Project/SAMPLING_DIR/COMBINED_SUBSAMPLES/ROI_data.txt';
posFile = fopen(ROIpath);
% Read in concatenated video filename, extenstion, Date, and Rectangle  
% Position from Text File.
% xmin,ymin are top left corner of imrect, width and height descripe size
% of rectangle
[filename,ext,xmin,ymin,width,height] = textread(ROIpath,...
                                            '%[^.] %s %d %d %d %d');
                                        % '%[^.] read until first occurence of '.'                                      

% For Every Line in the Rectangle Position text file, get school name and 
% date. Then get corresponding background image and videos. Crop both the
% backroud image and every frame of the videos and convert to luminance.
% Subtract, threshold, and count number of white pixels in every video
% frame.

for i = 1   %:length(filename)   % lines in text file   
    % Will parse line from Rectangle Position text file and set up school
    % and date variables. 
    splitSchoolandDate = strsplit(filename{i},{'_'});   %filename{i}
    school = splitSchoolandDate(1);      % maybe need string(split(1))
    date = strcat(splitSchoolandDate(2), '_',splitSchoolandDate(3));
    
    % Set up rectangle position
    pos = [xmin(i), ymin(i), width(i), height(i)];      % will be i's in for loop
    
    % Select Background Image    
    backgroundImage = imread(char(strcat('/Volumes/MyPassportforMac/SAMPLING_DIR/COMBINED_SUBSAMPLES/Saved_Frames/',school,'_', date,'.png')));
    background = (backgroundImage);    %im2double
    
    % Set up background for school and date -- constant for whole day
    %backframe = background;
    backcrop = (background([ymin(i) : 1 : ymin(i)+height(i)-1],...
                [xmin(i) : 1 : xmin(i)+width(i) +1],:));
    fullBackGray  = rgb2gray(backcrop);
    leftBackGray  = fullBackGray(1:end, 1:end/2);
    rightBackGray = fullBackGray(1:end, (end/2)+1:end);
   
    % Read in video files for specific school and date
    videoFiles = char(strcat('/Volumes/MyPassportforMac/SAMPLING_DIR/_DATES_DIRS/',school,'/', date,'/*.avi'));
    videoDirectory = struct2cell(dir(videoFiles));
    vidnames = videoDirectory(1,:);
    
    % If date file is empty:
    if isempty(vidnames) == 1
        resultFile = fopen('/Volumes/MyPassportforMac/Washing_Results.txt','at');
        fprintf(resultFile,'There are no videos for %s on %s. \n ',[string(school), string(date)]);
        fclose(resultFile);
    end
    
    for n = 4       %:length(vidnames)  % for every video file in a specific date
            
        % Select 30 sec Video
        v = VideoReader(vidnames{n});
        % ADD IN CROSS CHECK WITH GOOD FILE LIST TO AVOID DAMAGED VIDEOS 
        
        
% AVERAGE CURRENT VIDEO AND OBTAIN TRIANGLE THRESHOLD
%         Nframes = v.NumberOfFrames; Nheight = v.Height; Mwidth = v.Width;
%         videoFrame = zeros(Nheight,Mwidth,3,'single');
%         videoFrameAvg = zeros(Nheight,Mwidth,3,'single');      
%         for k = 1:Nframes
%             videoFrame = read(v,k);
%             videoFrameAvg = videoFrameAvg + single(videoFrame);
%         end   
%         close
%         
%         % Average Frame for Video
%         videoFrameAvg = videoFrameAvg/Nframes;
%         avgcrop = (videoFrameAvg([ymin(i) : 1 : ymin(i)+height(i)-1],...
%                     [xmin(i) : 1 : xmin(i)+width(i) +1],:));
%         fullAvgGray = rgb2gray(avgcrop);
%         leftAvgGray  = fullAvgGray(1:end, 1:end/2);
%         rightAvgGray = fullAvgGray(1:end, (end/2)+1:end);
% 
%         full_difference = abs(fullAvgGray - fullBackGray);
%         full_difference_hist = imhist(full_difference);
%         
%         left_difference  = full_difference(1:end, 1:end/2);
%         left_difference_hist = imhist(left_difference);
%         
%         right_difference = full_difference(1:end, (end/2)+1:end);
%         right_difference_hist = imhist(right_difference);
        
        
% COMPUTE TRIANGLE THRESHOLD FOR VIDEO
%         [full_TriangleThresh]  = triangle_th(full_difference_hist,256);
%         [left_TriangleThresh]  = triangle_th(left_difference_hist,256);
%         [right_TriangleThresh] = triangle_th(right_difference_hist,256);
%         
%         % need this??
%         full_avgVid_Thresh  = im2bw(full_difference,full_TriangleThresh);
%         left_avgVid_Thresh  = im2bw(left_difference,left_TriangleThresh);
%         right_avgVid_Thresh = im2bw(right_difference,right_TriangleThresh);
       
% BEGIN SUBTRACTION AND THRESHOLDING        
        v = VideoReader(vidnames{n});
        count=1;
        while v.hasFrame
            % set current frame and background frame.
            frame = (readFrame(v));         
            framecrop = (frame([ymin(i) : 1 : ymin(i)+height(i)-1],...
                        [xmin(i) : 1 : xmin(i)+width(i) +1],:));       
            frameGray  = rgb2gray(framecrop);          

% HSV MATRIX CREATION
            % HSV - want to ignore luminance values of 0 and 92-255 to try
            % to minimize interference of wooden bar. Skin color should be
            % roughly between 0 and 92.
            % Will also lower the number of white pixels in the image
            % Since frame is double, will ignore 0 and (92/255)- (255/255)
            % 92/255 = 0.3608
                HSVmatrix = frameGray;      % will be 0s and 1s
                %HSVmatrix(HSVmatrix < 0.3608) = 1;
                HSVmatrix(HSVmatrix > 92) = 0;
                HSVmatrix(HSVmatrix ~= 0) = 1;
                
            % does same as above ??
            % HSVmatrix = imbinarize(frameGray,0.3608);
            subtract   = abs(frameGray - fullBackGray) .* HSVmatrix;
            initialSub = subtract;
            
% SPLIT SUBTRACT ROI INTO LEFT AND RIGHT SECTIONS
            fullROI  = subtract;
            leftROI  = subtract(1:end, 1:end/2);
            rightROI = subtract(1:end, (end/2)+1:end);
            
% THRESHOLD 1 - TRIANGLE THRESHOLD          
%             fullROI(fullROI < full_TriangleThresh) = 0;
%             fullROI(fullROI > full_TriangleThresh) = 1;
%             
%             leftROI(leftROI < left_TriangleThresh) = 0;
%             leftROI(leftROI > left_TriangleThresh) = 1;
%             
%             rightROI(rightROI < right_TriangleThresh) = 0;
%             rightROI(rightROI > right_TriangleThresh) = 1;
            
            full_Thresh = graythresh(fullROI);
            fullROI(fullROI < full_Thresh) = 0;
            fullROI(fullROI > full_Thresh) = 1;
            
            left_Thresh = graythresh(leftROI);
            leftROI(leftROI < left_Thresh) = 0;
            leftROI(leftROI > left_Thresh) = 1;
            
            right_Thresh = graythresh(rightROI);
            rightROI(rightROI < right_Thresh) = 0;
            rightROI(rightROI > right_Thresh) = 1;
           
%             fullROI = imbinarize(fullROI,full_TriangleThresh);
%             leftROI = imbinarize(leftROI,left_TriangleThresh);
%             rightROI = imbinarize(rightROI,right_TriangleThresh);
                       
% COUNT NUMBER OF WHITE PIXELS IN ROI
            numberOfWhitePixelsLEFT(count)  = double(sum(sum(leftROI)));
            numberOfWhitePixelsRIGHT(count) = double(sum(sum(rightROI)));
            numberOfWhitePixelsFULL(count) = double(sum(sum(fullROI)));
            count=count+1;                    
        end
        
        % for testing
        % NWP_FULL  = numberOfWhitePixelsFULL;
        % NWP_LEFT  = numberOfWhitePixelsLEFT;
        % NWP_RIGHT = numberOfWhitePixelsRIGHT;
        
        
        % HISTORGRAMS
%         histogramPath = char(strcat('/Volumes/MyPassportforMac/WhitePixelNoThreshHist/','Histogram','_',school,'_', date,'_',vidnames{n},'.png'));
%         subplot(3,1,1)
%         histogram(numberOfWhitePixelsFULL)
%         title((strcat(school,date,vidnames{n},' Histogram')))
%         subplot(3,1,2)
%         histogram((numberOfWhitePixelsLEFT/max(numberOfWhitePixelsLEFT)).*100)
%         title('Number of White Pixels Left')
%         subplot(3,1,3)
%         histogram((numberOfWhitePixelsRIGHT/max(numberOfWhitePixelsRIGHT)).*100)
%         title('Number of White Pixels Right')
%         xlabel('Pixels')
%         %xlim([0 4000])
%         %set(gca,'fontsize',13)
%         set(gcf,'visible', 'off');
%         saveas(gcf,histogramPath)
     

% THRESHOLD 2- HISTOGRAM THRESHOLD FOR WHITE PIXELS
        [NF,edgesF] = histcounts(numberOfWhitePixelsFULL);
        maxIndexF = find(NF == max(NF));
        T2_FULL =max(edgesF(maxIndexF) + 0.10*(edgesF(maxIndexF)));
        
        [NL,edgesL] = histcounts(numberOfWhitePixelsLEFT);
        maxIndexL = find(NL == max(NL));
        T2_LEFT = real(max(edgesL(maxIndexL)+ 0.10*(edgesL(maxIndexL))));
        
        [NR,edgesR] = histcounts(numberOfWhitePixelsRIGHT);
        maxIndexR = find(NR == max(NR));
        T2_RIGHT = real(max(edgesR(maxIndexR) + 0.10*(edgesR(maxIndexR))));
        
        %percent = 0.85;
        %T2_FULL = percent*max(numberOfWhitePixelsFULL(:));
        numberOfWhitePixelsFULL(numberOfWhitePixelsFULL < T2_FULL) = 0;
        numberOfWhitePixelsFULL(numberOfWhitePixelsFULL >= T2_FULL) = 1;
        
        %T2_LEFT = percent*max(numberOfWhitePixelsLEFT(:));
        numberOfWhitePixelsLEFT(numberOfWhitePixelsLEFT < T2_LEFT) = 0;
        numberOfWhitePixelsLEFT(numberOfWhitePixelsLEFT >= T2_LEFT) = 1;
        
        %T2_RIGHT = percent*max(numberOfWhitePixelsRIGHT(:));
        numberOfWhitePixelsRIGHT(numberOfWhitePixelsRIGHT < T2_RIGHT) = 0;
        numberOfWhitePixelsRIGHT(numberOfWhitePixelsRIGHT >= T2_RIGHT) = 1;
        
% MEDIAN FILTER TO SMOOTH OUT THE DATA 
        % look at previous three (k-3) and next three (k+3) values 
        % to vote on vlaue at k
        SmoothedOutputFULL  = medfilt1(numberOfWhitePixelsFULL,7);
        SmoothedOutputLEFT  = medfilt1(numberOfWhitePixelsLEFT,7); 
        SmoothedOutputRIGHT = medfilt1(numberOfWhitePixelsRIGHT,7);
         
        % Zero Pad the beginning and end of SmoothedOutput so that
        % 'findpeaks' will be able to detect a peak starting at 1 and/or
        % ending at length(SmoothedOutput)
        % add 2 zeros at either end of the array -- [ 0 0 SmoothedOut 0 0]
        SmoothedOutputFULL = padarray(SmoothedOutputFULL, [0 2]);
        SmoothedOutputLEFT = padarray(SmoothedOutputLEFT, [0 2]);
        SmoothedOutputRIGHT = padarray(SmoothedOutputRIGHT, [0 2]);
          
         FrameIndexLEFT = zeros(1,length(SmoothedOutputLEFT));
         for fl = 1:length(SmoothedOutputLEFT)
             if SmoothedOutputLEFT(fl) == 1
                lframeNum = 1;
                FrameIndexLEFT(lframeNum) = fl;
                lframeNum = lframeNum + 1;
           
             end
         end

         
         FrameIndexRIGHT = zeros(1,length(SmoothedOutputRIGHT));
         for fr = 1:length(SmoothedOutputRIGHT)
             if SmoothedOutputRIGHT(fr) == 1
                rframeNum = 1;
                FrameIndexRIGHT(rframeNum) = fr;
                rframeNum = rframeNum + 1;
             end
         end
         
%          DetectedFramesFile = fopen('/Volumes/MyPassportforMac/FramesWhere1isDetected.txt','at');
%          fprintf(DetectedFramesFile,'%s,', string(vidnames{n}));
%          fprintf(DetectedFramesFile,'%d,%d \n', [FrameIndexLEFT, FrameIndexRIGHT]);
%          fclose(DetectedFramesFile);
%          
         
        OutputGraph = char(strcat('/Volumes/MyPassportforMac/GrayThreshAlgo/','Time Plot','_',vidnames{n},'.png'));
         %figure(1)      % Time Graph Output
         %plot(SmoothedOutputFULL,'Linewidth',2);
         %hold on
        x = linspace(0, ceil(v.Duration), length(SmoothedOutputFULL));
        plot(x,SmoothedOutputLEFT,'Linewidth',2);
        hold on
        plot(x,SmoothedOutputRIGHT,'Linewidth',2);
        hold off
        ylim([0 1.1])
        %title([{vidnames{n}},{' Threshold =' num2str(T2_RIGHT)}],'interpreter','none')
        title({'Washings Detected on Left and Right in', vidnames{n}},'interpreter','none')
        %xticks('auto')
        xlabel('Seconds')
        legend('Left ROI', 'Right ROI','Location','northeastoutside')
        set(gca,'fontsize',13)
        set(gcf,'visible', 'off');
        saveas(gcf,OutputGraph)
         %set(0,'defaultFigureVisible','off');
        
% COUNT NUMBER OF PEAKS IN OUTPUT TIME PLOT
        DetectedWashingsLEFT = ceil(sum(findpeaks(SmoothedOutputLEFT)) / 2);     %SmoothedOutput  numel( )
        DetectedWashingsRIGHT = ceil(sum(findpeaks(SmoothedOutputRIGHT)) / 2);
        
% OUTPUT RESULTS TO TEXT FILE
        resultFile = fopen('/Volumes/MyPassportforMac/GrayThreshAlgo.txt','at');
        fprintf(resultFile,'%s,', string(vidnames{n}));
        fprintf(resultFile,'%d,%d \n', [DetectedWashingsLEFT, DetectedWashingsRIGHT]);
        fclose(resultFile);      
        
        % Set numberOfWhitePixels back to zeros for next video
        numberOfWhitePixelsFULL  = zeros(1,length(numberOfWhitePixelsFULL));
        numberOfWhitePixelsLEFT  = zeros(1,length(numberOfWhitePixelsLEFT));
        numberOfWhitePixelsRIGHT = zeros(1,length(numberOfWhitePixelsRIGHT));

    end
    
      resultFile = fopen('/Volumes/MyPassportforMac/GrayThreshAlgo.txt','at');
      fprintf(resultFile, '\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
      fclose(resultFile);
      
% SUM NUMBER OF WASHING ON LEFT AND RIGHT FOR ONE SCHOOL/DAY 
%     WashingsPerDayLEFT = sum(DetectedWashingsLEFT);  %1:length(vidnames)));
%     WashingsPerDayRIGHT = sum(DetectedWashingsRIGHT);
%     resultFile = fopen('/Volumes/MyPassportforMac/Results_L&R.txt','at');
%     fprintf(resultFile,'Total Washings for %s on %s: ',[string(school), string(date)]);
%     fprintf(resultFile,'Left - %d, Right - %d \n', [WashingsPerDayLEFT, WashingsPerDayRIGHT]);
%     fclose(resultFile);
% 
%     % Set DetectedWashings to zeros for next video
%     DetectedWashings = zeros(1,length(DetectedWashings));
%     
end

% sound to signify code has finished running
load train.mat;
sound(y);

toc
 
