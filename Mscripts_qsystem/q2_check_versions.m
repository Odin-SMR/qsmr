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
changelog = fullfile( q2_topfolder, 'ChangeLog' );
%
fid = fileopen( changelog );
for i = 1 : 3
  m = fgets( fid );
end
fileclose( fid );
%
i = find( m == '*' );
if isempty(i)
  error( 'Something failed when parsing qsmr''s ChangeLog.' );
end
    
v = strtrim( m([1:i-1 i+1:end]) );
%
if ~strcmp( v, Q.VERSION_QSMR )
  error( 'Incorrect Qsmr version (expected %s, but %s found)', ...
         Q.VERSION_QSMR, v); 
end
