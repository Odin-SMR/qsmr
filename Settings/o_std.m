function O = o_std(fband)
% 
if length(fband) > 1
  for i = 1 : length(fband)
    O(i) = o_std( fband(i) );
  end
  return
end
%----------------------------------------------------------------------------


%---------------------------------------------------------------------------
%--- General settings
%---------------------------------------------------------------------------

topfolder            = q2_topfolder;
precalcdir           = '/home/patrick/Outdata2/Qsmr2';
  
O.FBAND              = fband;  

O.FOLDER_ABSLOOKUP   = fullfile( precalcdir, 'AbsLookup' );  
O.FOLDER_ANTENNA     = fullfile( precalcdir, 'Antenna' );  
O.FOLDER_BACKEND     = fullfile( precalcdir, 'Backend' );  
O.FOLDER_BDX         = fullfile( precalcdir, 'SpeciesApriori', 'Bdx' );  
O.FOLDER_FGRID       = fullfile( precalcdir, 'Fgrid' );  

O.T_SOURCE           = 'MSIS90';

O.ABSLOOKUP_OPTION   = '100mK_linear';
O.ABS_P_INTERP_ORDER = 3;  % 5 is recommended value
O.ABS_T_INTERP_ORDER = 5;  % 7 is recommended value

O.PPATH_LMAX         = 25e3;
O.PPATH_LRAYTRACE    = 6e3;

O.CONTINUA_FILE      = fullfile( topfolder, 'DataFiles', 'Continua', ...
                                                         'continua_std.arts' );

%O.DZA_MAX_IN_CORE    = 0.005;
%O.DZA_GRID_EDGES     = [ O.DZA_MAX_IN_CORE*[1:4 6 9 13 18 24 31 42] ];

O.DZA_MAX_IN_CORE    = 0.01;
O.DZA_GRID_EDGES     = [ O.DZA_MAX_IN_CORE*[1:3 5 8 12 21] ];

O.SIDEBAND_LEAKAGE   = 0.01;

%---------------------------------------------------------------------------
%--- Band specific
%---------------------------------------------------------------------------

switch fband
  
 case 1
  %
  O.ABS_SPECIES(1).TAG{1}   = 'ClO';
  O.ABS_SPECIES(1).SOURCE   = 'Bdx';
  O.ABS_SPECIES(1).RETRIEVE = true;
  O.ABS_SPECIES(1).L2       = true;
  O.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 60e3 );
  %
  O.ABS_SPECIES(2).TAG{1}   = 'O3';
  O.ABS_SPECIES(2).SOURCE   = 'Bdx';
  O.ABS_SPECIES(2).RETRIEVE = true;
  O.ABS_SPECIES(2).L2       = true;
  O.ABS_SPECIES(2).GRID     = q2_pgrid( 10e3, 80e3 );
  %
  O.ABS_SPECIES(3).TAG{1}   = 'N2O';
  O.ABS_SPECIES(3).SOURCE   = 'Bdx';
  O.ABS_SPECIES(3).RETRIEVE = false;
  %
  O.ABS_SPECIES(4).TAG{1}   = 'H2O';
  O.ABS_SPECIES(4).TAG{2}   = 'H2O-ForeignContStandardType';
  O.ABS_SPECIES(4).TAG{3}   = 'H2O-SelfContStandardType';
  O.ABS_SPECIES(4).SOURCE   = 'Bdx';
  O.ABS_SPECIES(4).RETRIEVE = false;
  %
  O.ABS_SPECIES(5).TAG{1}   = 'N2-SelfContMPM93';
  O.ABS_SPECIES(5).SOURCE   = 'Bdx';
  O.ABS_SPECIES(5).RETRIEVE = false;
  %
  O.ABS_SPECIES(6).TAG{1}   = 'O2';
  O.ABS_SPECIES(6).SOURCE   = 'Bdx';
  O.ABS_SPECIES(6).RETRIEVE = false;
  %
  O.FBAND_NAME              = 'SM_AC2ab';
  O.F_BACKEND_NOMINAL       = [ 501180:501580 502180:502380 ]*1e6;
  O.F_LO_NOMINAL            = 497.88e9;
  %
  O.P_GRID                  = q2_pgrid( [], 90e3, true );
  %-------------------------------------------------------------------------

    
 case 2
  %
  O.ABS_SPECIES(1).TAG{1}   = 'HNO3';
  O.ABS_SPECIES(1).SOURCE   = 'Bdx';
  O.ABS_SPECIES(1).RETRIEVE = true;
  O.ABS_SPECIES(1).L2       = true;
  O.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 60e3 );
  %
  O.ABS_SPECIES(2).TAG{1}   = 'O3';
  O.ABS_SPECIES(2).SOURCE   = 'Bdx';
  O.ABS_SPECIES(2).RETRIEVE = true;
  O.ABS_SPECIES(2).L2       = true;
  O.ABS_SPECIES(2).GRID     = q2_pgrid( 10e3, 90e3 );
  %
  O.ABS_SPECIES(3).TAG{1}   = 'H2O';
  O.ABS_SPECIES(3).TAG{2}   = 'H2O-ForeignContStandardType';
  O.ABS_SPECIES(3).TAG{3}   = 'H2O-SelfContStandardType';
  O.ABS_SPECIES(3).SOURCE   = 'Bdx';
  O.ABS_SPECIES(3).RETRIEVE = false;
  %
  O.ABS_SPECIES(4).TAG{1}   = 'N2-SelfContMPM93';
  O.ABS_SPECIES(4).SOURCE   = 'Bdx';
  O.ABS_SPECIES(4).RETRIEVE = false;
  %
  O.ABS_SPECIES(5).TAG{1}   = 'O2';
  O.ABS_SPECIES(5).SOURCE   = 'Bdx';
  O.ABS_SPECIES(5).RETRIEVE = false;
  %
  O.FBAND_NAME              = 'SM_AC1e';
  O.F_BACKEND_NOMINAL       = [ 544120:544920 ]*1e6;
  O.F_LO_NOMINAL            = 548.500e9;
  %
  O.P_GRID                  = q2_pgrid( [], 90e3, true ); 
  %-------------------------------------------------------------------------

    
 otherwise
  error( 'Frequency band %d is not yet handled (or not defined).', fband );
end

  

  