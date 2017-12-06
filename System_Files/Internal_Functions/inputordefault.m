function [out, inps] = inputordefault(keyname, defval, inps)
% out = inputordefault(keyname, defval, inps)
% Parses a cell array (usually varargin) looking for a string which matches 
% the keyname and then assigns out to the value of the next element of the
 % input if it finds it otherwise assignes it to the default value.
 % E.g. sessid = inputordefault('sessid', 0, varargin)

 ind = strcmpi(keyname, inps(1:2:end));
 % is the keyname in the inputs? Look only at the odd elements of inps, since this keyname could be a value of another input.
 if any(ind)
 	out = inps{2*find(ind)};
 	inps(2*find(ind)-1:2*find(ind)) = [];  % erase these from the list.
 else
 	out = defval;
 end

end

