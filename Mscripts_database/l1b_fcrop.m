% L1B_FCROP   Crop L1B to only cover one or several frequency ranges
%
%   This function requires that L1B.Frequency holds actual frequencies.
%
%   The channel selection is based on the frequency grid at the middle of
%   the scan.
%
% FORMAT   L1B = l1b_fcrop(L1B,flims)
%
% OUT   L1B    Modified L1B structure.
% IN    L1B    Original L1B structure.
%       flims  Frequency limits. A matrix with two rows. Each column
%              describes a frequency range, where first/second element
%              gives the lower/upper limit of the range.

% 2015-12-20   Patrick Eriksson

function L1B = l1b_fcrop(L1B,flims)
%
if isfield( L1B.Frequency, 'SSB' )
  error( 'This function demands that L1B.Frequency contains actual frequencies.' );
end
if size(flims,1) ~=2
  error( '*flims* must have two rows.' );
end

% Get index of tangent altitude to use as frequency reference
it = round(length(L1B.Altitude)/2);

% Loop frequency ranges and find channels hits
%
iok = false( size( L1B.Spectrum(:,1) ) );
%
for i = 1 : size(flims,2)
  iok = iok | ( ...
        L1B.Frequency(:,it) >= flims(1,i) & ...
        L1B.Frequency(:,it) <= flims(2,i) );
end

% Pick-out data inside frequency range(s)
%
L1B.Frequency = L1B.Frequency(iok,:);
L1B.Spectrum  = L1B.Spectrum(iok,:);