clc;

%%
%path = '/Users/caitycallahan/Documents/EC520-Digital Image Processing/Ghana/3_examples/RectPosition.txt';
path = '/Volumes/MyPassportforMac/3_combined_5_schools/RectPosition.txt';
posFile = fopen(path);
% Read in School, Date, and Rectangle Position from Text File
% xmin,ymin are top left corner of imrect, width and height descripe size
% of rectangle
[filename,ext,M,D,Y,xmin,ymin,width,height] = textread(path,...
                                            '%[^.] %s %d %d %d %d %d %d %d');
                                        % '%[^.] read until first occurence of '.'                                      

% FOR LOOP SHOULD START HERE
for i = 1:length(filename)
splitSchoolandDate = strsplit(filename{i},{'_'});   %filename{i}
school = splitSchoolandDate(1);      % maybe need string(split(1))  
date = strcat(splitSchoolandDate(2), '_',splitSchoolandDate(3));

% Set up rectangle position
pos = [xmin(i), ymin(i), width(i), height(i)];      % will be i's in for loop

% Select Background Image
backgroundImage = imread(char(strcat('/Volumes/MyPassportforMac/BACKGROUNDS/',school,'_', date,'.png')));
background = im2double(backgroundImage);
% Read in video files for specific school and date
videoFiles = char(strcat('/Volumes/MyPassportforMac/GhanaVideos/',school,'/', date,'/*.avi'));
videoDirectory = struct2cell(dir(videoFiles));
vidnames = videoDirectory(1,:);
   
    for n = 1:length(vidnames)
        % Create Ouput Video
        outputVideoName = char(strcat('/Volumes/MyPassportforMac/SubtractedVideos/','SubtractedThresh',vidnames{n}));
        %vout = VideoWriter(outputVideoName);
        % Select Videos
        v = VideoReader(vidnames{n});       
        %vout.open()
        
        count=1;
        while v.hasFrame
            
            frame = im2double(readFrame(v));
            backframe = background;
            
            framecrop = (frame([ymin(i) : 1 : ymin(i)+height(i)-1],...
                [xmin(i) : 1 : xmin(i)+width(i) +1],:));
            backcrop = (backframe([ymin(i) : 1 : ymin(i)+height(i)-1],...
                [xmin(i) : 1 : xmin(i)+width(i) +1],:));
            
            frameGray = rgb2gray(framecrop);
            backGray = rgb2gray(backcrop);
           
            subtract = abs(frameGray - backGray);
            
            % Threshold 1
            % 0.5 too high
            T1 = 0.25;
            subtract(subtract < T1) = 0;
            subtract(subtract > T1) = 1;
            
            %vout.writeVideo(subtract);
            
            numberOfWhitePixels(count) = double(sum(sum(subtract)));
            count=count+1;
                   
        end
       %vout.close();
       
        T2 = 2700;
        numberOfWhitePixels(numberOfWhitePixels < T2) = 0;
        numberOfWhitePixels(numberOfWhitePixels >= T2) = 1;
        
        OutputGraph = char(strcat('/Volumes/MyPassportforMac/OutputGraphs/','Time Plot','_',school,'_', date,'_',vidnames{n},'.png'));
        %figure(1)      % Time Graph Output
        plot(numberOfWhitePixels,'Linewidth',3);
        ylim([0 1.1])
        title((strcat(school,date,vidnames{n},' Threshold =',num2str(T2))))
        xlabel('Frames')
        set(gca,'fontsize',13)
        set(gcf,'visible', 'off'); 
        saveas(gcf,OutputGraph)  
        %set(0,'defaultFigureVisible','off');
        
    end
  
    
end



 
