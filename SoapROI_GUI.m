function SoapROI_GUI(hObject, eventdata, handles)
 %clc; clear all; 

%dinfo = dir('/Users/caitycallahan/Documents/EC520-Digital Image Processing/Ghana/3_examples/*.avi');
dinfo = dir('/Volumes/MyPassportforMac/3_combined_5_schools/*.avi');
fileName = {dinfo.name};
%%
%for i = 1:2     %length(fileName)  
global i 

handles.Counter = 1;
    currentvideo = fileName{handles.Counter};
%currentvideo ='/Users/caitycallahan/Documents/EC520-Digital Image Processing/Ghana/3_examples/Agona Nkran Islamic_feb_10.avi';

%currentvideo = 'Agona Nkran Islamic_feb_10.avi';
%currentvideo = '/Hand_washing_videos/VID0002.AVI';
v = VideoReader(currentvideo);

%v = VideoReader('vid-out2.AVI');
[hFig, hAxes] = createFigureAndAxes();

% Add buttons to control video playback.
insertButtons(hFig, hAxes, v,currentvideo,i);
           
%next = set(hFig,handles.PBNext,'Callback', {@nextCallback,v,hAxes,hFig,i});
%background=set(handles.PBBackground,'Callback', {@backgroundCallback,v,hAxes,hFig,currentvideo});

% playCallback(findobj('tag','PBButton123'),[],v,hAxes);
%uiwait(handles.backgroundCallback)
% uiwait()
% end
guidata(hObject, handles);
%% Create Figure, Axes, Titles
% Create a figure window and two axes with titles to display two videos.
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
               'position',[980 980 800 650]);        % [680 678 480 240]
                                                     % [L B W H]
        % Create axes and titles
        hAxes.axis1 = createPanelAxisTitle(hFig,[0.1 0.25 0.85 0.77],'Original Video'); % [X Y W H]
    end            

%% Create Axis and Title
% Axis is created on uipanel container object. This allows more control
% over the layout of the GUI. Video title is created using uicontrol.
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

            
%% Insert Buttons
% Insert buttons to play, pause the videos.
    function insertButtons(hFig, hAxes,v,currentvideo,i)

        % Play button with text Start/Pause/Continue
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Start',...
                'position',[10 10 80 65], 'tag','PBButton123','callback',...
                {@playCallback,v,hAxes,hFig});

        % Exit button with text Exit
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Exit',...
                'position',[100 10 80 65],'callback', ...
                {@exitCallback,v,hFig});
        
        % Next button with text Next Video     
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Next Video',...
                'position',[190 10 80 65],'tag','PBNext','callback',...
                {@nextCallback,v,hAxes,hFig,fileName});
           
        % Background button with text Save As Background    
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Save As Background',...
                'position',[280 10 120 65],'tag','PBBackground','callback',...
                {@backgroundCallback,v,hAxes,hFig,currentvideo});
    end

% PLAY BUTTON
    function playCallback(hObject,~,v,hAxes,hFig)    

       try
            % Check the status of play button
            isTextStart = strcmp(hObject.String,'Start');
            isTextCont  = strcmp(hObject.String,'Continue');
            
            if isTextStart
               % Two cases: (1) starting first time, or (2) restarting 
               % Start from first frame
               if ~v.hasFrame
                   v.CurrentTime = 0;
               end
            end
            if (isTextStart || isTextCont)
                hObject.String = 'Pause';
            else
                hObject.String = 'Continue';
            end
           
            while strcmp(hObject.String, 'Pause') && v.hasFrame
                pos = [314 237 148 141];
                frame = readFrame(v);
                
                showFrameOnAxis(hAxes.axis1, frame);

            end
            
            % When video reaches the end of file, display "Start" on the
            % play button.            
            if ~v.hasFrame
               %rect = getrect 
               rect = imrect()
               % won't save position until you double click the rectangle
               wait(rect);  
               pos = reshape(single(getPosition(rect)),1,length(getPosition(rect)));
        
               % Read file name, file date, and position of rectangle to text file
               name = string(v.name);
               file = dir(v.name);
               [Y, M, D, ~, ~, ~] = datevec(file.datenum);

               date = string([M,D,Y]);
               
               posFile = fopen('RectPosition.txt','at');
               fprintf(posFile,'%s ',name);
               fprintf(posFile,'%s ',date);
               fprintf(posFile,'%d ',pos);
               fprintf(posFile,'\n');
               fclose(posFile);
               
               delete(rect);
               hObject.String = 'Start';
            
            end
            
       catch ME
           % Re-throw error message if it is not related to invalid handle 
           if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
               rethrow(ME);
           end
       end
    end
% EXIT BUTTON
    function exitCallback(~,~,v,hFig)
        
        % Close the video file
        %release(v); 
        %v.close();
        % Close the figure window
        close(hFig);
    end

% NEXT BUTTON
    function nextCallback(hObject,~,v,hAxes,hFig,fileName)
%         currentvideo = fileName{i+1};
%         v = VideoReader(currentvideo);
%         sval = get(hObject,'Value');
%         data = get(hObject,'UserData');
%         v = VideoReader(fileName{2});
%         guidata(hObject, v);
        i = i+1;
        handles = guidata(hObject);
        handles.Counter = handles.Counter+1;
        % Read current text and convert it to a number.
% currentCounterValue = str2double(get(handles.Counter, 'String'));
% % Create a new string with the number being 1 more than the current number.
% newString = sprintf('%d', int32(currentCounterValue +1));
% % Send the new string to the text control.
% set(handles.Counter, 'String', newString );

        hObject.String = 'Saved';
        guidata(hObject, handles);
    % change background button from 'Saved' to 'Save as Background'
    end

% BACKGROUND BUTTON
% will need to pass in current file name 
    function backgroundCallback(hObject,~,v,hAxes,hFig,~)
        
        name = strsplit(v.name,'.avi');
        name{2} = '.png';
        fullname = strjoin(name,'');
        backgroundFrame = readFrame(v);
        path = '/Volumes/MyPassportforMac/BACKGROUNDS';
        splitpath = strsplit(path,'/');
        splitpath{end+1} = fullname;
        fullpath = strjoin(splitpath,'/');
        imwrite(backgroundFrame,fullpath,'png','WriteMode','append');
        
        hObject.String = 'Saved';
    end


% displayEndOfDemoMessage(mfilename)
    
end

