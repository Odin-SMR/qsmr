% L1B_ADJUST_TO_Q   Cropping and scaling of L1B according to Q
%
%   The function applies the following Q-settings:
%      Q.F_RANGES
%      Q.TB_CONTRAST_FAC
%      Q.TB_SCALING_FAC
%      Q.ZTAN_RANGE
%
% FORMAT   L1B = l1b_adjust_to_q( L1B, Q, do_qualfilter )
%
% OUT   L1B            Modiefied L1B
% IN    L1B            Original L1B.
%       Q              Q structire for frequency mode.
%       do_qualfilter  If set to true, default quality filtering of
%                      function l1b_filter is applied. If set to false, thos
%                      filtering is deactivated.

% 2016-02-16   Patrick Eriksson

function L1B = l1b_adjust_to_q( L1B, Q, do_qualfilter )


%
% Crop in tangent altitudes, with or without (default) quality criteria
%
assert( length(Q.ZTAN_LIMIT_BOT) == 4 );
%
[~,imin] = min( L1B.Altitude );
z_low    = interp1( [0 30 60 90], Q.ZTAN_LIMIT_BOT, abs(L1B.Latitude(imin)) ); 
%
if do_qualfilter
  [itan,isub] = l1b_filter( L1B, z_low, Q.ZTAN_LIMIT_TOP );
else
  [itan,isub] = l1b_filter( L1B, z_Low, Q.ZTAN_LIMIT_TOP, Inf, Inf, ...
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );    
end
%
L1B = l1b_crop( L1B, itan, isub );


%
% Crop in frequency
%
L1B = l1b_fcrop( L1B, Q.F_RANGES, Q.LO_ZREF );


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
