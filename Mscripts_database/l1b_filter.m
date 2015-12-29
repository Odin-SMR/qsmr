% L1B_FILTER   Altitude and quality filtering of L1B data
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
% FORMAT   [itan,isub] = l1b_filter( L1B,
%                                   [ztan_low,ztan_high,tint_maxdev,lag0_max,
%                                    q_tspill, q_trec, q_noise, q_scan, q_nspec,
%                                    q_tb,     q_tint, q_ref1,  q_ref2, q_moon])
%
% OUT  itan          Index of tangent altitudes that are OK according to criteria.
%      isub          Index of sub-bands that are OK according to criteria.
% IN   L1B           L1B structure.
% OPT  ztan_low      Minimum tangent altitude. 
%                    Default is -Inf.
%      ztan_high     Maximum tangent altitude. 
%                    Default is Inf
%      tint_maxdev   Maximum deviation from nominal integration times.
%                    Default is 0.02.
%      lag0_max      Max allowed value for ZeroLagVar. 
%                    Default is 0.5.
%      q_tspill      Flag to consider Tspill qualilty variable. 
%                    Defualt is 1.
%      q_trec        Flag to consider Trec qualilty variable. 
%                    Default is 1.
%      q_noise       Flag to consider Noise qualilty variable. 
%                    Default is 1.
%      q_scan        Flag to consider Scanning qualilty variable.
%                    Default is 0.
%      q_nspec       Flag to consider Nr of Spectra qualilty variable. 
%                    Default is 0.
%      q_tb          Flag to consider Tb range qualilty variable. 
%                    Default is 0.
%      q_tint        Flag to consider integration time qualilty variable. 
%                    Default is 0.
%      q_ref1        Flag to consider Reference 1 qualilty variable. 
%                    Default is 0.
%      q_ref2        Flag to consider Reference 2 qualilty variable. 
%                    Default is 0.
%      q_moon        Flag to consider Moon interference qualilty variable. 
%                    Default is 1.

% 2015-12-19   Patrick Eriksson

function [itan,isub] = l1b_filter(L1B,varargin)
%
[ztan_low,ztan_high,tint_maxdev,lag0_max,...
 q_tspill,q_trec,q_noise,q_scan,q_nspec,q_tb,q_tint,q_ref1,q_ref2,q_moon] = ...
    optargs( varargin, { -Inf, Inf, 0.02, 0.5, ...
                    1, 1, 1, 0, 0, 0, 0, 0, 0, 1 } ); 


% Nominal integration times
%
tint0 = [ 0.86 1.86 3.86 ];


% Index of tangent altitudes to keep
%
itan = find( ...
    L1B.Altitude                >= ztan_low       &  ...
    L1B.Altitude                <= ztan_high      &  ...
    ( abs(L1B.IntTime-tint0(1)) <= tint_maxdev |     ...
      abs(L1B.IntTime-tint0(2)) <= tint_maxdev |     ...
      abs(L1B.IntTime-tint0(3)) <= tint_maxdev )  &  ...
    ( ~q_tspill | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0001'),1:1))) ) &   ...
    ( ~q_trec   | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0002'),1:2))) ) &   ...
    ( ~q_noise  | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0004'),1:3))) ) &   ...
    ( ~q_scan   | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0008'),1:4))) ) &   ...
    ( ~q_nspec  | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0010'),1:5))) ) &   ...
    ( ~q_tb     | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0020'),1:6))) ) &   ...
    ( ~q_tint   | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0040'),1:7))) ) &   ...
    ( ~q_ref1   | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0080'),1:8))) ) &   ...
    ( ~q_ref2   | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0100'),1:9))) ) &   ...
    ( ~q_moon   | ~bitget( L1B.Quality,              ...
            find(bitget(hex2dec('0200'),1:10))) ) );    


% Index of AC sub-bands to keep
%
isub = find( ...
    L1B.Frequency.SubBandIndex(1,:) >= 1  &  ...
    max(L1B.ZeroLagVar,[],2)'       <= lag0_max );

                    