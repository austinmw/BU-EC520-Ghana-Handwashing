% Austin Welch
% EC520 Project

% WARNING: WILL TAKE >SEVERAL< HOURS TO RUN! 
% ~3s/vid * ~30K videos = 1500 mins = 25 HOURS!

% This code will navigate directories, subsample videos into frames,
% combine the frames into new videos, and place this new videos in a
% different directory

% After running this, will need to run a script that traverses directories
% of subsampled videos, merges these videos, and places them all in a
% single directory

clear; clc;
% PLACE AND RUN IN 'SAMPLING_DIR'

% input directory
fullvidsSubDirectory = 'FULL_VIDS'; % change to '_DATES_DIRS'
% output directory
subsampledSubDirectory = 'SUBSAMPLED'; % change to 'INDIVIDUAL_SUBSAMPLES'

% top dir
files = dir; % get directories
top = files.folder;
top = strcat(top,'/');
% append input dirs to top path
fullvidsDir = strcat(top,fullvidsSubDirectory,'/');
subvidsDir = strcat(top,subsampledSubDirectory,'/');
% school names/m_d names
files = dir(fullvidsDir);
schoolNames = {files([files.isdir]).name};
schoolNames = schoolNames(~ismember(schoolNames,{'.','..','.DS_Store'}));
firstschoolDirs = strcat(fullvidsDir,schoolNames(1),'/');
files_m_d = dir(firstschoolDirs{1});
monthDayNames = {files_m_d([files_m_d.isdir]).name};
monthDayNames = monthDayNames(~ismember(monthDayNames,{'.','..', ...
    '.DS_Store'}));


% get source and destination paths
sourcePaths = cell(length(schoolNames),length(monthDayNames));
destPaths = cell(length(schoolNames),length(monthDayNames));
for i=1:length(schoolNames)
    for j=1:length(monthDayNames) 
        sourcePaths{i,j} = strcat(fullvidsDir,schoolNames{i},'/', ...
            monthDayNames{j},'/');
        destPaths{i,j} = strcat(subvidsDir,schoolNames{i},'/', ...
            monthDayNames{j},'/');   
    end
end

% find videos, concat src and dst dirs, subsample each
for s=1:length(schoolNames) % loop through schools
    for d=1:length(monthDayNames) % loop through month_day directories
        tic
        % find all video file names directory
        f = dir(sourcePaths{s,d});
        vidNames = {f.name};
        % might need to add other hidden files..
        vidNames = vidNames(~ismember(vidNames,{'.','..','.DS_Store'}));
        % full source paths
        vidSrcPaths = cell(1,length(vidNames));
        vidDstPaths = cell(1,length(vidNames));   
        % loop through every video
        for i=1:length(vidNames)  
           vidSrcPaths{i} = strcat(sourcePaths{s,d},vidNames{i}); 
           vidDstPaths{i} = strcat(destPaths{s,d},vidNames{i});
           % call subsampler function
           subsampler(vidSrcPaths{i},vidDstPaths{i},20,100); 
           fprintf('\t\tfinished %s\n',vidNames{i});
        end
        fprintf('\tfinished %s:%s\n', schoolNames{s}, monthDayNames{d});
        fprintf('\t took %0.2f seconds\n',toc);
    end
    fprintf('finished subsampling %s\n\n', schoolNames{s});     
end

% finished
fprintf('\n\n\nDONE!!\n\n');