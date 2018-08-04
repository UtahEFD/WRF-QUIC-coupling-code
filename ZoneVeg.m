function VegLayer = ZoneVeg(V)

%%% INPUT : Limitations of a vegetation area, in QUIC's coordinate
%%% OUTPUT : Grid points coordinates where a vegetation block will be added
%%% to generate the canopy layer

MaxX = max(V(1,:));
MinX = min(V(1,:));
MaxY = max(V(2,:));
MinY = min(V(2,:));

%%% Left X
[~,indexminX]= min(V(1,:));
V1 = V(:,indexminX);
V(:,indexminX) = [];
%%% Right X
[~,indexmaxX]= max(V(1,:));
V4 = V(:,indexmaxX);
V(:,indexmaxX) = [];
%%% Upper Y
[~,indexmaxY]= max(V(2,:));
V2 = V(:,indexmaxY);
V(:,indexmaxY) = [];
%%% Lower Y
V3 = V;

V = [V1,V2,V3,V4];

A12 = (V(2,2)-V(2,1))/(V(1,2)-V(1,1)); B12 = V(2,2)-A12*V(1,2);
A13 = (V(2,3)-V(2,1))/(V(1,3)-V(1,1)); B13 = V(2,3)-A13*V(1,3);
A42 = (V(2,4)-V(2,2))/(V(1,4)-V(1,2)); B42 = V(2,2)-A42*V(1,2);
A43 = (V(2,4)-V(2,3))/(V(1,4)-V(1,3)); B43 = V(2,3)-A43*V(1,3);

Xpts = [];
Ypts = [];

for X = MinX:MaxX
    for Y = MinY:MaxY
        if Y<=X*A12 + B12...
           && Y>=X*A13 + B13 ...
           && Y<=X*A42 + B42 ...
           && Y>=X*A43 + B43
            Xpts = [Xpts X];
            Ypts = [Ypts Y];
        end
    end
end

VegLayer = [Xpts;Ypts];
