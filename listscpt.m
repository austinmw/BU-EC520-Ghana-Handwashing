clear; clc;


% DOES NOT INCLUDE FIRST 5 SCHOOLS!


% all vids that didnt error out
gfid = fopen('completedlist.txt');
goodvids = textscan(gfid,'%s','Delimiter','\n');
goodvids = goodvids{1};
goodvids = unique(goodvids);
size(goodvids)

% vids caught by error checking
bfid = fopen('badlist.txt');
badvids = textscan(bfid,'%s','Delimiter','\n');
badvids = badvids{1};
badvids = unique(badvids);
size(badvids)

% vids that didnt error - vids that didnt pass try/catch block
% == all good vids to process
processlist = setdiff(goodvids,badvids);

fileP = fopen('processlist.txt','w');
fprintf(fileP,'%s\n',processlist{:});
fclose(fileP);