function [iv1, iv2] = find_common_time(t1, t2, interval)

% find_common_time For which segments do the time arrays overlap?
%
% Given two vectors, gives the interval in which both overlap, +/- an
% interval.
%
% FORMAT
%
%   [iv1, iv2] = find_common_time(t1, t2, interval)
%
% IN
%
%   t1       vector     First time axis
%   t2       vector     Second time axis
%   interval number     Maximum difference to consider overlap
%
% OUT
%
%   iv1      logical    Segment of t1 overlapping with t2    
%   iv2      logical    Segment of t2 overlapping with t1
%
% $Id$

if isempty(t1) || isempty(t2)
    iv1 = true(size(t1));
    iv2 = true(size(t2));
    return
end

t1f = t1(1);
t1l = t1(end);
t2f = t2(1);
t2l = t2(end);

total_first = max([t1f t2f]) - interval;
total_last = min([t1l t2l]) + interval;

iv1 = (t1>total_first) & (t1<total_last);
iv2 = (t2>total_first) & (t2<total_last);

iv1(find(iv1, 1, 'first'):find(iv1, 1, 'last')) = true;
iv2(find(iv2, 1, 'first'):find(iv2, 1, 'last')) = true;