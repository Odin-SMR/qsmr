% Q2_INIT   Initialises the Qsmr system
%
%   The following operations are performed:
%     * Checks if Atmlab and Qsmr are part of Matlab's search path.
%     * Checks if expected versions of Atmlab and ARTS are used
%     * Adds folder information to R
%
%   It should suffice to call this function just once during a session.
%
% FORMAT   R = q2_init
%        
% OUT   R   A start to a R structure.

% 2015-12-17   Patrick Eriksson.

function R = q2_init


%- Check if Qsmr itself is at hand
%
if ~exist( 'q_std', 'file' )
  error( 'It seems that Qsmr is not added to the search path.' );
end


%- Check Atmlab 
%
S = system_settings;
%
if ~exist( 'atmlab_init', 'file' )
  error( 'It seems that Atmlab is not added to the search path.' );
end
%
if ~isnan(S.ATMLAB_VERSION) & ~strcmp( atmlab_version, S.ATMLAB_VERSION )
  error( 'Atmlab version deviates from selected.' );
end


%- Check ARTS
%
if ~isnan(S.ARTS_VERSION) & ~strcmp( arts_version, S.ARTS_VERSION )
  error( 'ARTS version deviates from selected.' );
end

