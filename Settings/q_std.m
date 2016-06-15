function Q = q_std(freqmode,invemode)
%
if nargin < 2, invemode = 'stnd'; end
%
assert( length(freqmode) == 1 );



%---------------------------------------------------------------------------
%--- Frequency and inversion modes
%---------------------------------------------------------------------------

Q.FREQMODE           = freqmode;  
Q.INVEMODE           = invemode;


%---------------------------------------------------------------------------
%--- Different paths
%---------------------------------------------------------------------------

Q.ARTS               = 'arts';
Q.FOLDER_WORK        = '/tmp';

if exist('/myhome')
  datadir            = '/QsmrData';    
else
  datadir            = '~/Data/QsmrData';
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
Q.ABSLOOKUP_OPTION   = '100mK_linear';
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
Q.TB_CONTRAST_FAC    = 1.03;


%---------------------------------------------------------------------------
%--- OEM settings
%---------------------------------------------------------------------------

Q.STOP_DX            = 1;
Q.GA_START           = 1;
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
Q.MIN_N_FREQS        = 100;



%---------------------------------------------------------------------------
%--- Band specific
%---------------------------------------------------------------------------

switch freqmode
  
 case 1
  %
  if ~( strcmp( invemode, 'stnd' )  )
    error( 'Inversion modes of freqmode %d are: ''stnd''.', freqmode ); 
  end
  %
  Q.P_GRID                  = q2_pgrid( [], 70e3 ); 
  %
  Q.BACKEND_NR              = 2;
  Q.FRONTEND_NR             = 2;
  Q.F_LO_NOMINAL            = 497.885e9;
  Q.SIDEBAND_LEAKAGE        = 0.02;
  %
  Q.F_RANGES                = [ 501.16e9 501.60e9; 501.96e9 502.40e9 ];
  Q.ZTAN_LIMIT_TOP          = 60e3;
  Q.ZTAN_LIMIT_BOT          = [ 20e3 17e3 13e3 13e3 ];
  Q.ZTAN_MIN_RANGE          = [ 25e3 40e3 ];
  %
  Q.T.L2                    = false;
  Q.T.GRID                  = q2_pgrid( 10e3, 65e3, 4 );
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'ClO-*-498e9-505e9';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).L2NAME   = 'ClO / 501 GHz / 20 to 50 km';
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 65e3, 4 );
  Q.ABS_SPECIES(1).UNC_REL  = 0.5;
  Q.ABS_SPECIES(1).UNC_ABS  = 2.5e-10;
  Q.ABS_SPECIES(1).CORRLEN  = 5e3;
  Q.ABS_SPECIES(1).LOG_ON   = false;
  %
  Q.ABS_SPECIES(2).TAG{1}   = 'N2O-*-491e9-512e9';
  Q.ABS_SPECIES(2).RETRIEVE = true;
  Q.ABS_SPECIES(2).L2       = true;
  Q.ABS_SPECIES(2).L2NAME   = 'N2O / 502 GHz / 20 to 50 km';
  Q.ABS_SPECIES(2).GRID     = q2_pgrid( 10e3, 65e3, 8 );
  Q.ABS_SPECIES(2).UNC_REL  = 0.25;
  Q.ABS_SPECIES(2).UNC_ABS  = 20e-9;
  Q.ABS_SPECIES(2).CORRLEN  = 5e3;
  Q.ABS_SPECIES(2).LOG_ON   = false;
  %
  Q.ABS_SPECIES(3).TAG{1}   = 'O3-666-491e9-512e9';
  Q.ABS_SPECIES(3).RETRIEVE = true;
  Q.ABS_SPECIES(3).L2       = true;
  Q.ABS_SPECIES(3).GRID     = q2_pgrid( 10e3, 65e3, 8 );
  Q.ABS_SPECIES(3).L2NAME   = 'O3 / 501 GHz / 20 to 50 km';
  Q.ABS_SPECIES(3).UNC_REL  = 0.5;
  Q.ABS_SPECIES(3).UNC_ABS  = 0.5e-6;
  Q.ABS_SPECIES(3).CORRLEN  = 15e3;
  Q.ABS_SPECIES(3).LOG_ON   = false;
  %
  Q.ABS_SPECIES(4).TAG{1}   = 'O3-668-498e9-505e9';
  Q.ABS_SPECIES(4).RETRIEVE = true;
  Q.ABS_SPECIES(4).L2       = true;
  Q.ABS_SPECIES(4).GRID     = q2_pgrid( 10e3, 65e3, 4 );
  Q.ABS_SPECIES(4).L2NAME   = 'O3-dummy / 501 GHz';
  Q.ABS_SPECIES(4).UNC_REL  = 0.5;
  Q.ABS_SPECIES(4).UNC_ABS  = 0.5e-6;
  Q.ABS_SPECIES(4).CORRLEN  = 15e3;
  Q.ABS_SPECIES(4).LOG_ON   = true;
  %
  Q.ABS_SPECIES(5).TAG{1}   = 'H2O-*-400e9-650e9';
  Q.ABS_SPECIES(5).TAG{2}   = 'H2O-ForeignContStandardType';
  Q.ABS_SPECIES(5).TAG{3}   = 'H2O-SelfContStandardType';
  Q.ABS_SPECIES(5).RETRIEVE = true;
  Q.ABS_SPECIES(5).L2       = true;
  Q.ABS_SPECIES(5).GRID     = q2_pgrid( 10e3, 30e3, 4 );
  Q.ABS_SPECIES(5).L2NAME   = 'H2O-dummy / 501 GHz';
  Q.ABS_SPECIES(5).UNC_REL  = 0.5;
  Q.ABS_SPECIES(5).UNC_ABS  = 1e-6;
  Q.ABS_SPECIES(5).CORRLEN  = 5e3;
  Q.ABS_SPECIES(5).LOG_ON   = true;
  %
  Q.ABS_SPECIES(6).TAG{1}   = 'N2-SelfContMPM93';
  Q.ABS_SPECIES(6).RETRIEVE = false;
  %
  Q.ABS_SPECIES(7).TAG{1}   = 'O2-*-400e9-650e9';
  Q.ABS_SPECIES(7).RETRIEVE = false;
  %
  Q.ABS_SPECIES(8).TAG{1}   = 'HNO3-*-498e9-505e9';
  Q.ABS_SPECIES(8).RETRIEVE = false;
  %
  Q.ABS_SPECIES(9).TAG{1}   = 'CH3Cl-*-498e9-505e9';
  Q.ABS_SPECIES(9).RETRIEVE = false;
  %
  Q.ABS_SPECIES(10).TAG{1}   = 'H2O2-*-498e9-505e9';
  Q.ABS_SPECIES(10).RETRIEVE = false;
  %
  Q.ABS_SPECIES(11).TAG{1}   = 'O3-667-498e9-505e9';
  Q.ABS_SPECIES(11).RETRIEVE = true;
  Q.ABS_SPECIES(11).L2       = true;
  Q.ABS_SPECIES(11).GRID     = q2_pgrid( 10e3, 65e3, 4 );
  Q.ABS_SPECIES(11).L2NAME   = 'O3-dummy / 501 GHz';
  Q.ABS_SPECIES(11).UNC_REL  = 0.5;
  Q.ABS_SPECIES(11).UNC_ABS  = 0.5e-6;
  Q.ABS_SPECIES(11).CORRLEN  = 15e3;
  Q.ABS_SPECIES(11).LOG_ON   = true;
  %
  [Q.ABS_SPECIES.ISOFAC]     = deal( 1 );  
  [Q.ABS_SPECIES.SOURCE]     = deal( 'WebApi' );
  %-------------------------------------------------------------------------

    
 case 2
  %
  error( 'Fmode 2 not yet fully defined' );
  %
  Q.FRONTEND_NR             = 4;
  Q.F_LO_NOMINAL            = 548.500e9;
  Q.SIDEBAND_LEAKAGE        = 0.04;
  Q.BACKEND_NR              = 1;
  Q.F_BACKEND_NOMINAL       = [ 544120:544920 ]*1e6;
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'HNO3-*-534e9-554e9';
  Q.ABS_SPECIES(1).SOURCE   = 'WebApi';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 60e3 );
  Q.ABS_SPECIES(1).UNC_REL  = 0.75;
  Q.ABS_SPECIES(1).UNC_ABS  = 1e-9;
  Q.ABS_SPECIES(1).CORRLEN  = 5e3;
  Q.ABS_SPECIES(1).LOG_ON   = false;
  %
  Q.ABS_SPECIES(2).TAG{1}   = 'O3-*-444e9-554e9';
  Q.ABS_SPECIES(2).SOURCE   = 'WebApi';
  Q.ABS_SPECIES(2).RETRIEVE = true;
  Q.ABS_SPECIES(2).L2       = true;
  Q.ABS_SPECIES(2).GRID     = q2_pgrid( 10e3, 90e3 );
  Q.ABS_SPECIES(2).UNC_REL  = 0.5;
  Q.ABS_SPECIES(2).UNC_ABS  = 1e-6;
  Q.ABS_SPECIES(2).CORRLEN  = 5e3;
  Q.ABS_SPECIES(2).LOG_ON   = true;
  %
  Q.ABS_SPECIES(3).TAG{1}   = 'H2O';
  Q.ABS_SPECIES(3).TAG{2}   = 'H2O-ForeignContStandardType';
  Q.ABS_SPECIES(3).TAG{3}   = 'H2O-SelfContStandardType';
  Q.ABS_SPECIES(3).SOURCE   = 'WebApi';
  Q.ABS_SPECIES(3).RETRIEVE = false;
  %
  Q.ABS_SPECIES(4).TAG{1}   = 'N2-SelfContMPM93';
  Q.ABS_SPECIES(4).SOURCE   = 'WebApi';
  Q.ABS_SPECIES(4).RETRIEVE = false;
  %
  Q.ABS_SPECIES(5).TAG{1}   = 'O2-*-444e9-644e9';
  Q.ABS_SPECIES(5).SOURCE   = 'WebApi';
  Q.ABS_SPECIES(5).RETRIEVE = false;
  %
  [Q.ABS_SPECIES.ISOFAC]     = deal( 1 );  
  [Q.ABS_SPECIES.SOURCE]     = deal( 'WebApi' );
  %-------------------------------------------------------------------------

  
 case 21
  %
  if ~( strcmp( invemode, 'stnd' ) )
    error( 'Inversion modes of freqmode %d is: ''stnd''.', freqmode ); 
  end
  %
  Q.STOP_DX                  = 1;
  Q.GA_START                 = 100;
  Q.GA_FACTOR_NOT_OK         = 20;
  Q.GA_FACTOR_OK             = 100;
  Q.GA_MAX                   = 1e5;
  %
  Q.P_GRID                   = q2_pgrid( [], 150e3 ); 
  %
  Q.BACKEND_NR               = 1;
  Q.FRONTEND_NR              = 4;
  Q.F_LO_NOMINAL             = 547.753e9;
  Q.SIDEBAND_LEAKAGE         = 0.02;  %
  %
  Q.F_RANGES                 = [ 551.13e9 551.58e9; 551.72e9 552.17e9 ];
  Q.ZTAN_LIMIT_TOP           = 150e3;
  Q.ZTAN_LIMIT_BOT           = [ 30e3 30e3 30e3 30e3 ];
  Q.ZTAN_MIN_RANGE           = [ 40e3 75e3 ];
  %
  Q.T.L2                     = false;
  Q.T.GRID                   = q2_pgrid( 20e3, 150e3, 4 );
  Q.T.SOURCE                 = 'MSIS90';
  %
  Q.ABS_SPECIES(1).TAG{1}    = 'NO-*-541e9-562e9';
  Q.ABS_SPECIES(1).ISOFAC    = 1;
  Q.ABS_SPECIES(1).RETRIEVE  = true;
  Q.ABS_SPECIES(1).L2        = true;
  Q.ABS_SPECIES(1).L2NAME    = 'NO / 551 GHz / 25 to 100 km';
  Q.ABS_SPECIES(1).GRID      = q2_pgrid( 15e3, 150e3, 4 );
  Q.ABS_SPECIES(1).UNC_REL   = 1;
  Q.ABS_SPECIES(1).UNC_ABS   = 1e-8;
  Q.ABS_SPECIES(1).CORRLEN   = 10e3;
  Q.ABS_SPECIES(1).LOG_ON    = false;
  %
  Q.ABS_SPECIES(2).TAG{1}    = 'O3-*-541e9-562e9';
  Q.ABS_SPECIES(2).ISOFAC    = 1;
  Q.ABS_SPECIES(2).RETRIEVE  = true;
  Q.ABS_SPECIES(2).L2        = true;
  Q.ABS_SPECIES(2).GRID      = q2_pgrid( 15e3, 100e3, 4 );
  Q.ABS_SPECIES(2).L2NAME    = 'O3 / 551 GHz / 25 to 90 km';
  Q.ABS_SPECIES(2).UNC_REL   = 0.5;
  Q.ABS_SPECIES(2).UNC_ABS   = 1e-6;
  Q.ABS_SPECIES(2).CORRLEN   = 5e3;
  Q.ABS_SPECIES(2).LOG_ON    = false;
  %
  Q.ABS_SPECIES(3).TAG{1}    = 'H2O-171-541e9-562e9';
  Q.ABS_SPECIES(3).ISOFAC    = 3.71884e-04;
  Q.ABS_SPECIES(3).RETRIEVE  = true;
  Q.ABS_SPECIES(3).L2        = true;
  Q.ABS_SPECIES(3).GRID      = q2_pgrid( 15e3, 100e3, 4 );
  Q.ABS_SPECIES(3).L2NAME    = 'H2O-17 / 552 GHz / 25 to 90km';
  Q.ABS_SPECIES(3).UNC_REL   = 0.5;
  Q.ABS_SPECIES(3).UNC_ABS   = 1e-6;
  Q.ABS_SPECIES(3).CORRLEN   = 5e3;
  Q.ABS_SPECIES(3).LOG_ON    = false;
  %
  Q.ABS_SPECIES(4).TAG{1}    = 'H2O-161-450e9-700e9';
  Q.ABS_SPECIES(4).TAG{2}    = 'H2O-ForeignContStandardType';
  Q.ABS_SPECIES(4).TAG{3}    = 'H2O-SelfContStandardType';
  Q.ABS_SPECIES(4).ISOFAC    = 1;
  Q.ABS_SPECIES(4).RETRIEVE  = true;
  Q.ABS_SPECIES(4).L2        = false;
  Q.ABS_SPECIES(4).GRID      = q2_pgrid( 20e3, 35e3, 4 );
  Q.ABS_SPECIES(4).L2NAME    = 'H2O-dummy / 552 GHz';
  Q.ABS_SPECIES(4).UNC_REL   = 0.5;
  Q.ABS_SPECIES(4).UNC_ABS   = 0.5e-6;
  Q.ABS_SPECIES(4).CORRLEN   = 5e3;
  Q.ABS_SPECIES(4).LOG_ON    = true;
  %
  Q.ABS_SPECIES(5).TAG{1}    = 'N2-SelfContMPM93';
  Q.ABS_SPECIES(5).RETRIEVE  = false;
  %
  Q.ABS_SPECIES(6).TAG{1}    = 'O2-*-450e9-700e9';
  Q.ABS_SPECIES(6).RETRIEVE  = false;
  %
  Q.ABS_SPECIES(7).TAG{1}    = 'HNO3-*-548e9-555e9';
  Q.ABS_SPECIES(7).RETRIEVE  = false;
  %
  [Q.ABS_SPECIES.SOURCE]     = deal( 'Bdx' );
  %-------------------------------------------------------------------------
  
    
 otherwise
  error( 'Frequency band %d is not yet handled (or not defined).', freqmode );
end
