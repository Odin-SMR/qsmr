function t = compensate_wraparound(t)

% compensate_wraparound Correct for different CS/MHS time measurements
%
% Several datasets store time in (milli)seconds since the start of the day
% (UTC). When an orbit crosses the date boundary, some of the times will be
% close to 86400 whereas some will be close to 0. This function corrects
% for that affect by adding 86400 to whatever element of the vector is
% smaller than the first one. Like this, time differences between different
% measurements can be more easily calculated. The time has to be in
% seconds, so to use this for AMSU data, one needs to convert from
% milliseconds before passing it here.
%
% FORMAT
%
%   t = compensate_wraparound(t)
%
% IN
%
%   t   vector      time vector
%
% OUT
%
%   t   vector      time vector
%
% $Id$

if isempty(t)
    return
end
wraparound = t < t(1);
t(wraparound) = t(wraparound) + 86400;
