% L1B_CROP   Removes unwanted tangent altitudes and AC sub-bands
%
%   The function crops the L1B to just hold the selected tangent altitudes
%   and AC sub-bands.
%
%   Note that the spectra get sorted according to the order specified by itan.
%   The spectrum channels maintain the order independently of the order in *issb*. 
%
%   This function requires that L1B.Frequency is of original type.
%
% FORMAT   L1B = l1b_crop(L1B,itan[,issb])
%
% OUT  L1B   Cropped L1B data.
% IN   L1B   Original L1B data.
%      itan  Index of tangent altitudes to keep
% OPT  issb  Index of sub-bands to keep. Default is to keep all.

% 2015-12-16   Patrick Eriksson

function L1B = l1b_crop(L1B,itan,issb)
%
if nargin < 3
  issb = find( L1B.Frequency.SSB(2:3:end) >= 1 );
else
  if any(issb<1) | any(issb>8) | length(unique(issb))~=length(issb)
    error( '*issb* can only contain values between 1 and 8, without duplicates.' );
  end
end


% Find channel index to keep and simultaneously adjust L1B.Frequency.SSB 
%
ich = [];
n   = 0;
%
[~,iorder] = sort( L1B.Frequency.SSB(2:3:end) );
%
for i = iorder
  i0  = (i-1)*3+1;
  if find( i == issb )
    if L1B.Frequency.SSB(i0+1) < 1  ||  L1B.Frequency.SSB(i0+2) < 1
      error( 'You have selected a SSB (nr %d) that is already removed.', i );
    end
    ich  = [ ich L1B.Frequency.SSB(i0+1):L1B.Frequency.SSB(i0+2) ];
    nnew = L1B.Frequency.SSB(i0+2) - L1B.Frequency.SSB(i0+1) + 1;
    L1B.Frequency.SSB(i0+1) = n + 1;
    L1B.Frequency.SSB(i0+2) = n + nnew;
    n = n + nnew;
  else
    [L1B.Frequency.SSB(i0+1),L1B.Frequency.SSB(i0+2)] = deal( -1 );
  end
end


% Loop fields and crop 
%
names = fieldnames( L1B );
%
for i = 1 : length(names)

  switch names{i}
    
   case 'Frequency'
    L1B.Frequency.IFreqGrid = L1B.Frequency.IFreqGrid(ich); 
    L1B.Frequency.LOFreq    = L1B.Frequency.LOFreq(itan); 
   
   case 'Spectrum'
    L1B.Spectrum = L1B.Spectrum(ich,itan);

   case 'SSB'
     %
       
   otherwise   
    L1B.(names{i}) = L1B.(names{i})(:,itan);
  end
end