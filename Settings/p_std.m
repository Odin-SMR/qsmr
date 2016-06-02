% P_STD   Precalculation settings, standard set
%
%    Note that the pre-calculations use settings in both P and Q. See
%    comments (and code) in the pre-calculation functions.
%
% FORMAT P = p_std

function P = p_std

  
%-------------------------------------------------------------------------------
%- Bdx a priori database
%-------------------------------------------------------------------------------

% Where to find original files (used in Qsmr1)
P.BDX_DATA_INFOLDER = '/home/patrick/Projects/SMR/Qsmr/Input/Climatologies/Bdx';



%-------------------------------------------------------------------------------
%- Antenna
%-------------------------------------------------------------------------------

% What integration times to consider
P.INTEGRATION_TIMES = [ 0.86 1.86 3.86 ];



%-------------------------------------------------------------------------------
%- Backend
%-------------------------------------------------------------------------------

% What channels frequency spacings to consider
P.BACKEND_FSPACINGS = [ 1/8 1 ]*1e6;



%-------------------------------------------------------------------------------
%- Reference atmospheres and spectra
%-------------------------------------------------------------------------------

% These three fields specify a set of date and position combinations. All three
% vectors must have the same length. The exact atmospheric states depend on
% settings in O, such as O.T_SOURCE. The first state is used as reference
% when calculating absorption lookupo tables. All states are used when
% generating frequency grids.
P.REFSPECTRA_LAT    = [ 40 -80:40:0 80 ];
P.REFSPECTRA_LON    = repmat( 0, size(P.REFSPECTRA_LAT) );
P.REFSPECTRA_MJD    = repmat( date2mjd(2000,1,1)+34, size(P.REFSPECTRA_LAT) );

% A set of tangent altitudes, considered when generating frequency grids.
P.REFSPECTRA_ZTAN   = 15e3 : 5e3 : 100e3; 


%-------------------------------------------------------------------------------
%- F_GRID
%-------------------------------------------------------------------------------

% Frequency spacing of reference spectra
P.FGRID_TEST_DF     = 200e3;

% How much frequency margin to add, to both primary and image band
P.FGRID_EDGE_MARGIN = 20e6;



%-------------------------------------------------------------------------------
%- Absorption lookup tables
%-------------------------------------------------------------------------------

topfolder       = q2_topfolder;

% File holding description of absorption continua and models
P.CONTINUA_FILE = fullfile( topfolder, 'DataFiles', 'Continua', ...
                                                         'continua_std.arts' );

% File holding all spectroscopy data
P.SPECTRO_FILE  = '~/Data/QsmrData/Spectroscopy/smr_linedata.xml';

% The set of temperature perturbations
P.ABS_T_PERT    = symgrid( [0:10:100 120 150] )';



