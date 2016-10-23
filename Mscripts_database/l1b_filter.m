% L1B_FILTER   Quality filtering of L1B data
%
%   The only criterion affecting *isub* is *lag0_max*, all other arguments
%   are related to *itan*.
%
%   The quality variables (q_xxxx) are defined in the L1b ATBD.
%
%   This function requires that L1B.Frequency is of original type.
%
%   To apply the filtering, call *l1b_crop* with the output arguments of
%   this function.
%
% FORMAT   [L1B,L2C] = l1b_filter( L1B, Q, L2C )
%
% OUT   L1B            Modiefied L1B
%       L2C            Possibly extended L2C
% IN    L1B            Original L1B.
%       Q              Q structire for frequency mode.
%       L2C            Original L2C 
%
% 2015-12-19   Patrick Eriksson

function [L1B,L2C] = l1b_filter( L1B, Q, L2C )


ntan = size( L1B.Spectrum, 2 );


% Tspill
%
if Q.QFILT_TSPILL
  itan001 = ~bitget( L1B.Quality, find(bitget(hex2dec('0001'),1:1)) );
  dtan    = ntan - sum(itan001);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Tspill flag', dtan );
  end
else
  itan001 = logical( ones(1,ntan) );
end


% Trec
%
if Q.QFILT_TREC
  itan002 = ~bitget( L1B.Quality, find(bitget(hex2dec('0002'),1:2)) );
  dtan    = ntan - sum(itan002);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Trec flag', dtan );
  end
else
  itan002 = logical( ones(1,ntan) );
end


% Noise
%
if Q.QFILT_NOISE
  itan004 = ~bitget( L1B.Quality, find(bitget(hex2dec('0004'),1:3)) );
  dtan    = ntan - sum(itan004);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Noise flag', dtan );
  end
else
  itan004 = logical( ones(1,ntan) );
end


% Scanning
%
if Q.QFILT_SCANNING
  itan008 = ~bitget( L1B.Quality, find(bitget(hex2dec('0008'),1:4)) );
  dtan    = ntan - sum(itan008);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Scanning flag', dtan );
  end
else
  itan008 = logical( ones(1,ntan) );
end


% No of spectra
%
if Q.QFILT_SPECTRA
  itan010 = ~bitget( L1B.Quality, find(bitget(hex2dec('0010'),1:5)) );
  dtan    = ntan - sum(itan010);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to No. of Spectra flag', dtan );
  end
else
  itan010 = logical( ones(1,ntan) );
end


% Tb
%
if Q.QFILT_TBRANGE
  itan020 = ~bitget( L1B.Quality, find(bitget(hex2dec('0020'),1:6)) );
  dtan    = ntan - sum(itan020);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Valid Tb flag', dtan );
  end
else
  itan020 = logical( ones(1,ntan) );
end


% Tint
%
if Q.QFILT_TINT
  itan040 = ~bitget( L1B.Quality, find(bitget(hex2dec('0040'),1:7)) );
  dtan    = ntan - sum(itan040);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Tint flag', dtan );
  end
else
  itan040 = logical( ones(1,ntan) );
end


% Ref1
%
if Q.QFILT_REF1
  itan080 = ~bitget( L1B.Quality, find(bitget(hex2dec('0080'),1:8)) );
  dtan    = ntan - sum(itan080);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Ref1 flag', dtan );
  end
else
  itan080 = logical( ones(1,ntan) );
end


% Ref2
%
if Q.QFILT_REF2
  itan100 = ~bitget( L1B.Quality, find(bitget(hex2dec('0100'),1:9)) );
  dtan    = ntan - sum(itan100);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Ref2 flag', dtan );
  end
else
  itan100 = logical( ones(1,ntan) );
end


% Moon
%
if Q.QFILT_MOON
  itan200 = ~bitget( L1B.Quality, find(bitget(hex2dec('0200'),1:10)) );
  dtan    = ntan - sum(itan200);
  if dtan > 0
    L2C{end+1} = sprintf( 'Filter: %d spectra removed due to Moon flag', dtan );
  end
else
  itan200 = logical( ones(1,ntan) );
end


% Combined tangent altitude filtering
%
itan = find( itan001 & itan002 & itan004 & itan008 & itan010 & ...
             itan020 & itan040 & itan080 & itan100 & itan200 ); 
%



% Index of AC sub-bands to keep
% (consider ZeroLagVar only for those spectra to keep)
%
%
if isempty(itan)
  isub = [];
else
  isub = find( ...
      L1B.Frequency.SubBandIndex(1,:)   >=    1    &  ...
      max(L1B.ZeroLagVar(:,itan),[],2)' <= Q.QFILT_LAG0MAX );
end


% Perform cropping
%
L1B  = l1b_crop( L1B, itan, isub );



% Sumemrize status 
%
L2C{end+1} = sprintf( 'Status: %d spectra left after quality filtering', ...
                      length(itan) );
L2C{end+1} = sprintf( 'Status: %d AC sub-modules left after quality filtering', ...
                      length(isub) );
