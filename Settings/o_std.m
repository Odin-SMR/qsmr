function O = o_std(fmode)
% 
if length(fmode) > 1
  for i = 1 : length(fmode)
    O(i) = o_std( fmode(i) );
  end
  return
end
%----------------------------------------------------------------------------


%---------------------------------------------------------------------------
%--- General settings
%---------------------------------------------------------------------------

topfolder            = q2_topfolder;
precalcdir           = '/home/patrick/Outdata2/Qsmr2';
  
O.FMODE              = fmode;  

O.FOLDER_ABSLOOKUP   = fullfile( precalcdir, 'AbsLookup' );  
O.FOLDER_ANTENNA     = fullfile( precalcdir, 'Antenna' );  
O.FOLDER_BACKEND     = fullfile( precalcdir, 'Backend' );  
O.FOLDER_BDX         = fullfile( precalcdir, 'SpeciesApriori', 'Bdx' );  
O.FOLDER_FGRID       = fullfile( precalcdir, 'Fgrid' );  

O.T_SOURCE           = 'MSIS90';

O.ABSLOOKUP_OPTION   = '100mK_linear';
O.F_GRID_NFILL       = 0;
O.ABS_P_INTERP_ORDER = 1;
O.ABS_T_INTERP_ORDER = 3;


% Only used when setting up absorption tables, and if on-the-fly would be done
O.P_GRID             = q2_pgrid( [], 90e3, true ); 

O.PPATH_LMAX         = 10e3;
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

switch fmode
  
 case 1
  %
  O.ABS_SPECIES(1).TAG{1}   = 'ClO-*-491e9-511e9';
  O.ABS_SPECIES(1).SOURCE   = 'Bdx';
  O.ABS_SPECIES(1).RETRIEVE = true;
  O.ABS_SPECIES(1).L2       = true;
  O.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 60e3 );
  %
  O.ABS_SPECIES(2).TAG{1}   = 'O3-*-401e9-601e9';
  O.ABS_SPECIES(2).SOURCE   = 'Bdx';
  O.ABS_SPECIES(2).RETRIEVE = true;
  O.ABS_SPECIES(2).L2       = true;
  O.ABS_SPECIES(2).GRID     = q2_pgrid( 10e3, 80e3 );
  %
  O.ABS_SPECIES(3).TAG{1}   = 'N2O-*-491e9-511e9';
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
  O.ABS_SPECIES(6).TAG{1}   = 'O2-*-401e9-601e9';
  O.ABS_SPECIES(6).SOURCE   = 'Bdx';
  O.ABS_SPECIES(6).RETRIEVE = false;
  %
  O.BACKEND_NR              = '2';
  O.FRONTEND_NR             = '2';
  O.F_BACKEND_NOMINAL       = [ 501180:501580 502180:502380 ]*1e6;
  O.F_LO_NOMINAL            = 497.88e9;
  %-------------------------------------------------------------------------

    
 case 2
  %
  O.ABS_SPECIES(1).TAG{1}   = 'HNO3-*-534e9-554e9';
  O.ABS_SPECIES(1).SOURCE   = 'Bdx';
  O.ABS_SPECIES(1).RETRIEVE = true;
  O.ABS_SPECIES(1).L2       = true;
  O.ABS_SPECIES(1).GRID     = q2_pgrid( 10e3, 60e3 );
  %
  O.ABS_SPECIES(2).TAG{1}   = 'O3-*-444e9-554e9';
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
  O.ABS_SPECIES(5).TAG{1}   = 'O2-*-444e9-644e9';
  O.ABS_SPECIES(5).SOURCE   = 'Bdx';
  O.ABS_SPECIES(5).RETRIEVE = false;
  %
  O.BACKEND_NR              = '1';
  %O.FRONTEND_NR             = '1';
  O.F_BACKEND_NOMINAL       = [ 544120:544920 ]*1e6;
  O.F_LO_NOMINAL            = 548.500e9;
  %-------------------------------------------------------------------------

    
 otherwise
  error( 'Frequency band %d is not yet handled (or not defined).', fmode );
end

  

  