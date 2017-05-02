clc;
tic
%%
ROIpath = '/Volumes/MyPassportforMac/SAMPLING_DIR/COMBINED_SUBSAMPLES/ROI_data.txt';
posFile = fopen(ROIpath);
% Read in concatenated video filename, extenstion, Date, and Rectangle  
% Position from Text File.
% xmin,ymin are top left corner of imrect, width and height descripe size
% of rectangle
[filename,ext,xmin,ymin,width,height] = textread(ROIpath,'%[^.] %s %d %d %d %d');
                                        % '%[^.] read until first occurence of '.'                                      

% For Every Line in the Rectangle Position text file, get school name and 
% date. Then get corresponding background image and videos. Crop both the
% backroud image and every frame of the videos and convert to luminance.
% Subtract, threshold, and count number of white pixels in every video
% frame.
% INITIALIZE DAY VECTORS
DayVectorFULL = zeros(1,12); DayVectorLEFT = zeros(1,12); DayVectorRIGHT = zeros(1,12);
for i = 1       %:length(filename)   % lines in text file 
    % RESET DETECTED WASHINGS TO 0 FOR NEXT VIDEO
    DetectedWashingsFULL = 0; DetectedWashingsLEFT = 0; DetectedWashingsRIGHT = 0; 

    % Will parse line from Rectangle Position text file and set up school
    % and date variables. 
    splitSchoolandDate = strsplit(filename{i},{'_'});   %filename{i}
    school = splitSchoolandDate(1);      % maybe need string(split(1))
    date = strcat(splitSchoolandDate(2), '_',splitSchoolandDate(3));
    
    % Set up rectangle position
    pos = [xmin(i), ymin(i), width(i), height(i)];      % will be i's in for loop
    
    % Select Background Image
    backgroundImage = imread(char(strcat('/Volumes/MyPassportforMac/SAMPLING_DIR/COMBINED_SUBSAMPLES/Saved_Frames/',school,'_', date,'.png')));
    background = rgb2gray(backgroundImage);
    
    % Set up background for school and date -- constant for whole day
    backcropFULL = (background([ymin(i) : 1 : ymin(i)+height(i)-1],...
                    [xmin(i) : 1 : xmin(i)+width(i) +1],:));
    backcropLEFT  = backcropFULL(1:end, 1:end/2);
    backcropRIGHT = backcropFULL(1:end, (end/2)+1:end);    
    
    % Read in video files for specific school and date
    videoFiles = char(strcat('/Volumes/MyPassportforMac/SAMPLING_DIR/_DATES_DIRS/',school,'/', date,'/*.avi'));
    videoDirectory = struct2cell(dir(videoFiles));
    vidnames = videoDirectory(1,:);
    
    % If date file is empty:
%     if isempty(vidnames) == 1
%         resultFile = fopen('/Volumes/MyPassportforMac/Washing_Results.txt','at');
%         fprintf(resultFile,'There are no videos for %s on %s. \n ',[string(school), string(date)]);
%         fclose(resultFile);
%     end
    
    for n = 2:4       %:length(vidnames)  % for every video file in a specific date     
% OPEN 30 SECOND VIDEO
        v = VideoReader(vidnames{n});
        
% PARSE TIME STAMP IN VIDNAMES
        vnamesplit = strsplit(vidnames{n},{'_'});
        day = strcat(vnamesplit(2), '_', vnamesplit(3), '_', vnamesplit(4));    %ie. Fri_Feb_10
        time = strsplit(string(vnamesplit(5)),{':'});   %ie. 08:35:34
        hour = char(time(1)); minute = time(2); second = time(3);       
             
        count=1;
        fnum=0;
        while v.hasFrame
            fnum=fnum+1;
            % set current frame and background frame.
            frame = rgb2gray(readFrame(v));
            framecrop = frame([ymin(i) : 1 : ymin(i)+height(i)-1],...
                        [xmin(i) : 1 : xmin(i)+width(i) +1],:);
            
            % ignore jet black rope
            notpitchblackFULL  = framecrop > 3; 
            notpitchblackLEFT  = framecrop(1:end, 1:end/2) > 3; 
            notpitchblackRIGHT = framecrop(1:end, (end/2)+1:end) > 3; 
            
            subtract = imabsdiff(framecrop, backcropFULL);
                       
% SPLIT SUBTRACT ROI INTO LEFT AND RIGHT SECTIONS
            fullROI  = subtract;
            leftROI  = subtract(1:end, 1:end/2);
            rightROI = subtract(1:end, (end/2)+1:end);

% INTENSITY THRESHOLD                       
            I = 58; % max pixel intensity
            highvalsFULL  = framecrop < I;
            highvalsLEFT  = framecrop(1:end, 1:end/2) < I;
            highvalsRIGHT = framecrop(1:end, (end/2)+1:end) < I;
            
% THRESHOLD 1 - SUBTRACTION
            T1 = 40;
            fullROI(fullROI < T1) = 0;
            bwsubtractFULL = imbinarize(fullROI);
            bwsubtractFULL = bwsubtractFULL.*notpitchblackFULL.*highvalsFULL;
           
            leftROI(leftROI < T1) = 0;
            bwsubtractLEFT = imbinarize(leftROI);
            bwsubtractLEFT = bwsubtractLEFT.*notpitchblackLEFT.*highvalsLEFT;
           
            rightROI(rightROI < T1) = 0;
            bwsubtractRIGHT = imbinarize(rightROI);
            bwsubtractRIGHT = bwsubtractRIGHT.*notpitchblackRIGHT.*highvalsRIGHT;

% COUNT NUMBER OF WHITE PIXELS IN SUBTRACTED ROI
            numberOfWhitePixelsFULL(count)  = double(sum(sum(bwsubtractFULL)));
            numberOfWhitePixelsLEFT(count)  = double(sum(sum(bwsubtractLEFT)));
            numberOfWhitePixelsRIGHT(count) = double(sum(sum(bwsubtractRIGHT)));
            
            count=count+1;           
        end
       
% THRESHOLD 2 - PERCENTAGE OF WHITE PIXELS        
        T2FULL = (0.30)*max(numberOfWhitePixelsFULL(:));
        numberOfWhitePixelsFULL(numberOfWhitePixelsFULL < T2FULL) = 0;
        numberOfWhitePixelsFULL(numberOfWhitePixelsFULL >= T2FULL) = 1;
        
        T2LEFT = (0.30)*max(numberOfWhitePixelsLEFT(:));
        numberOfWhitePixelsLEFT(numberOfWhitePixelsLEFT < T2LEFT) = 0;
        numberOfWhitePixelsLEFT(numberOfWhitePixelsLEFT >= T2LEFT) = 1;
        
        T2RIGHT = (0.30)*max(numberOfWhitePixelsRIGHT(:));
        numberOfWhitePixelsRIGHT(numberOfWhitePixelsRIGHT < T2RIGHT) = 0;
        numberOfWhitePixelsRIGHT(numberOfWhitePixelsRIGHT >= T2RIGHT) = 1;
        
        
% MEDIAN FILTER AND PADDED ARRAY
        % Zero Pad the beginning and end of SmoothedOutput so that
        % 'findpeaks' will be able to detect a peak starting at 1 and/or
        % ending at length(SmoothedOutput) - Add 2 zeros at either end of the array -- [ 0 0 SmoothedOut 0 0]
        % Look at previous three (k-3) and next three (k+3) values 
        % to vote on vlaue at k
        SmoothedOutputFULL  = padarray(medfilt1(numberOfWhitePixelsFULL,7), [0 2]);
        SmoothedOutputLEFT  = padarray(medfilt1(numberOfWhitePixelsLEFT,7), [0 2]);
        SmoothedOutputRIGHT = padarray(medfilt1(numberOfWhitePixelsRIGHT,7), [0 2]);
        
% COUNT NUMBER OF PEAKS IN ROI
        DetectedWashingsFULL  = ceil(sum(findpeaks(SmoothedOutputFULL)) / 2); 
        DetectedWashingsLEFT  = ceil(sum(findpeaks(SmoothedOutputLEFT)) / 2); 
        DetectedWashingsRIGHT = ceil(sum(findpeaks(SmoothedOutputRIGHT)) / 2); 
        
        HourVectorFULL = zeros(1, 12);  % Represents 7am - 6pm
        HourVectorFULL(str2double(hour)-6) = DetectedWashingsFULL;
        DayVectorFULL = DayVectorFULL + HourVectorFULL;
        
        HourVectorLEFT = zeros(1, 12);  % Represents 7am - 6pm
        HourVectorLEFT(str2double(hour)-6) = DetectedWashingsLEFT;
        DayVectorLEFT = DayVectorLEFT + HourVectorLEFT;
        
        HourVectorRIGHT = zeros(1, 12);  % Represents 7am - 6pm
        HourVectorRIGHT(str2double(hour)-6) = DetectedWashingsRIGHT;
        DayVectorRIGHT = DayVectorRIGHT + HourVectorRIGHT;

        % Frames that have value of 1 - detected handwashing
        fDetectedFULL = find(SmoothedOutputFULL==1);
        fDetectedLEFT = find(SmoothedOutputLEFT==1);
        fDetectedRIGHT = find(SmoothedOutputRIGHT==1);
        
        % To Avoid Dark Frames (all 1's detected)
        if length(fDetectedFULL) > 300
            DetectedWashingsFULL = 0;
        end
        if length(fDetectedLEFT) > 300
            DetectedWashingsLEFT = 0;
        end
        if length(fDetectedRIGHT) > 300
            DetectedWashingsRIGHT = 0;
        end
            
        dFULL  = sprintf('%d ', fDetectedFULL);
        dLEFT  = sprintf('%d ', fDetectedLEFT);
        dRIGHT = sprintf('%d ', fDetectedRIGHT);

% PRINT RESULTS TO COMMAND WINDOW     
        fprintf('For: %s', string(vidnames{n}));
        fprintf('\n\nTotal Detected Washings for video, FULL ROI: %d', DetectedWashingsFULL);
        fprintf('\n\nAt Frames: %s \n', dFULL);
        fprintf('\n\nTotal Detected Washings for video, LEFT ROI: %d', DetectedWashingsLEFT);
        fprintf('\n\nAt Frames: %s \n', dLEFT);
        fprintf('\n\nTotal Detected Washings for video, RIGHT ROI: %d', DetectedWashingsRIGHT);
        fprintf('\n\nAt Frames: %s \n', dRIGHT);
        
% SAVE OUTPUT TIME GRAPH OF FULL ROI TO FOLDER        
        OutputGraphFULL = char(strcat('/Volumes/MyPassportforMac/OutputGraphsFULL/','Time Plot','_',school,'_', date,'_',vidnames{n},'.png'));
        x = linspace(0, ceil(v.Duration), length(SmoothedOutputFULL));
        plot(x,SmoothedOutputFULL,'Linewidth',2);
        ylim([0 1.1])
        title({'Washings Detected in Full ROI in', vidnames{n}},'interpreter','none')
        xlabel('Seconds')
        legend('Left ROI','Location','northeastoutside')
        set(gca,'fontsize',13)
        set(gcf,'visible', 'off');
        saveas(gcf,OutputGraphFULL)
        
% SAVE OUTPUT TIME GRAPH OF FULL ROI TO FOLDER        
        OutputGraphLR = char(strcat('/Volumes/MyPassportforMac/OutputGraphsLR/','Time Plot','_',school,'_', date,'_',vidnames{n},'.png'));        
        plot(x,SmoothedOutputLEFT,'Linewidth',2);
        hold on
        plot(x,SmoothedOutputRIGHT,'Linewidth',2);
        hold off
        ylim([0 1.1])
        title({'Washings Detected in Left and Right ROIs in', vidnames{n}},'interpreter','none')
        xlabel('Seconds')
        legend('Left ROI', 'Right ROI','Location','northeastoutside')
        set(gca,'fontsize',13)
        set(gcf,'visible', 'off');
        saveas(gcf,OutputGraphLR)
        
        
%       
% OUTPUT RESULTS TO HOURLY TEXT FILES IN 24 HOUR FORMAT        
        % vidname,7am,8am,9am,...6pm 
        FULL_ROI_Hourly_ResutsFile = fopen('/Volumes/MyPassportforMac/RESULTS/FULL_ROI_Hourly_Results.txt','at');
        fprintf(FULL_ROI_Hourly_ResutsFile,'%s,',string(vidnames{n}));
            hvf=string(HourVectorFULL); hvf=strjoin(hvf,',');
        fprintf(FULL_ROI_Hourly_ResutsFile,'%s\n',hvf);
        fclose(FULL_ROI_Hourly_ResutsFile);

        LR_ROI_Hourly_ResutsFile = fopen('/Volumes/MyPassportforMac/RESULTS/LR_ROI_Hourly_Results.txt','at');
        fprintf(LR_ROI_Hourly_ResutsFile,'%s,',string(vidnames{n}));
            hvl=string(HourVectorLEFT);  hvl=strjoin(hvl,',');
            hvr=string(HourVectorRIGHT); hvr=strjoin(hvr,',');
        fprintf(LR_ROI_Hourly_ResutsFile,'%s,%s\n',[hvl,hvr]);
        fclose(LR_ROI_Hourly_ResutsFile);
        
        % SET NUMBER OF WHITE PIXELS BACK TO ZERO FOR NEXT VIDEO
        numberOfWhitePixelsFULL  = zeros(1,length(numberOfWhitePixelsFULL));
        numberOfWhitePixelsLEFT  = zeros(1,length(numberOfWhitePixelsLEFT));
        numberOfWhitePixelsRIGHT = zeros(1,length(numberOfWhitePixelsRIGHT));
    end
    
% OUTPUT RESULTS TO DAILY TEXT FILES IN 24 HOUR FORMAT           
    FULL_ROI_Daily_ResutsFile = fopen('/Volumes/MyPassportforMac/RESULTS/FULL_ROI_Daily_Results.txt','at');
    fprintf(FULL_ROI_Daily_ResutsFile,'%s,', string(school));
    fprintf(FULL_ROI_Daily_ResutsFile,'%s,', string(day));
        dvf=string(DayVectorFULL); dvf=strjoin(dvf,',');
    fprintf(FULL_ROI_Daily_ResutsFile,'%s\n',dvf);
    fclose(FULL_ROI_Daily_ResutsFile);
    
    LR_ROI_Daily_ResutsFile = fopen('/Volumes/MyPassportforMac/RESULTS/LR_ROI_Daily_Results.txt','at');
    fprintf(LR_ROI_Daily_ResutsFile,'%s,', string(school));
    fprintf(LR_ROI_Daily_ResutsFile,'%s,', string(day));
    dvl=string(DayVectorLEFT);  dvl=strjoin(dvl,',');
    dvr=string(DayVectorRIGHT); dvr=strjoin(dvr,',');
    fprintf(LR_ROI_Daily_ResutsFile,'%s,%s\n',[dvl, dvr]);
    fclose(LR_ROI_Daily_ResutsFile);
 
% RESET DAYVECTOR COUNT FOR NEXT DAY    
    DayVectorFULL = zeros(1,12); DayVectorLEFT = zeros(1,12); DayVectorRIGHT = zeros(1,12);
end

% sound to signify code has finished running
%load train.mat;
%sound(y);

toc


 