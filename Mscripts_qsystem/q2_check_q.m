% Q2_CHECK_Q   Performs basic checks of the Q structure
%
%   The following checks are performed:
%
%     1. If Q only contains recognised fields, and that all fields 
%        are included.
%     2. That correct versions of Atmlab and ARTS are being used.
%
% FORMAT   r = q2_check_q(Q,R)
%        
% OUT   r   A report string. Empty if all OK.
% IN    Q   The Q structure to be used.
%       R   The R structure (with R.FOLDER_SETTINGS set).

% 2015-05-18   Patrick Eriksson.

function r = q2_check_q(Q,R)

  
%- Init error reporting
%
r = [];
mfile = upper( mfilename );


%-----------------------------------------------------------------------------
%--- Part 1
%-----------------------------------------------------------------------------  

%- Read RST documentation 
%
[s,res] = system( ['rst2latex ', ...
                   fullfile( R.FOLDER_SETTINGS, 'q_fields.rst' ) ] );
%
if s > 0
  r = 'Error while reading q_fields.rst.';
  if nargout
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
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
  r = 'Could not locate fields in q_fields.rst.';
  if nargout
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
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
    r = sprintf( 'At least the field *%s* is missing in Q.', F{i} );
    if nargout
      r = sprintf( '%s: %s', mfile, r );
      return;
    else
      error( r );
    end
  end
end


% Check if Q contains any undefined field
%
QF = fieldnames(Q);
%
if length(F) ~= length(QF) 
  for i = 1 : length(QF)
    if ~any( strcmp(QF{i}, F ) )
      r = sprintf( 'At least the field *%s* of Q is undefined.', QF{i} );
      if nargout
        r = sprintf( '%s: %s', mfile, r );
        return;
      else
        error( r );
      end 
    end
  end
end



%-----------------------------------------------------------------------------
%--- Part 2
%-----------------------------------------------------------------------------  

if ~strcmp( atmlab_version, Q.ATMLAB_VERSION )
  r = 'Atmlab version deviates from selected.';
  if nargout
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
end

if ~strcmp( arts_version, Q.ARTS_VERSION )
  r = 'ARTS version deviates from selected.';
  if nargout
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
end

