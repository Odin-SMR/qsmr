% L1B_CROP   Removes unwanted tangent altitudes and AC sub-bands
%
%   The function crops the L1b to just hold the selected tangent altitudes
%   and AC sub-bands.
%
%   Note that the spectra get sorted according to the order specified by itan.
%   The spectrum channels maintain the order independently of the order in *issb*. 
%
% FORMAT   l1b = l1b_crop(l1b,itan[,issb])
%
% OUT  l1b   Cropped L1b data.
% IN   l1b   Original L1b data
%      itan  Index of tangent altitudes to keep
% OPT  issb  Index of sub-bands to keep. Default is to keep all.

% 2015-12-16   Patrick Eriksson

function l1b = l1b_crop(l1b,itan,issb)
%
if nargin < 3
  issb = find( l1b.Frequency.SSB(2:3:end) >= 1 );
else
  if any(issb<1) | any(issb>8) | length(unique(issb))~=length(issb)
    error( '*issb* can only contain values between 1 and 8, without duplicates.' );
  end
end


% Find channel index to keep and simultaneously adjust l1b.Frequency.SSB 
%
ich = [];
n   = 0;
%
[~,iorder] = sort( l1b.Frequency.SSB(2:3:end) );
%
for i = iorder
  i0  = (i-1)*3+1;
  if find( i == issb )
    if l1b.Frequency.SSB(i0+1) < 1  ||  l1b.Frequency.SSB(i0+2) < 1
      error( 'You have selected a SSB (nr %d) that is already removed.', i );
    end
    ich  = [ ich l1b.Frequency.SSB(i0+1):l1b.Frequency.SSB(i0+2) ];
    nnew = l1b.Frequency.SSB(i0+2) - l1b.Frequency.SSB(i0+1) + 1;
    l1b.Frequency.SSB(i0+1) = n + 1;
    l1b.Frequency.SSB(i0+2) = n + nnew;
    n = n + nnew;
  else
    [l1b.Frequency.SSB(i0+1),l1b.Frequency.SSB(i0+2)] = deal( -1 );
  end
end


% Loop fields and crop 
%
names = fieldnames( l1b );
%
for i = 1 : length(names)

  switch names{i}
    
   case 'Frequency'
    l1b.Frequency.IFreqGrid = l1b.Frequency.IFreqGrid(ich); 
    l1b.Frequency.LOFreq    = l1b.Frequency.LOFreq(itan); 
   
   case 'Spectrum'
    l1b.Spectrum = l1b.Spectrum(ich,itan);

   case 'SSB'
     %
       
   otherwise   
    l1b.(names{i}) = l1b.(names{i})(:,itan);
  end
end