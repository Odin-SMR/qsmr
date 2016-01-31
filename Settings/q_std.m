function Q = q_std(fmode)
% 
assert( length(fmode) == 1 );


%---------------------------------------------------------------------------
%--- Various general
%---------------------------------------------------------------------------

Q.FMODE              = fmode;  
  
Q.T_SOURCE           = 'MSIS90';



%---------------------------------------------------------------------------
%--- Pre-calculations
%---------------------------------------------------------------------------

Q.P_GRID             = q2_pgrid( [], 90e3, true ); 

precalcdir           = '/home/patrick/Outdata2/Qsmr2';
Q.FOLDER_ABSLOOKUP   = fullfile( precalcdir, 'AbsLookup' );  
Q.FOLDER_ANTENNA     = fullfile( precalcdir, 'Antenna' );  
Q.FOLDER_BACKEND     = fullfile( precalcdir, 'Backend' );  
Q.FOLDER_BDX         = fullfile( precalcdir, 'SpeciesApriori', 'Bdx' );  
Q.FOLDER_FGRID       = fullfile( precalcdir, 'Fgrid' );  



%---------------------------------------------------------------------------
%--- Folders
%---------------------------------------------------------------------------

topfolder            = q2_topfolder;
Q.FOLDER_ARTSXMLDATA = '/home/patrick/SVN/ARTS/arts-xml-data';
Q.FOLDER_WORK        = '/home/patrick/WORKAREA';
%Q.FOLDER_WORK        = '/tmp';


%---------------------------------------------------------------------------
%--- Absorption 
%---------------------------------------------------------------------------

Q.ABSLOOKUP_OPTION   = '100mK_linear';
Q.F_GRID_NFILL       = 0;
Q.ABS_P_INTERP_ORDER = 1;
Q.ABS_T_INTERP_ORDER = 3;
Q.CONTINUA_FILE      = fullfile( topfolder, 'DataFiles', 'Continua', ...
                                                         'continua_std.arts' );
  
  
%---------------------------------------------------------------------------
%--- RT and sensor
%---------------------------------------------------------------------------

Q.PPATH_LMAX         = 15e3;
Q.PPATH_LRAYTRACE    = 20e3;

Q.DZA_MAX_IN_CORE    = 0.01;
Q.DZA_GRID_EDGES     = [ Q.DZA_MAX_IN_CORE*[1:3 5 8 12 21] ];

Q.F_BACKEND_COMMON   = true;



%---------------------------------------------------------------------------
%--- OEM settings
%---------------------------------------------------------------------------

Q.STOP_DX            = 0.1;
Q.GA_START           = 10;
Q.GA_FACTOR_NOT_OK   = 10;
Q.GA_FACTOR_OK       = 10;
Q.GA_MAX             = 1e4;



%---------------------------------------------------------------------------
%--- Retrieval settings
%---------------------------------------------------------------------------

Q.NOISE_SCALEFAC     = 1.2;

Q.BASELINE_PIECEWISE = true;
Q.BASELINE_SI        = 2;

Q.POINTING_SI        = 0.01;
Q.FREQUENCY_SI       = 1e6;



%---------------------------------------------------------------------------
%--- Band specific
%---------------------------------------------------------------------------

switch fmode
  
 case 1
  %
  Q.ABS_SPECIES(1).TAG{1}   = 'ClO-*-491e9-511e9';
  Q.ABS_SPECIES(1).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(1).RETRIEVE = true;
  Q.ABS_SPECIES(1).L2       = true;
  Q.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 60e3 );
  Q.ABS_SPECIES(1).UNC_REL  = 0.5;
  Q.ABS_SPECIES(1).UNC_ABS  = 5e-10;
  Q.ABS_SPECIES(1).CORRLEN  = 5e3;
  Q.ABS_SPECIES(1).LOG_ON   = false;
  %
  Q.ABS_SPECIES(2).TAG{1}   = 'O3-*-401e9-601e9';
  Q.ABS_SPECIES(2).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(2).RETRIEVE = true;
  Q.ABS_SPECIES(2).L2       = true;
  Q.ABS_SPECIES(2).GRID     = q2_pgrid( 10e3, 80e3 );
  Q.ABS_SPECIES(2).UNC_REL  = 0.5;
  Q.ABS_SPECIES(2).UNC_ABS  = 1e-6;
  Q.ABS_SPECIES(2).CORRLEN  = 5e3;
  Q.ABS_SPECIES(2).LOG_ON   = true;
  %
  Q.ABS_SPECIES(3).TAG{1}   = 'N2O-*-491e9-511e9';
  Q.ABS_SPECIES(3).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(3).RETRIEVE = true;
  Q.ABS_SPECIES(3).L2       = true;
  Q.ABS_SPECIES(3).GRID     = q2_pgrid( 10e3, 60e3 );
  Q.ABS_SPECIES(3).UNC_REL  = 0.5;
  Q.ABS_SPECIES(3).UNC_ABS  = 10e-9;
  Q.ABS_SPECIES(3).CORRLEN  = 5e3;
  Q.ABS_SPECIES(3).LOG_ON   = true;
  %
  Q.ABS_SPECIES(4).TAG{1}   = 'H2O';
  Q.ABS_SPECIES(4).TAG{2}   = 'H2O-ForeignContStandardType';
  Q.ABS_SPECIES(4).TAG{3}   = 'H2O-SelfContStandardType';
  Q.ABS_SPECIES(4).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(4).RETRIEVE = true;
  Q.ABS_SPECIES(4).L2       = false;
  Q.ABS_SPECIES(4).GRID     = q2_pgrid( 10e3, 30e3 );
  Q.ABS_SPECIES(4).UNC_REL  = 0.5;
  Q.ABS_SPECIES(4).UNC_ABS  = 2e-6;
  Q.ABS_SPECIES(4).CORRLEN  = 5e3;
  Q.ABS_SPECIES(4).LOG_ON   = true;
  %
  Q.ABS_SPECIES(5).TAG{1}   = 'N2-SelfContMPM93';
  Q.ABS_SPECIES(5).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(5).RETRIEVE = false;
  %
  Q.ABS_SPECIES(6).TAG{1}   = 'O2-*-401e9-601e9';
  Q.ABS_SPECIES(6).SOURCE   = 'Bdx';
  Q.ABS_SPECIES(6).RETRIEVE = false;
  %
  Q.FRONTEND_NR             = 2;
  Q.F_LO_NOMINAL            = 497.88e9;
  Q.SIDEBAND_LEAKAGE        = 0.02;
  Q.BACKEND_NR              = 2;
  Q.F_BACKEND_NOMINAL       = [ 501180:501580 502180:502380 ]*1e6;
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

    
 otherwise
  error( 'Frequency band %d is not yet handled (or not defined).', fmode );
end
