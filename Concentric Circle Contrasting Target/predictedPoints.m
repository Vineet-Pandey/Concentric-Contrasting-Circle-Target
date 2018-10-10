function p = predictedPoints(x, P_M, K)
% Projecting 3D points onto image
% Get pose parameters
ax = x(1); ay = x(2); az = x(3);
tx = x(4); ty = x(5); tz = x(6);
% Rotation matrix (model to camera)
Rx = [ 1 0 0; 0 cos(ax) -sin(ax); 0 sin(ax) cos(ax)];
Ry = [ cos(ay) 0 sin(ay); 0 1 0; -sin(ay) 0 cos(ay)];
Rz = [ cos(az) -sin(az) 0; sin(az) cos(az) 0; 0 0 1];
R = Rz * Ry * Rx;
% Extrinsic camera matrix
Mext = [ R [tx;ty;tz] ];
% Project points
ph = K*Mext*P_M;
% Divide through 3rd element of each column
ph(1,:) = ph(1,:)./ph(3,:);
ph(2,:) = ph(2,:)./ph(3,:);
ph = ph(1:2,:); % Get rid of 3rd row
p = reshape(ph, [], 1);
return