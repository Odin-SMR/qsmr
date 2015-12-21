function S = system_settings

% ARTS version expected
%
S.ARTS_VERSION     = 'arts-2.3.394';


% ATMLAB version expected
%
S.ATMLAB_VERSION   = 'atmlab-2.3.140';


% During development use this, that deactivates check of exact version  
%
[S.ARTS_VERSION,S.ATMLAB_VERSION] = deal( NaN );

