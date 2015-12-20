% L1B_FREQUENCY   Absolute frequency of L1B data
%
%   The function returns absolute frequencies for the selected set of spectra.
%
% FORMAT   F = l1b_frequency( L1B [, itan] )
%
% OUT  F     Frequencies, one column per spectrum.
% IN   L1B   L1B data
% OPT  itan  Returns frequency for these tangent altitude index. Default is
%            to include all.

% 2015-12-16   Patrick Eriksson

function F = l1b_frequency( L1B, itan )
%
if nargin < 2
  itan = 1 : length(L1B.Frequency.LOFreq);
end
  
nf = length( L1B.Frequency.IFreqGrid );
nt = length( itan);

F = zeros( nf, nt );

for i = 1 : nt
  F(:,i) = L1B.Frequency.LOFreq(itan(i)) + L1B.Frequency.IFreqGrid;
end