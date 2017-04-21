function gui(hObject, eventdata, handles)
 clc; clear all; 

 v = VideoReader('vid1.avi');
[hFig, hAxes] = createFigureAndAxes();

%global Xi Yi Wi Ht;

% Add buttons to control video playback.
insertButtons(hFig, hAxes, v);

% playCallback(findobj('tag','PBButton123'),[],v,hAxes);
	
	%%
% Create Figure 
   % hf = figure;
% Resize figure based on the video's width and height
	%set(hf);
			% set(hf,'position',[150 150 vidWidth vidHeight]);
% Playback movie once at the video's frame rate of 20 frames per second
  %  movie(hf,mov,1,20);        % 20 = FrameRate
			% movie(hf, mov, 1);

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
	function insertButtons(hFig, hAxes,v)

		% Play button with text Start/Pause/Continue
		uicontrol(hFig,'unit','pixel','style','pushbutton','string','Start',...
				'position',[10 10 80 65], 'tag','PBButton123','callback',...
				{@playCallback,v,hAxes,hFig});

		% Exit button with text Exit
		uicontrol(hFig,'unit','pixel','style','pushbutton','string','Exit',...
				'position',[100 10 80 65],'callback', ...
				{@exitCallback,v,hFig});
		 
		 % rect % x y w h
		 global Xi Yi Wi Ht Spd;
		 Xi = 340; Yi = 220; Wi = 100; Ht = 100; Spd = 6;   

		 % position
		Xup = uicontrol(hFig,'unit','pixel','style','pushbutton','string',' Up ',...
			'position',[320 100 50 30],'callback', ...
			{@upCallback,v,hFig});  
		Xdown = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Down',...
			'position',[320 40 50 30],'callback', ...
			{@downCallback,v,hFig});  
		Yleft = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Left',...
			'position',[270 70 50 30],'callback', ...
			{@leftCallback,v,hFig});  
		Yright = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Right',...
			'position',[370 70 50 30],'callback', ...
			{@rightCallback,v,hFig});  

		
		% size
	 Xup = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Taller',...
		'position',[520 100 50 30],'callback', ...
		{@incHeightCallback,v,hFig});  
	Xdown = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Shorter',...
		'position',[520 40 50 30],'callback', ...
		{@decHeightCallback,v,hFig});  
	Yleft = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Thinner',...
		'position',[470 70 50 30],'callback', ...
		{@decWidthCallback,v,hFig});  
	Yright = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Wider',...
		'position',[570 70 50 30],'callback', ...
		{@incWidthCallback,v,hFig});  

	
	
	speedUp = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Inc.Speed.',...
		'position',[680 90 80 55],'callback', ...
		{@speedUpCallback,v,hFig});  
	speedDown = uicontrol(hFig,'unit','pixel','style','pushbutton','string','Dec.Speed.',...
		'position',[680 30 80 55],'callback', ...
		{@speedDownCallback,v,hFig});  
		
		
		
		% reset button?
		% increase/decrease speed buttons?
		
	   
		

		 
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
			   %if isDone(v)
			   if ~v.hasFrame
				  % readFrame(v);
				   %hObject.String = 'Pause';
				   
				   
				   
				   v.CurrentTime = 0; 
				   
				  %reset(v);
			   end
			end
			if (isTextStart || isTextCont)
				hObject.String = 'Pause';
			else
				hObject.String = 'Continue';
			end


			%while strcmp(hObject.String, 'Pause') && ~isDone(v)
			while strcmp(hObject.String, 'Pause') && v.hasFrame
				
				
				pos = [314 237 148 141];
				frame = readFrame(v);
				global Xi Yi Wi Ht;
				
				backupFrame = frame;
				frame = insertShape(frame,'Rectangle',[Xi Yi Wi Ht],'LineWidth',2,'Color','red'); 
				%rect = shapeInserter(frame,pos);
				showFrameOnAxis(hAxes.axis1, frame);
				
				
				
				

			end
			
			% When video reaches the end of file, display "Start" on the
			% play button.
			%if isDone(v)
			while strcmp(hObject.String, 'Pause')

				
				frame = insertShape(backupFrame,'Rectangle',[Xi Yi Wi Ht],'LineWidth',2,'Color','red'); 
				%rect = shapeInserter(frame,pos);
				showFrameOnAxis(hAxes.axis1, frame);
				
				

				%{
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
			   %}

			   %hObject.String = 'Start';
				%}
			end
			
	   catch ME
		   % Re-throw error message if it is not related to invalid handle 
		   if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
			   rethrow(ME);
		   end
	   end
	end


	function exitCallback(~,~,v,hFig)
		
		% Close the video file
		%release(v); 
		%v.close();
		% Close the figure window
		close(hFig);
	end
 
%% movement callbacks
	function upCallback(~,~,v,hFig)
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
	   Spd = Spd + 4;
	end
	function speedDownCallback(~,~,v,hFig)
	   global  Spd;  
	   Spd = Spd - 4;
	end



displayEndOfDemoMessage(mfilename)
end

