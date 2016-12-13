% L1B_CROP   Removes unwanted tangent altitudes and AC sub-bands
%
%   The function crops the L1B to just hold the selected tangent altitudes
%   and AC sub-bands.
%
%   Note that the spectra get sorted according to the order specified by itan.
%   The spectrum channels maintain the order independently of the order in *isub*. 
%
% FORMAT   L1B = l1b_crop(L1B,itan[,isub])
%
% OUT  L1B   Cropped L1B data.
% IN   L1B   Original L1B data.
%      itan  Index of tangent altitudes to keep
% OPT  isub  Index of AC sub-bands to keep. Default is to keep all.

% 2015-12-16   Patrick Eriksson

function L1B = l1b_crop(L1B,itan,isub)
%
if nargin < 3
  isub = find( L1B.Frequency.SubBandIndex(1,:) >= 1 );
else
  if any(isub<1) | any(isub>8) | length(unique(isub))~=length(isub)
    error( '*isub* can only contain values between 1 and 8, without duplicates.' );
  end
end


% Find channel index to keep and simultaneously adjust L1B.Frequency.SubBandIndex 
%
ich = [];
n   = 0;
%
[~,iorder] = sort( L1B.Frequency.SubBandIndex(1,:) );
%
for i = iorder
  if find( i == isub )
    if L1B.Frequency.SubBandIndex(1,i) < 1  ||  L1B.Frequency.SubBandIndex(2,i) < 1
      error( 'You have selected a SubBandIndex (nr %d) that is already removed.', i );
    end
    ich  = [ ich L1B.Frequency.SubBandIndex(1,i):L1B.Frequency.SubBandIndex(2,i) ];
    nnew = L1B.Frequency.SubBandIndex(2,i) - L1B.Frequency.SubBandIndex(1,i) + 1;
    L1B.Frequency.SubBandIndex(1,i) = n + 1;
    L1B.Frequency.SubBandIndex(2,i) = n + nnew;
    n = n + nnew;
  else
    [L1B.Frequency.SubBandIndex(1,i),L1B.Frequency.SubBandIndex(2,i)] = deal( -1 );
  end
end


% Loop fields and crop 
%
names = fieldnames( L1B );
%
for i = 1 : length(names)

  switch names{i}
    
   case 'Channels'
    L1B.Channels = repmat( length(ich), 1, length(itan) );
   
   case 'Frequency'
    L1B.Frequency.AppliedDopplerCorr = L1B.Frequency.AppliedDopplerCorr(itan);   
    L1B.Frequency.ChannelsID         = L1B.Frequency.ChannelsID(ich); 
    L1B.Frequency.IFreqGrid          = L1B.Frequency.IFreqGrid(ich); 
    L1B.Frequency.LOFreq             = L1B.Frequency.LOFreq(itan); 
   
   case 'Spectrum'
    L1B.Spectrum = L1B.Spectrum(itan,ich);

   case 'TrecSpectrum'
    L1B.TrecSpectrum = L1B.TrecSpectrum(ich,1);
    
   otherwise   
    L1B.(names{i}) = L1B.(names{i})(itan,:);
  
  end
end