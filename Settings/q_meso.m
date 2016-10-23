function Q = q_meso(freqmode, invemode)


%---------------------------------------------------------------------------
%--- Frequency and inversion modes
%---------------------------------------------------------------------------

Q.FREQMODE           = freqmode;  
Q.INVEMODE           = 'meso';


%---------------------------------------------------------------------------
%--- Work and data folders
%---------------------------------------------------------------------------

Q.FOLDER_WORK        = '/tmp';

if exist('/myhome')
  datadir              = '/QsmrData';
else
  datadir              = '~/Data/QsmrData';
end
Q.FOLDER_ABSLOOKUP   = fullfile( datadir, 'AbsLookup', Q.INVEMODE );
Q.FOLDER_BDX         = fullfile( datadir, 'SpeciesApriori', 'Bdx' );  
Q.FOLDER_FGRID       = fullfile( datadir, 'Fgrid', Q.INVEMODE );
Q.FOLDER_MSIS90      = fullfile( datadir, 'TemperatureApriori', 'MSIS90' );  

topfolder            = q2_topfolder;
Q.FOLDER_ANTENNA     = fullfile( topfolder, 'DataFiles', 'Antenna' );  
Q.FOLDER_BACKEND     = fullfile( topfolder, 'DataFiles', 'Backend' );  


%---------------------------------------------------------------------------
%--- Absorption tables
%---------------------------------------------------------------------------

%Q.ABSLOOKUP_OPTION   = [];
Q.ABSLOOKUP_OPTION   = '200mK_linear';
Q.F_GRID_NFILL       = 0;
Q.ABS_P_INTERP_ORDER = 1;
Q.ABS_T_INTERP_ORDER = 3;
  
  
%---------------------------------------------------------------------------
%--- RT and sensor
%---------------------------------------------------------------------------

Q.REFRACTION_DO      = false;  
Q.PPATH_LMAX         = 15e3;
Q.PPATH_LRAYTRACE    = 20e3;

Q.DZA_MAX_IN_CORE    = 0.01;
Q.DZA_GRID_EDGES     = [ Q.DZA_MAX_IN_CORE*[1:3 5 8 12 21] ];

Q.LO_COMMON          = true;
Q.LO_ZREF            = 60e3;

Q.TB_SCALING_FAC     = 1.0025;
Q.TB_CONTRAST_FAC    = [];


%---------------------------------------------------------------------------
%--- OEM settings
%---------------------------------------------------------------------------

Q.STOP_DX            = 0.2;
%Q.GA_START           = 10;
Q.GA_START           = 1;
Q.GA_FACTOR_NOT_OK   = 10;
Q.GA_FACTOR_OK       = 10;
Q.GA_MAX             = 1e4;


%---------------------------------------------------------------------------
%--- Common retrieval settings
%---------------------------------------------------------------------------

Q.NOISE_CORRMODEL    = 'expo';  % 'none', 'empi' 'expo'

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
%--- Quality criteria
%---------------------------------------------------------------------------

Q.QFILT_TSPILL       = true;
Q.QFILT_TREC         = true;
Q.QFILT_NOISE        = true;
Q.QFILT_SCANNING     = true;
Q.QFILT_SPECTRA      = false;
Q.QFILT_TBRANGE      = true;
Q.QFILT_TINT         = true;
Q.QFILT_REF1         = false;
Q.QFILT_REF2         = false;
Q.QFILT_MOON         = true;
Q.QFILT_LAG0MAX      = 1;

Q.MIN_N_SPECTRA      = 8;

%Q.MIN_N_FREQS        = 50;
Q.MIN_N_FREQS        = 300;



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
  Q.ZTAN_MIN_RANGE          = [ 45e3 70e3 ];
  %
  Q.T.L2                    = false;
  Q.T.GRID                  = q2_pgrid( 40e3, 100e3, 8 );
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'O3-*-544e9-546e9';
  Q.ABS_SPECIES(1).SOURCE   = 'WebApi';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).L2NAME   = 'O3 / 545 GHz / 45 to 95 km';
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 40e3, 100e3, 4 );
  Q.ABS_SPECIES(1).UNC_REL  = 0.5;
  Q.ABS_SPECIES(1).UNC_ABS  = 1e-6;
  Q.ABS_SPECIES(1).CORRLEN  = 5e3;
  
  %Q.ABS_SPECIES(1).CORRLEN  = 10e3;
  
  
  Q.ABS_SPECIES(1).LOG_ON   = false;
  %
  [Q.ABS_SPECIES.ISOFAC]     = deal( 1 );  
  [Q.ABS_SPECIES.SOURCE]     = deal( 'WebApi' );
  %-------------------------------------------------------------------------

  
 case 21
  %
  Q.GA_START                 = 10;
  %Q.GA_START=1;
  %
  Q.P_GRID                   = q2_pgrid( [], 150e3 ); 
  %
  Q.BACKEND_NR               = 1;
  Q.FRONTEND_NR              = 4;
  Q.F_LO_NOMINAL             = 547.753e9;
  Q.SIDEBAND_LEAKAGE         = 0.02;  %
  %
  Q.F_RANGES                 = [ 551.13e9 551.58e9; ];
  Q.ZTAN_LIMIT_TOP           = 150e3;
  Q.ZTAN_LIMIT_BOT           = [ 40e3 40e3 40e3 40e3 ];
  Q.ZTAN_MIN_RANGE           = [ 45e3 80e3 ];
  %
  Q.T.L2                     = true;
  Q.T.GRID                   = q2_pgrid( 40e3, 150e3, 4 );
  Q.T.SOURCE                 = 'WebApi';
  %
  Q.ABS_SPECIES(1).TAG{1}    = 'NO-*-541e9-562e9';
  Q.ABS_SPECIES(1).ISOFAC    = 1;
  Q.ABS_SPECIES(1).RETRIEVE  = true;
  Q.ABS_SPECIES(1).L2        = true;
  Q.ABS_SPECIES(1).L2NAME    = 'NO / 551 GHz / 45 to 115 km';
  Q.ABS_SPECIES(1).GRID      = q2_pgrid( 40e3, 150e3, 4 );
  Q.ABS_SPECIES(1).UNC_REL   = 1;
  Q.ABS_SPECIES(1).UNC_ABS   = 1e-8;
  Q.ABS_SPECIES(1).CORRLEN   = 6e3;
  Q.ABS_SPECIES(1).LOG_ON    = true;
  %
  Q.ABS_SPECIES(2).TAG{1}    = 'O3-*-541e9-562e9';
  Q.ABS_SPECIES(2).ISOFAC    = 1;
  Q.ABS_SPECIES(2).RETRIEVE  = true;
  Q.ABS_SPECIES(2).L2        = true;
  Q.ABS_SPECIES(2).GRID      = q2_pgrid( 40e3, 110e3, 4 );
  Q.ABS_SPECIES(2).L2NAME    = 'O3 / 551 GHz / 45 to 90 km';
  Q.ABS_SPECIES(2).UNC_REL   = 0.5;
  Q.ABS_SPECIES(2).UNC_ABS   = 1e-6;
  %Q.ABS_SPECIES(2).CORRLEN   = 10e3;
  
  Q.ABS_SPECIES(2).CORRLEN   = 10e3;

  Q.ABS_SPECIES(2).LOG_ON    = false;
  %
  [Q.ABS_SPECIES.SOURCE]     = deal( 'WebApi' );
  %-------------------------------------------------------------------------
  
    
 otherwise
  error( 'Frequency band %d is not yet handled (or not defined).', freqmode );
end
