%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Name: Vineet Pandey
%Date: 10/7/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Main program
clear all
close all
movieObjInput = VideoReader('fiveCCC.wmv'); % open file
get(movieObjInput) % display all information about movie
nFrames = movieObjInput.NumberOfFrames;
%% Open output movie.
 movieObjOutput = VideoWriter('myResults.mp4', 'MPEG-4'); % open file.Input the name of the video file containing the CCs
 open(movieObjOutput);
% Get picture to insert onto target.
Img_ins = imread('illuminati.jpg'); % Image that should be placed
% These are the points in the model's coordinate system (inches), in
% the same order as the detected points; ie UL,UM,UR,LL,LR. Each column is
% a point in the form X;Y;Z;1.
P_M = [
0 3.7 7.4 0 7.4;
0 0 0 4.55 4.55;
0 0 0 0 0;
1 1 1 1 1 ];
P_M(1,:) = P_M(1,:) - 3.7; % moving the origin to the center
P_M(2,:) = P_M(2,:) - 4.55/2;
%% camera parameters
f = 531; % focal length in pixels
cx = 320;
cy = 240;
K = [ f 0 cx; 0 f cy; 0 0 1 ]; % intrinsic parameter matrix
%% initial guess of the pose [ax ay az tx ty tz].
x = [0; 0.0; 0.0; 0; 0; 50];
for iFrame=1:nFrames
I = read(movieObjInput,iFrame); % getting one image
fprintf('Frame %d\n', iFrame);

%% Finding all the targets.
targets = findCCC(I);
nCCC = size(targets,2); % Skipping image if not enough targets
if nCCC < 5 continue;
end
%% Finding correspondences.
targets = findCorrespondence(targets); % Finding the correspondence of the targets
%% Determining the pose.
% Create the vector of measurements, as a single column vector 
y0 = [];
for i=1:5
p = targets(:, i);
y0 = [y0; p(1); p(2)];
end
%% Getting the predicted image points by substituting in the current pose
y = predictedPoints(x, P_M, K);
for i=1:10
% Get predicted image points
y = predictedPoints(x, P_M, K);
% Determining the Jacobian
e = 0.00002; % arbitrary tiny number
J(:,1) = ( predictedPoints(x+[e;0;0;0;0;0],P_M,K) - y )/e;
J(:,2) = ( predictedPoints(x+[0;e;0;0;0;0],P_M,K) - y )/e;
J(:,3) = ( predictedPoints(x+[0;0;e;0;0;0],P_M,K) - y )/e;
J(:,4) = ( predictedPoints(x+[0;0;0;e;0;0],P_M,K) - y )/e;
J(:,5) = ( predictedPoints(x+[0;0;0;0;e;0],P_M,K) - y )/e;
J(:,6) = ( predictedPoints(x+[0;0;0;0;0;e],P_M,K) - y )/e;
% Error observed in image points - predicted image points
dy = y0 - y;
% Solving for dx using the pseudo inverse
dx = pinv(J) * dy;
% Condition if parameters are no longer changing
if abs( norm(dx)/norm(x) ) < 1e-6
break;
end
x = x + dx; % Updating the pose estimate
end
% Insert picture onto target.
% Get list of corresponding points. The four corners are in the order

Pts1 = [
1, 1;
size(Img_ins,2), 1;
1, size(Img_ins,1);
size(Img_ins,2), size(Img_ins,1)];
Pts2 = [
targets(1,1), targets(2,1);
targets(1,3), targets(2,3);
targets(1,4), targets(2,4);
targets(1,5), targets(2,5)];
T12 = fitgeotrans(Pts1, Pts2, 'projective');
I1warp = imwarp(Img_ins, T12, 'OutputView',imref2d(size(I), [1 size(I,2)], [1 size(I,1)]));
% Combining the pictures
Icombined = (I .* uint8(I1warp==0)) + I1warp;

% Show the image.
figure(1), imshow(Icombined,[]);
% Drawing coordinate axes on the image. Scaling the length of the axes
% according to the size of the model.
W = max(P_M,[],2) - min(P_M,[],2); % Size of model in X,Y,Z
W = norm(W); % Length of the diagonal of the bounding box
u0 = predictedPoints(x, [0;0;0;1], K); % origin
uX = predictedPoints(x, [W/5;0;0;1], K); % unit X vector
uY = predictedPoints(x, [0;W/5;0;1], K); % unit Y vector
uZ = predictedPoints(x, [0;0;W/5;1], K); % unit Z vector
line([u0(1) uY(1)], [u0(2) uY(2)], 'Color', 'g', 'LineWidth', 2);
line([u0(1) uZ(1)], [u0(2) uZ(2)], 'Color', 'b', 'LineWidth', 2);
line([u0(1) uX(1)], [u0(2) uX(2)], 'Color', 'r', 'LineWidth', 2);
% frame number and pose on the video.
text(20,40,sprintf('Frame %d ax=%.2f ay=%.2f az=%.2f tx=%.1f ty=%.1f tz=%.1f',iFrame, x(1), x(2), x(3), x(4), x(5), x(6)),'BackgroundColor', 'w','FontSize', 10); 
newFrameOut = getframe;
writeVideo(movieObjOutput,newFrameOut);
pause(0.01);
end
 close(movieObjOutput); % all done, close file