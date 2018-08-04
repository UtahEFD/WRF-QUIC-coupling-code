function T = UTC2epoch(X)

%%% Converts UTC time expressed in a particular format, to EPOCH time in seconds

V = datevec(X);

T = round(8.64e4 * (datenum(V(1),V(2),V(3),V(4),V(5),V(6)) - datenum('1970', 'yyyy')));
