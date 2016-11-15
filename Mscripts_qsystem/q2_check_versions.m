% Q2_CHECK_VERSIONS   Confirms that correct ARTS and Qsmr version used
%
% FORMAT   q2_check_versions(Q)

% 2016-11-10 Patrick Eriksson


function q2_check_versions(Q)


%- ARTS
%
[s,m] = system( [ Q.ARTS, ' -v' ] );
%
if s
  error( 'Something failed when doing arts -v.' );
end
%
v = strtrim( m(1:13) );
%
if ~strcmp( v, Q.VERSION_ARTS )
  error( 'Incorrect ARTS version (expected %s, but %s found)', ...
         Q.VERSION_ARTS, v); 
end


%- Qsmr
%
v = q2_version;
%
if ~strcmp( v, Q.VERSION_QSMR )
  error( 'Incorrect Qsmr version (expected %s, but %s found)', ...
         Q.VERSION_QSMR, v); 
end
