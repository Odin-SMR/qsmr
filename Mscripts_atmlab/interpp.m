%------------------------------------------------------------------------
% NAME:    interpp
%
%          Makes log-linear interpolation. That is, the x-dimension is
%          converted to log before doing the interpolation.
%
%          The profiles are assumed to be constant outside the end points.
%
%          A typical application of the function is interpolation of
%          atmospheric vertical profiles.
%
% FORMAT:  X = interpp(pp,Xp,p)
%
% RETURN:  X          interpolated profiles
% IN:      pp         original pressure levels
%          Xp         original profiles
%          p          new pressure levels 
%------------------------------------------------------------------------

% HISTORY: 2005-05-11  Moved to Atmlab by PE.
%          2000-01-04  Moved from Norns to AMI
%          1999-11-02  Created by Patrick Eriksson.


function X = interpp(pp,Xp,p)

pp	= vec2col(pp);
np	= length(pp);

assert( size(Xp,1) == np );

X	= interp1([1e3;log(pp);-1e3],[Xp(1,:);Xp;Xp(np,:)],log(p));

