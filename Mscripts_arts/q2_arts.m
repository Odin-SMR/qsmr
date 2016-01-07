% Q2_ARTS   Executes ARTS
%
%    The ARTS executable is assumed to be called arts4smr. The executable
%    must be in the general search path. 
%
%    A Matlab error is issued if any ARTS or system error occur.
%
% FORMAT   result = q2_arts( argstring )
%
% IN   argstring   String holding all command line arguments
% OUT  result      Screen output tex.

% 2016-01-07   Patrick Eriksson

function result = q2_arts( argstring )
  
  
[status,result] = system( ['arts4smr ',argstring] );


if status
  disp( result );
  error('An error occured while executing ARTS. See above.')
end