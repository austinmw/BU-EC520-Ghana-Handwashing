clc;
tic
%%
ROIpath = '/Volumes/MyPassportforMac/SAMPLING_DIR/COMBINED_SUBSAMPLES/ROI_data.txt';
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
    %backgroundImage = imread(char(strcat('/Volumes/MyPassportforMac/BACKGROUNDS/',school,'_', date,'.png')));
    backgroundImage = imread(char(strcat('/Volumes/MyPassportforMac/SAMPLING_DIR/COMBINED_SUBSAMPLES/Saved_Frames/',school,'_', date,'.png')));
    background = im2double(backgroundImage);
    
    % Set up background for school and date -- constant for whole day
    %backframe = background;
    backcrop = (background([ymin(i) : 1 : ymin(i)+height(i)-1],...
        [xmin(i) : 1 : xmin(i)+width(i) +1],:));
    backGray = rgb2gray(backcrop);
    
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
    
    for n = 1   %:length(vidnames)  % for every video file in a specific date
        % Create Ouput Video
        % outputVideoName = char(strcat('/Volumes/MyPassportforMac/SubtractedVideos/','SubtractedThresh',vidnames{n}));
        % vout = VideoWriter(outputVideoName);
        % vout.open() 
            
        % Select 30 sec Video
        v = VideoReader(vidnames{n});
        % ADD IN CROSS CHECK WITH GOOD FILE LIST TO AVOID DAMAGED VIDEOS 
        
        
        % AVERAGE CURRENT VIDEO AND OBTAIN TRIANGLE THRESHOLD
        Nframes = v.NumberOfFrames; Nheight = v.Height; Mwidth = v.Width;
        videoFrame = zeros(Nheight,Mwidth,3,'single');
        videoFrameAvg = zeros(Nheight,Mwidth,3,'single');
        
        for k = 1:Nframes
            videoFrame = read(v,k);
            videoFrameAvg = videoFrameAvg + single(videoFrame);
        end
        % Average Frame for Video
        videoFrameAvg = videoFrameAvg/Nframes;
        avgcrop = (videoFrameAvg([ymin(i) : 1 : ymin(i)+height(i)-1],...
                    [xmin(i) : 1 : xmin(i)+width(i) +1],:));
        avgGray = rgb2gray(avgcrop);
        
        difference = abs(avgGray - backGray);
        difference_hist = imhist(difference);
        
        % Compute Triangle Threshold for Video
        [TriangleThresh] = triangle_th(difference_hist,256);
        avgVid_Thresh=im2bw(difference,TriangleThresh);
        close
        
        v = VideoReader(vidnames{n});
        count=1;
        while v.hasFrame
            % set current frame and background frame.
            frame = im2double(readFrame(v));         
            framecrop = (frame([ymin(i) : 1 : ymin(i)+height(i)-1],...
                [xmin(i) : 1 : xmin(i)+width(i) +1],:));       
            frameGray = rgb2gray(framecrop);          
            subtract = abs(frameGray - backGray);
            
            % Threshold 1
            % 0.5 too high
            % T1 = 0.3;
            subtract(subtract < TriangleThresh) = 0;
            subtract(subtract > TriangleThresh) = 1;
            
            numberOfWhitePixels(count) = double(sum(sum(subtract)));
            count=count+1;
            
            % vout.writeVideo(subtract);
            
        end
%          f=figure;
%             imshow(subtract)
%             waitfor(f);
        %vout.close();
        
        % HISTORGRAMS
%         histogram = char(strcat('/Volumes/MyPassportforMac/WhitePixelNoThreshHist/','Histogram','_',school,'_', date,'_',vidnames{n},'.png'));
%         hist(numberOfWhitePixels)
%         title((strcat(school,date,vidnames{n},' Histogram')))
%         xlabel('Pixels')
%         xlim([0 4000])
%         set(gca,'fontsize',13)
%         set(gcf,'visible', 'off');
%         saveas(gcf,histogram)
        
        % THIS THRESHOLD IS STILL A LITTLE VAGUE
        T2 = (0.85)*max(numberOfWhitePixels(:));
        numberOfWhitePixels(numberOfWhitePixels < T2) = 0;
        numberOfWhitePixels(numberOfWhitePixels >= T2) = 1;
       
        % Median Filter to Smooth out the Data
        % look at previous 2 (k-2) and next 2 (k+2) values to vote on vlaue at k
         SmoothedOutput = medfilt1(numberOfWhitePixels,7);
         
        % Zero Pad the beginning and end of SmoothedOutput so that
        % 'findpeaks' will be able to detect a peak starting at 1 and/or
        % ending at length(SmoothedOutput)
        % add 2 zeros at either end of the array -- [ 0 0 SmoothedOut 0 0]
        SmoothedOutput = padarray(SmoothedOutput, [0 2]);
          
%          %FrameIndex = zeros(1,length(SmoothedOutput));
%          for f = 1:length(SmoothedOutput)
%              if SmoothedOutput(f) == 1
%                 cell = 1;
%                 FrameIndex(cell) = f;
%                 cell = cell + 1;
%              end
%          end
         
%          DetectedFramesFile = fopen('/Volumes/MyPassportforMac/FramesWhere1isDetected.txt','at');
%          fprintf(DetectedFramesFile,'%s,', string(vidnames{n}));
%          fprintf(DetectedFramesFile,'%d \n', FrameIndex);
%          fclose(DetectedFramesFile);
%          
%          FrameIndex = zeros(1:length(FrameIndex));
%         
         OutputGraph = char(strcat('/Volumes/MyPassportforMac/Smoothed/','Time Plot','_',vidnames{n},'.png'));
         %figure(1)      % Time Graph Output
         plot(SmoothedOutput,'Linewidth',2);
         %plot(numberOfWhitePixels,'Linewidth',2);
         ylim([0 1.1])
         title((strcat(school,date,vidnames{n},' Threshold =',num2str(T2))))
         xlabel('Frames')
         set(gca,'fontsize',13)
         set(gcf,'visible', 'off');
         saveas(gcf,OutputGraph)
         %set(0,'defaultFigureVisible','off');
        
        % COUNT NUMBER OF PEAKS IN OUTPUT TIME PLOT
        DetectedWashings = ceil(sum(findpeaks(SmoothedOutput)) / 2);     %SmoothedOutput  numel( )
        disp(['Detected Washings: ' DetectedWashings])
        % Output results to Text file
        resultFile = fopen('/Volumes/MyPassportforMac/Washing_Results.txt','at');
        %fprintf(resultFile,'%s ', string(school));
        %fprintf(resultFile,'%s ', string(date));
        fprintf(resultFile,'%s,', string(vidnames{n}));
        fprintf(resultFile,'%d \n', DetectedWashings);
        fclose(resultFile);      
        
    end
    
    % sum number of washing for one day(i)
%     WashingsPerDay = ceil(DetectedWashings / 2);  %1:length(vidnames)));
%     resultFile = fopen('/Volumes/MyPassportforMac/Washing_Results.txt','at');
%     fprintf(resultFile,'Total Washings for %s on %s: ',[string(school), string(date)]);
%     fprintf(resultFile,'%d \n', WashingsPerDay);
%     fclose(resultFile);
    
%     DetectedWashings = zeros(1,length(DetectedWashings));
    
end

% sound to signify code has finished running
% load train.mat;
% sound(y);

toc


 
