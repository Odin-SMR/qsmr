% L1B_FREQUENCY   Absolute frequency of L1B data
%
%   The function returns absolute frequencies for the selected set of spectra.
%
% FORMAT   F = l1b_frequency( l1b [, itan] )
%
% OUT  F     Frequencies, one column per spectrum.
% IN   l1b   L1b data
% OPT  itan  Returns frequency for these tangent altitude index. Default is
%            to include all.

% 2015-12-16   Patrick Eriksson

function F = l1b_frequency( l1b, itan )
%
if nargin < 2
  itan = 1 : length(l1b.Frequency.LOFreq);
end
  
nf = length( l1b.Frequency.IFreqGrid );
nt = length( itan);

F = zeros( nf, nt );

for i = 1 : nt
  F(:,i) = l1b.Frequency.LOFreq(itan(i)) + l1b.Frequency.IFreqGrid;
end