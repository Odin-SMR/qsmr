% Q2_CHECK_Q   Performs basic checks of the Q structure
%
%   The following checks are performed:
%
%     1. If Q only contains recognised fields, and that all fields 
%        are included.
%     2. That correct versions of Atmlab and ARTS are being used.
%
% FORMAT   q2_check_q(Q,R)
%        
% IN    Q   The Q structure to be used.
%       R   The R structure (with R.FOLDER_SETTINGS set).

% 2015-05-18   Patrick Eriksson.

function q2_check_q(Q,R)

  
%-----------------------------------------------------------------------------
%--- Part 1
%-----------------------------------------------------------------------------  

%- Read RST documentation 
%
[s,res] = system( ['rst2latex ', ...
                   fullfile( R.FOLDER_SETTINGS, 'q_fields.rst' ) ] );
%
if s > 0
  error( 'Error while reading q_fields.rst.' );
end
  

%- Extract defined fields
%
startstring = '\item[{';
endstring   = '}] \leavevmode';
%
i1 = strfind( res, startstring );
i2 = strfind( res, endstring );
%
if length(i1) ~= length(i2)
  error( 'Could not locate fields in q_fields.rst.' );
end
%
for i = length(i1):-1:1
  F{i} = res( i1(i)+length(startstring):i2(i)-1 );
  F{i} = strrep( F{i}, '\_', '_' );
end


% Check if Q contains all defined fields
%
for i = 1 : length(F)
  if ~isfield( Q, F{i} )
    error( 'At least the field *%s* is missing in Q.', F{i} );
  end
end


% Check if Q contains any undefined field
%
QF = fieldnames(Q);
%
if length(F) ~= length(QF) 
  for i = 1 : length(QF)
    if ~any( strcmp(QF{i}, F ) )
      error( 'At least the field *%s* of Q is undefined.', QF{i} );
    end
  end
end



%-----------------------------------------------------------------------------
%--- Part 2
%-----------------------------------------------------------------------------  

if ~strcmp( atmlab_version, Q.ATMLAB_VERSION )
  error( 'Atmlab version deviates from selected.' );
end

if ~strcmp( arts_version, Q.ARTS_VERSION )
  error( 'ARTS version deviates from selected.' );
end

