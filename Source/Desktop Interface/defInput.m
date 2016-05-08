function [ result ] = defInput( prompt, default )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

result = input(strcat(prompt, ' [', default, ']: '))
if isempty(result)
    result = default;
end
end

