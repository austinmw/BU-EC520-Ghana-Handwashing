function gui()
clear all; clc; %#ok<CLALL>

% GUI for collecting background frames and ROI positions

% Place in directory with combined videos
% Requires an empty folder named "Saved_Frames" to also be in the directory


% get schools
global schools totalVids vidCount;
Files = dir('./*.avi');
schools = {Files.name};
totalVids = length(schools);
vidCount = 1;
% Start at video #1
v = VideoReader(schools{vidCount});


 % figure, handles struct
[hFig, hAxes] = createFigureAndAxes();
handles = guihandles(hFig);
guidata(hFig,handles);
% Add buttons to control video playback
insertButtons(hFig, hAxes, v, handles);


% Create Figure, Axes, Titles
function [hFig, hAxes] = createFigureAndAxes()
    % Close figure opened by last run
    figTag = 'CVST_VideoOnAxis_9804532';
    close(findobj('tag',figTag));

    % Create new figure
    hFig = figure('numbertitle', 'off', ...
           'name', 'Video In Custom GUI', ...
           'menubar','figure', ...
           'toolbar','figure', ...
           'resize', 'on', ...
           'tag',figTag, ...
           'renderer','painters', ...
           'position',[980 980 820 690]);        

    % Create axes and titles
    hAxes.axis1 = createPanelAxisTitle(hFig,[0.1 0.25 0.80 0.72],...
        'Original Video'); % [X Y W H]
end      


% Create Axis and Title
function hAxis = createPanelAxisTitle(hFig, pos, axisTitle)
    % Create panel
    hPanel = uipanel('parent',hFig,'Position',pos,'Units','Normalized');

    % Create axis   
    hAxis = axes('position',[0 0 1 1],'Parent',hPanel); 
    hAxis.XTick = [];
    hAxis.YTick = [];
    hAxis.XColor = [1 1 1];
    hAxis.YColor = [1 1 1];
    % Set video title using uicontrol. uicontrol is used so that text
    % can be positioned in the context of the figure, not the axis.
    titlePos = [pos(1)+0.02 pos(2)+pos(3)+0.3 0.3 0.07];
    uicontrol('style','text',...
        'String', axisTitle,...
        'Units','Normalized',...
        'Parent',hFig,'Position', titlePos,...
        'BackgroundColor',hFig.Color);
end

	
% UI Buttons it
function insertButtons(hFig, hAxes,v, handles)
    
    handles = guidata(hFig);
    
    % Play button with text Start/Pause/Continue
    handles.playButton = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Play','position',[30 85 170 65], 'tag',...
        'PBButton123','callback',{@playCallback,v,hAxes,hFig});

    % Exit button with text Exit
    handles.exitButton = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Exit','position',[120 15 80 65],...
        'callback',{@exitCallback,v,hFig});

     global Xi Yi Wi Ht Spd; 
     Xi = 320; Yi = 260; Wi = 130; Ht = 80; Spd = 10; % (x y w h)

     % Rectangle Position Buttons
    handles.Xup = uicontrol(hFig,'unit','pixel','style','pushbutton',...
        'string','Up','position',[300 100 50 30],'callback',...
        {@upCallback,v,hFig}); %#ok<*NASGU>
    
    handles.Xdown = uicontrol(hFig,'unit','pixel','style','pushbutton',...
        'string','Down','position',[300 40 50 30],'callback',...
        {@downCallback,v,hFig});  
    
    handles.Yleft = uicontrol(hFig,'unit','pixel','style','pushbutton',...
        'string','Left','position',[250 70 50 30],'callback',...
        {@leftCallback,v,hFig});  
    
    handles.Yright = uicontrol(hFig,'unit','pixel','style','pushbutton',...
        'string','Right','position',[350 70 50 30],'callback', ...
        {@rightCallback,v,hFig});  

    % Rectangle Size Buttons
    handles.Xtaller = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Taller','position',[540 100 50 30],...
        'callback',{@incHeightCallback,v,hFig});  
    
    handles.Xshorter = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Shorter','position',[540 40 50 30],...
        'callback',{@decHeightCallback,v,hFig});  

    handles.Ythinner = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Thinner','position',[490 70 50 30],...
        'callback',{@decWidthCallback,v,hFig});  

    handles.Ywider = uicontrol(hFig,'unit','pixel','style','pushbutton',...
        'string','Wider','position',[590 70 50 30],'callback', ...
        {@incWidthCallback,v,hFig});  


    % Buttons to change increment amount for repositioning/resizing
    handles.speedUp = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Inc.Speed.','position',[690 90 80 55],...
        'callback',{@speedUpCallback,v,hFig});  

    handles.speedDown = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Dec.Speed.','position',[690 30 80 55],...
        'callback',{@speedDownCallback,v,hFig});  

    
    % Next video button
    handles.NextVid = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Next','position',[30 15 80 65],...
        'callback',{@nextCallback,v,hFig});  
    
    % Save frame for background button
    handles.SaveFrame = uicontrol(hFig,'unit','pixel','style',...
        'pushbutton','string','Save Frame','position',[380 110 130 45],...
        'callback',{@saveCallback,v,hFig}); 
    
    
    % Capture button
    handles.CapPos = uicontrol(hFig,'unit','pixel','style','pushbutton',...
        'string','Record Position','position',[380 15 130 45], ...
        'callback',{@captureCallBack,v,hFig});     
    
   guidata(hFig,handles);
end



% Play button
function playCallback(playhandle,~,v,hAxes,handles)
    % Needed stuff
    handles = guidata(playhandle);
    handles.counter = 1; % take out after testing
    guidata(playhandle,handles);
    
    % Global variables (less efficient than handles, but easier to code)
    global Restart Pause lastFrame;
    global Xi Yi Wi Ht;
    
    try              
        v = VideoReader(schools{vidCount});
        
        %disp(v.CurrentTime); 
        
        % Check the status of play button
        Play = strcmp(playhandle.String,'Play');
        Pause = strcmp(playhandle.String,'Pause');
        Restart = strcmp(playhandle.String,'Restart');
        
        % Play
        if Play % (paused)
            %After playing, change text to "Pause" 
            playhandle.String = 'Pause';
        end   
        
        % Pause
        if Pause % (playing)
            % After pausing, change text to "Play"
            playhandle.String = 'Play';
        end

        % Restart 
        if Restart % (if clicked "Play" AND EoV)
            v.CurrentTime = 0;
            Play = 1;
           % Pause = 1;
        end
        % Play
        if Play % (paused)
            %After playing, change text to "Pause" 
            playhandle.String = 'Pause';
        end   
        
        num = vidCount;
        while (Play && v.hasFrame && (num==vidCount))
            
            
            frame = readFrame(v);
            lastFrame = frame;
            
            if num==vidCount % find better way to do this later
            
                frame = insertShape(frame,'Rectangle',[Xi Yi Wi Ht],...
                    'LineWidth', 2, 'Color','red'); 
                showFrameOnAxis(hAxes.axis1, frame);
                %disp('play print')
            end
        end
              
        % If no frames left, replace "Play" with "Restart"        
        if ~v.hasFrame
            playhandle.String = 'Restart';
            Restart = 1;
        end
        
        % Move retangle while paused or EoV
        while (Pause || Restart) && (num==vidCount)
              
            if (num==vidCount)
                frame = insertShape(lastFrame,'Rectangle',[Xi Yi Wi Ht],...
                    'LineWidth',2,'Color','red'); 
                showFrameOnAxis(hAxes.axis1, frame);
            end
            %disp('pause loop');
        end
            
    catch ME
    % Re-throw error message if it is not related to invalid handle 
        if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
        rethrow(ME);
        end
    end
    
end



% Button Callbacks

function nextCallback(nextHandle,~,v,handles)
    %global Xi Yi Wi Ht;
    global Play Pause;
    Play = 0; Pause = 0;

    handles = guidata(nextHandle);

    handles.playButton.String = 'Play';

    guidata(nextHandle,handles);

    if vidCount < totalVids
        vidCount = vidCount + 1;    
    else
        vidCount = 1;
    end

    v = VideoReader(schools{vidCount});
    disp(v.name);disp(' ');
    frame = readFrame(v);
    %frame = insertShape(frame,'Rectangle',[Xi Yi Wi Ht],...
       %             'LineWidth', 2, 'Color','red'); 

    showFrameOnAxis(hAxes.axis1, frame);
    v.CurrentTime = 0;   
end

function saveCallback(~,~,v,hFig)
    global lastFrame;
    [~,name,~] = fileparts(char(schools{vidCount}));
    imwrite(lastFrame,strcat('./Saved_Frames/',name,'.png'));
    fprintf('Frame saved in /Saved_Frames/.\n\n');
end


function captureCallBack(~,~,v,hFig)
    global Xi Yi Wi Ht;
    fprintf('Position recorded. (%d %d %d %d)\n\n', Xi, Yi, Wi, Ht); 
    fileID = fopen('ROI_data.txt','a');
    fmt = '%d %d %d %d\n';
    fprintf(fileID,'%s ', char(schools{vidCount}));
    fprintf(fileID,fmt,[Xi, Yi, Wi, Ht]); 
    fclose(fileID);  
end

function exitCallback(exitHandle,~,v,hFig, handles) %#ok<*INUSL>
    global Play Pause Restart; 
    handles = guidata(exitHandle); 
    Play = 0; Pause = 0; Restart = 0;
    guidata(exitHandle,handles);  
    close(hFig);
    clc;       
end

function upCallback(~,~,v,hFig) %#ok<*INUSD>
   global Yi Spd;  
   Yi = Yi - Spd;
end

function downCallback(~,~,v,hFig)
   global Yi Spd;  
   Yi = Yi + Spd;
end

function leftCallback(~,~,v,hFig)
   global Xi Spd;  
   Xi = Xi - Spd;
end

function rightCallback(~,~,v,hFig)
   global Xi Spd;  
   Xi = Xi + Spd;
end

function incHeightCallback(~,~,v,hFig)
   global Ht Spd;  
   Ht = Ht + Spd;
end

function decHeightCallback(~,~,v,hFig)
   global Ht Spd;  
   Ht = Ht - Spd;
end

function incWidthCallback(~,~,v,hFig)
   global Wi Spd;  
   Wi = Wi + Spd;
end

function decWidthCallback(~,~,v,hFig)
   global Wi Spd;  
   Wi = Wi - Spd;
end

function speedUpCallback(~,~,v,hFig)
   global Spd;  
   Spd = round(Spd * 2);
end

function speedDownCallback(~,~,v,hFig)
   global  Spd;  
   Spd = round(Spd / 2);
end



end % end GUI

