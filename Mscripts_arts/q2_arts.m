% Q2_ARTS   Executes ARTS
%
%    A Matlab error is issued if any ARTS or system error occur.
%
% FORMAT   result = q2_arts( Q, argstring )
%
% OUT  result      Screen output tex.
% IN   Q           Q structure.
%      argstring   String holding all command line arguments

% 2016-01-07   Patrick Eriksson

function result = q2_arts( Q, argstring )
  
  
[status,result] = system( [Q.ARTS,' ',argstring] );


if status
  error( ['Error when running ARTS:',sprintf('\n'),result] );
end
