clc;
%% Read from text file 
%  out = vidsample('VID0002.AVI');


%%

posFile = fopen('RectPosition.txt');
% for i = 1:feof(posFile)
[filename,M,D,Y,xmin,ymin,width,height] = textread('RectPosition.txt',...
                                            '%s %d %d %d %d %d %d %d',6)
% end
% xmin,ymin are top left corner of imrect, width and height descripe size
% of rectangle

% Set up rectangle position
%pos = [xmin, ymin, width, height];
background = VideoReader('VID0001.AVI');
v = VideoReader('VID0002.AVI');
vout = VideoWriter('subtracted.AVI');

vout.open()
 while v.hasFrame
    frame = readFrame(v);
    backframe = readFrame(background);
    crop = deal(frame([ymin(6) : 1 : ymin(6)+height(6)-1],...
            [xmin(6) : 1 : xmin(6)+width(6) +1],:));
    backcrop = deal(backframe([ymin(6) : 1 : ymin(6)+height(6)-1],...
            [xmin(6) : 1 : xmin(6)+width(6) +1],:));
        
    subtract = crop - backcrop;
    vout.writeVideo(subtract);
    
%     figure(1)
%     subplot(2,2,1)
%     imshow(crop)
%     subplot(2,2,2)
%     imshow(backcrop)
%     subplot(2,2,3)
%     imshow(subtract)
   
 end
 vout.close();
 
 implay(vout)
 
