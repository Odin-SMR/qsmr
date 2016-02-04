% L1B_FCROP   Crop L1B to only cover one or several frequency ranges
%
%   The channel selection is based on the frequency grid at the middle of
%   the scan.
%
% FORMAT   L1B = l1b_fcrop(L1B,flims)
%
% OUT   L1B    Modified L1B structure.
% IN    L1B    Original L1B structure.
%       flims  Frequency limits. A matrix with two columns. Each row
%              describes a frequency range, where first/second element
%              gives the lower/upper limit of the range.

% 2015-12-20   Patrick Eriksson

function L1B = l1b_fcrop(L1B,flims)
%
if size(flims,2) ~=2
  error( '*flims* must have two columns.' );
end

% Get the frequency grid to use for cropping
it   = round(length(L1B.Altitude)/2);
fref = l1b_frequency( L1B, it );

% Loop frequency ranges and find channels hits
%
iok = false( size( L1B.Spectrum(:,1) ) );
%
for i = 1 : size(flims,1)
  iok = iok | ( ...
        fref >= flims(i,1) & ...
        fref <= flims(i,2) );
end

% Pick-out data inside frequency range(s)
%
L1B.Spectrum            = L1B.Spectrum(iok,:);
L1B.TrecSpectrum        = L1B.TrecSpectrum(iok);
L1B.Frequency.IFreqGrid = L1B.Frequency.IFreqGrid(iok,:);

% Adjust SubBandIndex
%
inew                     = 1 : length(fref);
inew                     = inew(iok);
%
for i = 1 : 8
  if L1B.Frequency.SubBandIndex(1,i) > -1
    iout = intersect( inew, L1B.Frequency.SubBandIndex(1,i) : ...
                            L1B.Frequency.SubBandIndex(2,i) );
    if isempty(iout)
      L1B.Frequency.SubBandIndex(1,i) = -1;
      L1B.Frequency.SubBandIndex(2,i) = -1;
    else        
      L1B.Frequency.SubBandIndex(1,i) = find( inew == iout(1) );
      L1B.Frequency.SubBandIndex(2,i) = find( inew == iout(end) );
    end
  end
end