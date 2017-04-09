function subsampler(src,dst,framerate,subrate)
% most likely values:
% framerate: 20
% subrate: 100

    vin = VideoReader(src);
    vout = VideoWriter(dst);
    vout.FrameRate = framerate;
    everyNframe = subrate;
    framenum = 0;

    vout.open();
    while vin.hasFrame
        try 
            frame = vin.readFrame;
            if rem(framenum,everyNframe) == 0
                vout.writeVideo(frame);
                %imwrite(frame, [num2str(framenum,'%04i') '.jpg']);
                %disp(framenum)
            end
            framenum = framenum + 1;
        catch ME
            fprintf('CAUGHT EXCEPTION: DAMAGED VIDEO!\n');
            break 
        end
            % maybe save list of of/delete broken videos later
    end
    vout.close();
end

