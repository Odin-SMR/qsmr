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
%--- Folders holding pre-calculated data
%---------------------------------------------------------------------------

precalcdir           = '/home/patrick/Outdata2/Qsmr2';
Q.FOLDER_ABSLOOKUP   = fullfile( precalcdir, 'AbsLookup' );  
Q.FOLDER_ANTENNA     = fullfile( precalcdir, 'Antenna' );  
Q.FOLDER_BACKEND     = fullfile( precalcdir, 'Backend' );  
Q.FOLDER_BDX         = fullfile( precalcdir, 'SpeciesApriori', 'Bdx' );  
Q.FOLDER_FGRID       = fullfile( precalcdir, 'Fgrid' );  



%---------------------------------------------------------------------------
%--- Other folders
%---------------------------------------------------------------------------

Q.FOLDER_ARTSXMLDATA = '/home/patrick/SVN/ARTS/arts-xml-data';
Q.FOLDER_WORK        = '/home/patrick/WORKAREA';
%Q.FOLDER_WORK        = '/tmp';


%---------------------------------------------------------------------------
%--- Absorption tables
%---------------------------------------------------------------------------

Q.ABSLOOKUP_OPTION   = '100mK_linear';
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

Q.TB_SCALING_FAC     = [];%1.0025;
Q.TB_CONTRAST_FAC    = [];%1.03;



%---------------------------------------------------------------------------
%--- OEM settings
%---------------------------------------------------------------------------

Q.STOP_DX            = 1;
Q.GA_START           = 1;
Q.GA_FACTOR_NOT_OK   = 10;
Q.GA_FACTOR_OK       = 10;
Q.GA_MAX             = 1e4;



%---------------------------------------------------------------------------
%--- Retrieval settings
%---------------------------------------------------------------------------

Q.NOISE_CORRMODEL    = 'empi';  % 'none', 'empi' 'expo'
Q.NOISE_SCALEFAC     = 1.1;

Q.BASELINE.RETRIEVE  = true;
Q.BASELINE.PIECEWISE = true;
Q.BASELINE.UNC       = 2;

Q.POINTING.RETRIEVE  = true;
Q.POINTING.UNC       = 0.01;

Q.FREQUENCY.RETRIEVE = true;
Q.FREQUENCY.UNC      = 1e6;

Q.T.SOURCE           = 'MSIS90';
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
  Q.P_GRID                  = q2_pgrid( [], 70e3, true ); 
  %
  Q.BACKEND_NR              = 2;
  Q.FRONTEND_NR             = 2;
  Q.F_LO_NOMINAL            = 497.885e9;
  Q.SIDEBAND_LEAKAGE        = 0.02;
  %
  Q.F_RANGES                = [ 501.16e9 501.60e9; 501.96e9 502.40e9 ];
  Q.ZTAN_LIMIT_TOP          = 60e3;
  Q.ZTAN_LIMIT_BOT          = [ 20e3 17e3 13e3 13e3 ];
  %
  Q.T.L2                    = false;
  Q.T.GRID                  = q2_pgrid( 10e3, 65e3 );
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'ClO-*-491e9-512e9';
  Q.ABS_SPECIES(1).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).L2NAME   = 'ClO-501GHz-20to50km';
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 65e3 );
  Q.ABS_SPECIES(1).UNC_REL  = 0.5;
  Q.ABS_SPECIES(1).UNC_ABS  = 2.5e-10;
  Q.ABS_SPECIES(1).CORRLEN  = 5e3;
  Q.ABS_SPECIES(1).LOG_ON   = false;
  %
  Q.ABS_SPECIES(2).TAG{1}   = 'O3-666-501.2e9-501.6e9';
  Q.ABS_SPECIES(2).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(2).RETRIEVE = true;
  Q.ABS_SPECIES(2).L2       = true;
  Q.ABS_SPECIES(2).GRID     = q2_pgrid( 10e3, 65e3 );
  Q.ABS_SPECIES(2).L2NAME   = 'O3-501GHz-20to50km';
  Q.ABS_SPECIES(2).UNC_REL  = 0.5;
  Q.ABS_SPECIES(2).UNC_ABS  = 0.5e-6;
  Q.ABS_SPECIES(2).CORRLEN  = 5e3;
  Q.ABS_SPECIES(2).LOG_ON   = false;
  %
  Q.ABS_SPECIES(3).TAG{1}   = 'O3-*-401e9-602e9';
  Q.ABS_SPECIES(3).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(3).RETRIEVE = true;
  Q.ABS_SPECIES(3).L2       = true;
  Q.ABS_SPECIES(3).GRID     = q2_pgrid( 10e3, 65e3 );
  Q.ABS_SPECIES(3).L2NAME   = 'O3-dummy-501GHz-20to50km';
  Q.ABS_SPECIES(3).UNC_REL  = 0.5;
  Q.ABS_SPECIES(3).UNC_ABS  = 0.5e-6;
  Q.ABS_SPECIES(3).CORRLEN  = 5e3;
  Q.ABS_SPECIES(3).LOG_ON   = false;
  %
  Q.ABS_SPECIES(4).TAG{1}   = 'N2O-*-491e9-512e9';
  Q.ABS_SPECIES(4).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(4).RETRIEVE = true;
  Q.ABS_SPECIES(4).L2       = true;
  Q.ABS_SPECIES(4).L2NAME   = 'N2O-502GHz-20-50km';
  Q.ABS_SPECIES(4).GRID     = q2_pgrid( 10e3, 65e3 );
  Q.ABS_SPECIES(4).UNC_REL  = 0.25;
  Q.ABS_SPECIES(4).UNC_ABS  = 20e-9;
  Q.ABS_SPECIES(4).CORRLEN  = 5e3;
  Q.ABS_SPECIES(4).LOG_ON   = false;
  %
  Q.ABS_SPECIES(5).TAG{1}   = 'H2O';
  Q.ABS_SPECIES(5).TAG{2}   = 'H2O-ForeignContStandardType';
  Q.ABS_SPECIES(5).TAG{3}   = 'H2O-SelfContStandardType';
  Q.ABS_SPECIES(5).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(5).RETRIEVE = true;
  Q.ABS_SPECIES(5).L2       = false;
  Q.ABS_SPECIES(5).GRID     = q2_pgrid( 10e3, 30e3 );
  Q.ABS_SPECIES(5).UNC_REL  = 0.5;
  Q.ABS_SPECIES(5).UNC_ABS  = 1e-6;
  Q.ABS_SPECIES(5).CORRLEN  = 5e3;
  Q.ABS_SPECIES(5).LOG_ON   = true;
  %
  Q.ABS_SPECIES(6).TAG{1}   = 'N2-SelfContMPM93';
  Q.ABS_SPECIES(6).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(6).RETRIEVE = false;
  %
  Q.ABS_SPECIES(7).TAG{1}   = 'O2';
  Q.ABS_SPECIES(7).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(7).RETRIEVE = false;
  %
  Q.ABS_SPECIES(8).TAG{1}   = 'HNO3-*-491e9-512e9';
  Q.ABS_SPECIES(8).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(8).RETRIEVE = false;
  %
  Q.ABS_SPECIES(9).TAG{1}   = 'CH3Cl-*-491e9-511e9';
  Q.ABS_SPECIES(9).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(9).RETRIEVE = false;
  %
  Q.ABS_SPECIES(10).TAG{1}   = 'H2O2-*-491e9-511e9';
  Q.ABS_SPECIES(10).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(10).RETRIEVE = false;
  %-------------------------------------------------------------------------

    
 case 2
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'HNO3-*-534e9-554e9';
  Q.ABS_SPECIES(1).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 60e3 );
  Q.ABS_SPECIES(1).UNC_REL  = 0.75;
  Q.ABS_SPECIES(1).UNC_ABS  = 1e-9;
  Q.ABS_SPECIES(1).CORRLEN  = 5e3;
  Q.ABS_SPECIES(1).LOG_ON   = false;
  %
  Q.ABS_SPECIES(2).TAG{1}   = 'O3-*-444e9-554e9';
  Q.ABS_SPECIES(2).SOURCE   = 'Bdx';
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
  Q.ABS_SPECIES(3).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(3).RETRIEVE = false;
  %
  Q.ABS_SPECIES(4).TAG{1}   = 'N2-SelfContMPM93';
  Q.ABS_SPECIES(4).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(4).RETRIEVE = false;
  %
  Q.ABS_SPECIES(5).TAG{1}   = 'O2-*-444e9-644e9';
  Q.ABS_SPECIES(5).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(5).RETRIEVE = false;
  %
  Q.FRONTEND_NR             = 4;
  Q.F_LO_NOMINAL            = 548.500e9;
  Q.SIDEBAND_LEAKAGE        = 0.04;
  Q.BACKEND_NR              = 1;
  Q.F_BACKEND_NOMINAL       = [ 544120:544920 ]*1e6;
  %-------------------------------------------------------------------------

  
 case 21
  %
  if ~( strcmp( invemode, 'stnd' ) )
    error( 'Inversion modes of freqmode %d is: ''stnd''.', freqmode ); 
  end
  %
  Q.P_GRID                  = q2_pgrid( [], 120e3, true ); 
  %
  Q.BACKEND_NR              = 1;
  Q.FRONTEND_NR             = 4;
  Q.F_LO_NOMINAL            = 547.753e9;
  Q.SIDEBAND_LEAKAGE        = 0.02;  %
  %
  Q.F_RANGES                = [ 551.13e9 551.58e9; 551.72e9 552.17e9 ];
  Q.ZTAN_LIMIT_TOP          = 110e3;
  Q.ZTAN_LIMIT_BOT          = [ 25e3 25e3 25e3 25e3 ];
  %
  Q.T.L2                    = false;
  Q.T.GRID                  = q2_pgrid( 20e3, 120e3 );
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'NO-*-541e9-562e9';
  Q.ABS_SPECIES(1).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).L2NAME   = 'NO-551GHz-25to100km';
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 20e3, 120e3 );
  Q.ABS_SPECIES(1).UNC_REL  = 2;
  Q.ABS_SPECIES(1).UNC_ABS  = 2e-8;
  Q.ABS_SPECIES(1).CORRLEN  = 20e3;
  Q.ABS_SPECIES(1).LOG_ON   = true;
  %
  Q.ABS_SPECIES(2).TAG{1}   = 'O3-*-451e9-652e9';
  Q.ABS_SPECIES(2).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(2).RETRIEVE = true;
  Q.ABS_SPECIES(2).L2       = true;
  Q.ABS_SPECIES(2).GRID     = q2_pgrid( 20e3, 120e3 );
  Q.ABS_SPECIES(2).L2NAME   = 'O3-551GHz-25to90km';
  Q.ABS_SPECIES(2).UNC_REL  = 0.5;
  Q.ABS_SPECIES(2).UNC_ABS  = 0.5e-6;
  Q.ABS_SPECIES(2).CORRLEN  = 5e3;
  Q.ABS_SPECIES(2).LOG_ON   = false;
  %
  Q.ABS_SPECIES(3).TAG{1}   = 'H2O-171-551e9-553e9';
  Q.ABS_SPECIES(3).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(3).RETRIEVE = true;
  Q.ABS_SPECIES(3).L2       = true;
  Q.ABS_SPECIES(3).GRID     = q2_pgrid( 20e3, 120e3 );
  Q.ABS_SPECIES(3).L2NAME   = 'H2O/17-552GHz-25to90km';
  Q.ABS_SPECIES(3).UNC_REL  = 0.5;
  Q.ABS_SPECIES(3).UNC_ABS  = 1e-6;
  Q.ABS_SPECIES(3).CORRLEN  = 5e3;
  Q.ABS_SPECIES(3).LOG_ON   = false;
  %
  Q.ABS_SPECIES(4).TAG{1}   = 'H2O';
  Q.ABS_SPECIES(4).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(4).RETRIEVE = true;
  Q.ABS_SPECIES(4).L2       = false;
  Q.ABS_SPECIES(4).GRID     = q2_pgrid( 20e3, 35e3 );
  Q.ABS_SPECIES(4).UNC_REL  = 0.5;
  Q.ABS_SPECIES(4).UNC_ABS  = 0.5e-6;
  Q.ABS_SPECIES(4).CORRLEN  = 5e3;
  Q.ABS_SPECIES(4).LOG_ON   = false;
  %
  Q.ABS_SPECIES(5).TAG{1}   = 'N2-SelfContMPM93';
  Q.ABS_SPECIES(5).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(5).RETRIEVE = false;
  %
  Q.ABS_SPECIES(6).TAG{1}   = 'O2';
  Q.ABS_SPECIES(6).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(6).RETRIEVE = false;
  %
  Q.ABS_SPECIES(7).TAG{1}   = 'HNO3-*-541e9-562e9';
  Q.ABS_SPECIES(7).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(7).RETRIEVE = false;
  %-------------------------------------------------------------------------
  
    
 otherwise
  error( 'Frequency band %d is not yet handled (or not defined).', freqmode );
end
