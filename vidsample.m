clear; clc;

vin = VideoReader('vid1.avi');
vout = VideoWriter('vid-out.mp4');
framenum = 0;
everyNframe = 100;
vout.open();
while vin.hasFrame
    frame = vin.readFrame;
    if rem(framenum,everyNframe) == 0
        vout.writeVideo(frame);
        % OR
        imwrite(frame, [num2str(framenum,'%04i') '.jpg']);
        disp(framenum)
    end
    framenum = framenum + 1;
end
vout.close();
