function dates = daterange(date1, date2)

% daterange Returns a matrix of valid dates within the daterange
%
% FORMAT
%
%   dates = daterange(date1, date2)
%
% IN
%
%   date1   array   Starting date
%   date2   array   Ending date
%
% OUT
%
%   dates   Nxlength(date1) Matrtix  All dates in the range
%
% NOTE
%
%  If 4th element of date (hour) is given, any missing minute or hour is assumed to be 0
%
% FORMAT
%
%   dates = daterange(date1, date2)
%
%
% $Id: daterange.m 8570 2013-08-10 18:36:48Z seliasson $

errId = ['atmlab' mfilename ':badInput'];
assert(length(date1)==length(date2),errId,...
    'length(date1)~=length(date2)')

dl = length(date1);

if dl ==2
    date1(3) = 1;
    date2(3) = 1;
end
% datenum wants length(date) ==3 or ==6
if dl > 3
    % fill missing with 0
    date1(end+1:6) = 0;
    date2(end+1:6) = 0;
end
dn1 = datenum(date1);
dn2 = datenum(date2);

switch dl
    case 2
        dates = datevec(dn1:dn2);
        dates = unique(dates(:, 1:2),'rows'); % only year/month/day part
    case 3
        dates = datevec(dn1:dn2);
        dates = dates(:, 1:3); % only year/month/day part
    case 4
        dates = datevec(dn1:1/24:dn2); %hour steps
        dates = dates(:, 1:4);
        
    case 5
        dates = datevec(dn1:1/(24*60):dn2); %minute steps
        dates = dates(:, 1:5);
    case 6
        dates = datevec(dn1:1/(24*3600):dn2); %seconds steps
    
    otherwise
        error(errId,'datevector lengths=%d is not supported',dl)    
end

end
