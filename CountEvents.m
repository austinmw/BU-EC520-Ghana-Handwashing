clear; clc; tic

ROIpath = '/Volumes/Seagate/SAMPLING_DIR/COMBINED_SUBSAMPLES/ROI_data.txt';

posFile = fopen(ROIpath);

[filename,ext,xmin,ymin,width,height] = textread(ROIpath,...
											'%[^.] %s %d %d %d %d');                                     
									 
for i = 1%:length(filename) % particular school/date

	splitSchoolandDate = strsplit(filename{i},{'_'});   
	school = splitSchoolandDate(1);     
	date = strcat(splitSchoolandDate(2), '_',splitSchoolandDate(3));
	
	% Set up rectangle position
	pos = [xmin(i), ymin(i), width(i), height(i)];     
	
	backgroundImage = imread(char(strcat('/Volumes/Seagate/SAMPLING_DIR/COMBINED_SUBSAMPLES/Saved_Frames/',school,'_', date,'.png')));

	backcrop = (backgroundImage(ymin(i):ymin(i)+height(i)-1,xmin(i):xmin(i)+width(i)+1,:));
	fullBackGray = rgb2gray(backcrop);
   
	% Read in video files for specific school and date
	videoFiles = char(strcat('/Volumes/Seagate/SAMPLING_DIR/_DATES_DIRS/',school,'/', date,'/*.avi'));
	
	videoDirectory = struct2cell(dir(videoFiles));
	vidnames = videoDirectory(1,:);
	
	resultFile = fopen('/Users/austin/Desktop/BackSub/Washing_Results.txt','a');
	% If date file is empty:
	if isempty(vidnames) == 1
		%resultFile = fopen('/project/vipcnns/Ghana-Project/Washing_Results.txt','at');
		fprintf(resultFile,'There are no videos for %s on %s. \n ',[string(school), string(date)]);
		fclose(resultFile);
	else
		
		DayTotal = 0;
		for n = 1:length(vidnames)  % for every video file of specific date

			fpath = strsplit(videoFiles,'*');
			fpath = fpath{1};
			sname = strcat(fpath,vidnames{n});
			v = VideoReader(sname);
			% ADD IN CROSS CHECK WITH GOOD FILE LIST TO AVOID DAMAGED VIDEOS 
		
	
			events = zeros(1,v.Duration*20);
			fnum=0;
			while hasFrame(v)
				fnum=fnum+1;
				frame = rgb2gray(readFrame(v)); % Grayscale ROI
				frameROI = frame(ymin(i):ymin(i)+height(i)-1,xmin(i):xmin(i)+width(i)+1,:);
				notpitchblack = frameROI > 3; % ignore jet black rope
				imdiff = imabsdiff(frameROI,fullBackGray);
				threshold1 = 55; % max pixel intensity
				highvals = frameROI < threshold1;
				threshold2 = 40; % diff threshold
				imdiff(imdiff<threshold2)=0;
				bwdiff = imbinarize(imdiff);
				bwdiff = bwdiff.*highvals.*notpitchblack;
				threshold3 = 0.079; % percentage of white pixels
				events(fnum) = sum(bwdiff(:)) > (threshold3*numel(bwdiff));
				
				%origwriteto = sprintf('./diffs/aOrig_%d.png',fnum);
				%imwrite(frameROI,origwriteto);
				%writeto = sprintf('./diffs/frame_%d.png',fnum);
				%imwrite(bwdiff,writeto);

				%fprintf('#%d:   event: %d\n', fnum, events(fnum));    
			end
			%imwrite(fullBackGray,'./diffs/FULLBLACKGRAY.png');
			
			
			% TO ADD LATER:
			% can make this better by also keeping track of how many
			% 0's in between groupings of 1's and making sure that's above
			% another threshold so it doesn't just represent a glitch
			
			% Count Events
			EventCount = 0;
			subcount = 0;
			N = 5; % quarter second threshold
			
			for e=1:length(events) % events is a binary array
				if (events(e) == 1) && (subcount == 0)
					subcount = 1;
				elseif events(e) == 1 
					subcount = subcount + 1;
				elseif (events(e) == 0) && (subcount > N)
					EventCount = EventCount + 1;
					subcount = 0;
				elseif (events(e) == 0) && (subcount <= N)
					subcount = 0;
				else
					disp('Oops, should not get here!');                  
				end
			end
			%if subcount > N % catch handwashing events at very end of vid
			%    EventCount = EventCount + 1;
			%end
			
			% this is iffy because half the kids just wipe the soap
			% rather than pick-up/put-down
			EventCount = round(EventCount/2);
			
			% bad count: too high to be realistic, probably very dark video
			% may change this to 3 or 4
			if EventCount > 2 
				EventCount = 0;
			end
			
			DayTotal = DayTotal + EventCount;
			fprintf('%s: %d\n', vidnames{n}, EventCount);
 
			%{
			threshold1 = 90;
			subplot(5,1,1);
			imshow(frameROI);
			title('original ROI grayscale');
			subplot(5,1,2);
			imshow(fullBackGray);
			title('background ROI grayscale');
			subplot(5,1,3);
			imshow(imdiff);
			title('absolute difference grayscale');
			subplot(5,1,4);
			imdiff(imdiff<threshold1)=0;
			imshow(imdiff);
			title('difference thresholded');
			bwdiff = imbinarize(imdiff);
			subplot(5,1,5);
			imshow(bwdiff);
			title('difference binarized');
			%}
			
		end 
		fprintf('\n\nTotal over entire day: %d\n\n', DayTotal); 
	end	
end

% sound to signify code has finished running
load train.mat;
sound(y); toc

% MORE THINGS TO TRY OUT:
% - splitting it over two sections, might cause problems without some
% adjustments though
% - possibly just make max count per video == 1 like wade was saying,
% doesn't sound as great but might help more than hurt by avoiding errors
% - creating a list of manual counts and crossvalidating threshold values
% to find the argmin's of the count differences



