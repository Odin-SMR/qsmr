% L1B_ADJUST_TO_Q   Cropping and scaling of L1B according to Q
%
%   The function applies the following Q-settings:
%      Q.F_RANGES
%      Q.TB_CONTRAST_FAC
%      Q.TB_SCALING_FAC
%      Q.ZTAN_RANGE
%
% FORMAT   [L1B,L2C] = l1b_adjust_to_q( L1B, Q, L2C )
%
% OUT   L1B            Modiefied L1B
%       L2C            Possibly extended L2C
% IN    L1B            Original L1B.
%       Q              Q structire for frequency mode.
%       L2C            Original L2C 

% 2016-02-16   Patrick Eriksson

function [L1B,L2C] = l1b_adjust_to_q( L1B, Q, L2C )


%
% Tangent altitude cropping
%
[~,imin]       = min( L1B.Altitude );
ztan_limit_bot = interp1( [0 30 60 90], Q.ZTAN_LIMIT_BOT, abs(L1B.Latitude(imin)) ); 
%
itan = find( L1B.Altitude >= ztan_limit_bot  &  ...
             L1B.Altitude <= Q.ZTAN_LIMIT_TOP );
L1B  = l1b_crop( L1B, itan );
%
L2C{end+1} = sprintf( 'Status: %d spectra left after altitude cropping', ...
                      length(itan) );


%
% Return if no spectra left
%
if any( size(L1B.Spectrum) == 0 )
  return
end


%
% Filter based on L1B.Quality
%
%[L1B,L2C] = l1b_filter( L1B, Q, L2C );


%
% Return if no spectra left
%
if any( size(L1B.Spectrum) == 0 )
  return
end


%
% Crop in frequency
%
L1B = l1b_fcrop( L1B, Q.F_RANGES, Q.LO_ZREF );
%
L2C{end+1} = sprintf( 'Status: %d channels left after frequency cropping', ...
                      length(L1B.Frequency.IFreqGrid) );


%
% Perform overall Tb scaling
%
if ~( isempty(Q.TB_SCALING_FAC)  |  Q.TB_SCALING_FAC == 1 )
  L1B.Spectrum = Q.TB_SCALING_FAC * L1B.Spectrum;
end


%
% Perform Tb contrast scaling
%
if ~( isempty(Q.TB_CONTRAST_FAC)  |  Q.TB_CONTRAST_FAC == 1 )

  % Find index for AC module
  for j = 1 : 4
    ind{j} = [];
    for k = 1 : 2
      if L1B.Frequency.SubBandIndex(1,(j-1)*2+k) > 0
        ind{j} = [ ind{j}, L1B.Frequency.SubBandIndex(1,(j-1)*2+k) : ...
                           L1B.Frequency.SubBandIndex(2,(j-1)*2+k) ];
      end
    end
  end
    
  % Loop spectra
  for i = 1 : size( L1B.Spectrum, 2 )
      
    % Estimate noise magnitude assuming a fixed 3500K system noise temperature
    thn = 3000 / sqrt( L1B.FreqRes(1) * L1B.EffTime(i) );

    y0 = L1B.Spectrum(:,i);
    
    % Loop AC modules
    for j = 1 : 4
     
      if ~isempty( ind{j} )
  
        % Take min + 2 noise std dev, but not allow a negative value
        tb_min = max( 0, min(L1B.Spectrum(ind{j},i)) + 2*thn );

        % Apply scaling
        L1B.Spectrum(ind{j},i) = tb_min + Q.TB_CONTRAST_FAC * ...
                                            ( L1B.Spectrum(ind{j},i) - tb_min );
      
      end
    end
  end
end
