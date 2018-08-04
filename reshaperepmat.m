function [outX,outY] = reshaperepmat(listx,listy)

% Sort 1:nx : 111...222...333... 
% Sort 1:ny : 123...123...123...

nx = numel(listx);
ny = numel(listy);

outX = reshape((repmat((listx)',1,ny))',1,nx*ny);
outY = repmat((listy),1,nx);