clc;
tic
%%
path = '/Volumes/MyPassportforMac/3_combined_5_schools/RectPosition.txt';
posFile = fopen(path);
% Read in concatenated video filename, extenstion, Date, and Rectangle  
% Position from Text File.
% xmin,ymin are top left corner of imrect, width and height descripe size
% of rectangle
[filename,ext,M,D,Y,xmin,ymin,width,height] = textread(path,...
                                            '%[^.] %s %d %d %d %d %d %d %d');
                                        % '%[^.] read until first occurence of '.'                                      

% For Every Line in the Rectangle Position text file, get school name and 
% date. Then get corresponding background image and videos. Crop both the
% backroud image and every frame of the videos and convert to luminance.
% Subtract, threshold, and count number of white pixels in every video
% frame.

for i = 1:length(filename)   % lines in text file   
    % Will parse line from Rectangle Position text file and set up school
    % and date variables. 
    splitSchoolandDate = strsplit(filename{i},{'_'});   %filename{i}
    school = splitSchoolandDate(1);      % maybe need string(split(1))
    date = strcat(splitSchoolandDate(2), '_',splitSchoolandDate(3));
    
    % Set up rectangle position
    pos = [xmin(i), ymin(i), width(i), height(i)];      % will be i's in for loop
    
    % Select Background Image
    backgroundImage = imread(char(strcat('/Volumes/MyPassportforMac/BACKGROUNDS/',school,'_', date,'.png')));
    background = im2double(backgroundImage);
    
    % Set up background for school and date -- constant for whole day
    %backframe = background;
    backcrop = (background([ymin(i) : 1 : ymin(i)+height(i)-1],...
        [xmin(i) : 1 : xmin(i)+width(i) +1],:));
    backGray = rgb2gray(backcrop);
    
    % Read in video files for specific school and date
    videoFiles = char(strcat('/Volumes/MyPassportforMac/GhanaVideos/',school,'/', date,'/*.avi'));
    videoDirectory = struct2cell(dir(videoFiles));
    vidnames = videoDirectory(1,:);
    
    % If date file is empty:
    if isempty(vidnames) == 1
        resultFile = fopen('/Volumes/MyPassportforMac/Washing_Results.txt','at');
        fprintf(resultFile,'There are no videos for %s on %s. \n ',[string(school), string(date)]);
        fclose(resultFile);
    end
    
    for n = 1:length(vidnames)  % for every video file in a specific date
        % Create Ouput Video
        % outputVideoName = char(strcat('/Volumes/MyPassportforMac/SubtractedVideos/','SubtractedThresh',vidnames{n}));
        % vout = VideoWriter(outputVideoName);
        
        % Select 30 sec Video
        v = VideoReader(vidnames{n});
        %vout.open()      
        
        count=1;
        while v.hasFrame
            % set current frame and background frame.
            frame = im2double(readFrame(v));
            %backframe = background;
            
            framecrop = (frame([ymin(i) : 1 : ymin(i)+height(i)-1],...
                [xmin(i) : 1 : xmin(i)+width(i) +1],:));
            %backcrop = (backframe([ymin(i) : 1 : ymin(i)+height(i)-1],...
             %   [xmin(i) : 1 : xmin(i)+width(i) +1],:));
            
            frameGray = rgb2gray(framecrop);
            %backGray = rgb2gray(backcrop);
            
            %noThreshSubtract = abs(frameGray - backGray);
            
            subtract = abs(frameGray - backGray);
            
            % Threshold 1
            % 0.5 too high
            T1 = 0.3;
            subtract(subtract < T1) = 0;
            subtract(subtract > T1) = 1;
            
            %vout.writeVideo(subtract);
            
            numberOfWhitePixels(count) = double(sum(sum(subtract)));
            count=count+1;
            
        end
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
        
        T2 = (0.75)*max(numberOfWhitePixels(:));
        numberOfWhitePixels(numberOfWhitePixels < T2) = 0;
        numberOfWhitePixels(numberOfWhitePixels >= T2) = 1;
        
        %         OutputGraph = char(strcat('/Volumes/MyPassportforMac/OutputGraphsT1_0.4/','Time Plot','_',school,'_', date,'_',vidnames{n},'.png'));
        %         %figure(1)      % Time Graph Output
        %         plot(numberOfWhitePixels,'Linewidth',3);
        %         ylim([0 1.1])
        %         title((strcat(school,date,vidnames{n},' Threshold =',num2str(T2))))
        %         xlabel('Frames')
        %         set(gca,'fontsize',13)
        %         set(gcf,'visible', 'off');
        %         saveas(gcf,OutputGraph)
        %set(0,'defaultFigureVisible','off');
        
        % Count number of peaks in output time plot
        DetectedWashings(n) = numel(findpeaks(numberOfWhitePixels));
        % Output results to Text file
        resultFile = fopen('/Volumes/MyPassportforMac/Washing_Results.txt','at');
        fprintf(resultFile,'%s ', string(school));
        fprintf(resultFile,'%s ', string(date));
        fprintf(resultFile,'%s ', string(vidnames{n}));
        fprintf(resultFile,'%d \n', DetectedWashings(n));
        fclose(resultFile);
        
        
    end
    
    % sum number of washing for one day(i)
    WashingsPerDay = sum(DetectedWashings(1:length(vidnames)));
    resultFile = fopen('/Volumes/MyPassportforMac/Washing_Results.txt','at');
    fprintf(resultFile,'Total Washings for %s on %s: ',[string(school), string(date)]);
    fprintf(resultFile,'%d \n', ceil(WashingsPerDay/2));
    fclose(resultFile);
    
    DetectedWashings = zeros(1,length(DetectedWashings));
    
end

% sound to signify code has finished running
load train.mat;
sound(y);

toc


 
