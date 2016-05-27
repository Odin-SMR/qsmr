function Q = q_meso(freqmode)


%---------------------------------------------------------------------------
%--- Frequency and inversion modes
%---------------------------------------------------------------------------

Q.FREQMODE           = freqmode;  
Q.INVEMODE           = 'mesospheric';


%---------------------------------------------------------------------------
%--- Work folder and folders holding pre-calculated data
%---------------------------------------------------------------------------

Q.FOLDER_WORK        = '/tmp';

Q.FOLDER_ABSLOOKUP   = '/QsmrAbsLookups';  

topfolder            = q2_topfolder;
Q.FOLDER_ANTENNA     = fullfile( topfolder, 'DataFiles', 'Antenna' );  
Q.FOLDER_BACKEND     = fullfile( topfolder, 'DataFiles', 'Backend' );  


%---------------------------------------------------------------------------
%--- NaNs for folders only used for development
%---------------------------------------------------------------------------

Q.FOLDER_ARTSXMLDATA = NaN;
Q.FOLDER_BDX         = NaN;  
Q.FOLDER_FGRID       = NaN;  


%---------------------------------------------------------------------------
%--- Absorption tables
%---------------------------------------------------------------------------

Q.ABSLOOKUP_OPTION   = [];
Q.F_GRID_NFILL       = 0;
Q.ABS_P_INTERP_ORDER = 1;
Q.ABS_T_INTERP_ORDER = 3;
  
  
%---------------------------------------------------------------------------
%--- RT and sensor
%---------------------------------------------------------------------------

Q.PPATH_LMAX         = 15e3;
Q.PPATH_LRAYTRACE    = 20e3;

Q.DZA_MAX_IN_CORE    = 0.01;
Q.DZA_GRID_EDGES     = [ Q.DZA_MAX_IN_CORE*[1:3 5 8 12 21] ];

Q.LO_COMMON          = true;
Q.LO_ZREF            = 60e3;

Q.TB_SCALING_FAC     = 1.0025;
Q.TB_CONTRAST_FAC    = 1.03;


%---------------------------------------------------------------------------
%--- OEM settings
%---------------------------------------------------------------------------

Q.STOP_DX            = 0.5;
Q.GA_START           = 0;
Q.GA_FACTOR_NOT_OK   = 10;
Q.GA_FACTOR_OK       = 10;
Q.GA_MAX             = 1e4;


%---------------------------------------------------------------------------
%--- Common retrieval settings
%---------------------------------------------------------------------------

Q.NOISE_CORRMODEL    = 'empi';  % 'none', 'empi' 'expo'

Q.BASELINE.RETRIEVE  = true;
Q.BASELINE.MODEL     = 'adaptive';  % 'common', 'module', 'adaptive'
Q.BASELINE.UNC       = 2;

Q.POINTING.RETRIEVE  = true;
Q.POINTING.UNC       = 0.01;

Q.FREQUENCY.RETRIEVE = true;
Q.FREQUENCY.UNC      = 1e6;

Q.T.SOURCE           = 'WebApi';
Q.T.RETRIEVE         = true;
Q.T.UNC              = [ 3 3 9 15 15 ];
Q.T.CORRLEN          = 8e3;


%---------------------------------------------------------------------------
%--- Quality demands
%---------------------------------------------------------------------------

Q.MIN_N_SPECTRA      = 8;
Q.MIN_N_FREQS        = 50;



%---------------------------------------------------------------------------
%--- Band specific
%---------------------------------------------------------------------------

switch freqmode
  
 case 2
  %
  Q.P_GRID                  = q2_pgrid( [], 110e3 ); 
  %
  Q.BACKEND_NR              = 1;
  Q.FRONTEND_NR             = 4;
  Q.F_LO_NOMINAL            = 548.500e9;
  Q.SIDEBAND_LEAKAGE        = 0.04;
  %
  Q.F_RANGES                = 544.857e9 + 75e6*[-1 1];
  Q.ZTAN_LIMIT_TOP          = 105e3;
  Q.ZTAN_LIMIT_BOT          = [ 40e3 40e3 40e3 40e3 ];
  %
  Q.T.L2                    = false;
  Q.T.GRID                  = q2_pgrid( 40e3, 100e3, 8 );
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'O3-*-544e9-546e9';
  Q.ABS_SPECIES(1).SOURCE   = 'WebApi';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).L2NAME   = 'O3 / 545 GHz / 45 to 95 km';
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 40e3, 100e3, 8 );
  Q.ABS_SPECIES(1).UNC_REL  = 0.5;
  Q.ABS_SPECIES(1).UNC_ABS  = 1e-6;
  Q.ABS_SPECIES(1).CORRLEN  = 10e3;
  Q.ABS_SPECIES(1).LOG_ON   = true;
  %
  [Q.ABS_SPECIES.ISOFAC]     = deal( 1 );  
  [Q.ABS_SPECIES.SOURCE]     = deal( 'WebApi' );
  %-------------------------------------------------------------------------
  
    
 otherwise
  error( 'Frequency band %d is not yet handled (or not defined).', freqmode );
end
