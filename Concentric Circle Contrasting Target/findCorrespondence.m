function targetOutput = findCorrespondence(targets)
nCCC = size(targets,2);
assert(nCCC >= 5);
id_Midpoint = zeros(nCCC,nCCC);
d_Midpoint = Inf(nCCC,nCCC);

for i=1:nCCC
    
for j=i+1:nCCC
P_mid = (targets(:, i) + targets(:, j))/2; 
d = Inf(nCCC,1); 

for k=1:nCCC   
if k==i || k==j continue;   
end
d(k) = norm(P_mid-targets(:, k));
end
[d_min,k] = min(d);
d_Midpoint(i,j) = d_min;
id_Midpoint(i,j) = k;
end
[i1,i3] = find(d_Midpoint == min(d_Midpoint(:)));
i2 = id_Midpoint(i1,i3);
dist = Inf(1,nCCC); 
for i=1:nCCC
if (i ~= i1) && (i ~= i2) && (i ~= i3)
dist(i) = norm(targets(:,i) - targets(:,i1));
end
end
[~,i4] = min(dist);
dist = Inf(1,nCCC); 
for i=1:nCCC
if (i ~= i1) && (i ~= i2) && (i ~= i3)
dist(i) = norm(targets(:,i) - targets(:,i3));
end
end
[~,i5] = min(dist);
end
M = [ targets(:,i4)-targets(:,i1) targets(:,i3)-targets(:,i1) ];
if det(M) < 0
id_targets(1) = i1; % UL
id_targets(2) = i2; % UM
id_targets(3) = i3; % UR;
id_targets(4) = i4; % LL;
id_targets(5) = i5; % LR;
else
id_targets(1) = i3; % UL
id_targets(2) = i2; % UM
id_targets(3) = i1; % UR;
id_targets(4) = i5; % LL;
id_targets(5) = i4; % LR;
end
targetOutput(:,1) = targets(:,id_targets(1));
targetOutput(:,2) = targets(:,id_targets(2));
targetOutput(:,3) = targets(:,id_targets(3));
targetOutput(:,4) = targets(:,id_targets(4));
targetOutput(:,5) = targets(:,id_targets(5));
return

