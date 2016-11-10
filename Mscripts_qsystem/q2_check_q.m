% Q2_CHECK_Q   Performs basic checks of the Q structure
%
%   The function tests if Q only contains recognised fields, and that all
%   fields are included.
%
% FORMAT   q2_check_q(Q)
%        
% IN    Q   The Q structure to be checked.

% 2015-05-18   Patrick Eriksson.

function q2_check_q(Q)

  
%- Read RST documentation 
%
[s,res] = system( ['rst2latex ', fullfile( q2data_topfolder, ...
                                           'Settings', 'q_fields.rst' ) ] );
%
if s > 0
  error( 'Error while scanning q_fields.rst: %s', res );
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
qfields = fieldnames( Q );
mfields = setdiff( F, qfields );
%
for i = 1 : length(mfields)
  fprintf( 'The field %s is missing in Q.\n', mfields{i} );    
  error( 'At least one field is missing in Q.' );
end


% Check if Q contains any undefined field
%
mfields = setdiff( qfields, F );
%
for i = 1 : length(mfields)
  fprintf( 'The field %s of Q is not defined.\n', mfields{i} );    
  error( 'At least one undefined field in Q.' );
end



