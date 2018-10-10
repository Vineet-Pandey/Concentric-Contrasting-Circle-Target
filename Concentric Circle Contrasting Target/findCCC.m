function targets = findCCC(I)
if size(I,3) > 1
G = rgb2gray(I);
end
W = im2bw(G, graythresh(G)); 
S = strel('disk',1, 0);
W2 = imopen(W,S);
B = ~W2; 
B2 = B;
[LW, nw] = bwlabel(W2);
[LB, nb] = bwlabel(B2);
blobsWhite = regionprops(LW, 'BoundingBox', 'Centroid', 'Area');
blobsBlack = regionprops(LB, 'BoundingBox', 'Centroid', 'Area', 'Perimeter');

%Finding CCCs
nCCC = 0; 
for iw=1:nw
for ib=1:nb
bc = blobsBlack(ib).Centroid;
wc = blobsWhite(iw).Centroid;
if ~(norm(bc-wc) < 1.0) continue; 
end
if ~(blobsBlack(ib).Area > blobsWhite(iw).Area)
continue;
end
nCCC = nCCC + 1;
targets(:, nCCC) = [bc(1); bc(2)];
end 
end
return
