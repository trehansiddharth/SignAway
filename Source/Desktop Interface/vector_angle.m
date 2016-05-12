function [ theta ] = vector_angle( v )
% Calculates the angle between a vector and the x-axis, measured
% counter-clockwise and between 0 and 2*pi

theta = atan2(v(2), v(1));

end

