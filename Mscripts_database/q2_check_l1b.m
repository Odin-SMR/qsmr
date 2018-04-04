% Q2_CHECK_L1B   Basic consistency check of L1B and Q
%
%    Performs only basic, non-costly, checks.
%
% FORAMT  q2_check_l1b( L1B, Q )
%
% IN   L1B   L1B structure.
%      Q     Q structure for expected frequency mode.

% 2015-12-21   Patrick Eriksson

function q2_check_l1b( L1B, Q )

% Frequency mode
%
if length(unique( L1B.FreqMode )) > 1
  error( 'The L1B data can just contain a single frequency mode.' );
end
%
if L1B.FreqMode(1) ~= Q.FREQMODE
  error( 'Different frequency mode in L1B and Q (%d rep. %d).', ...
         L1B.FreqMode(1), Q.FREQMODE );
end


% Frontend
%
if any( L1B.Frontend ~= Q.FRONTEND_NR )
  error( 'Different frontend in L1B and Q (%d resp. %d).', ...
         L1B.Frontend(1), Q.FRONTEND_NR );
end


% Backend
%
if any( L1B.Backend ~= Q.BACKEND_NR )
  error( 'Different frontend in L1B and Q (%d rep. %d).', ...
         L1B.Frontend(1), Q.BACKEND_NR );
end


% L1B.Frequency
%
I = L1B.Frequency.SubBandIndex;
c = 0;
while any( I(1,:) > 0 )  
  ihit = find( I(1,:) == c+1 );
  if isempty(ihit)
    error( 'Problem in L1B.Frequency.SubBandIndex detected.' );
  end
  I(1,ihit) = -1;
  c         = I(2,ihit);
end
if c ~= length(L1B.Frequency.IFreqGrid)
  error( ['Inconsistency between length of L1B.Frequency.IFreqGrid and data ' ...
          'in L1B.Frequency.SubBandIndex.'] );
end