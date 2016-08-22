function Q = q_docker(fmode)

Q = q_std( fmode );

Q.ARTS               = 'LD_LIBRARY_PATH="" arts';
Q.FOLDER_WORK        = '/tmp';

datadir            = '/QsmrData';

Q.FOLDER_ABSLOOKUP   = fullfile( datadir, 'AbsLookup', Q.INVEMODE );
Q.FOLDER_BDX         = fullfile( datadir, 'SpeciesApriori', 'Bdx' );
Q.FOLDER_FGRID       = fullfile( datadir, 'Fgrid', Q.INVEMODE );
Q.FOLDER_MSIS90      = fullfile( datadir, 'TemperatureApriori', 'MSIS90' );

topfolder            = '/qsmr';
Q.FOLDER_ANTENNA     = fullfile( topfolder, 'DataFiles', 'Antenna' );
Q.FOLDER_BACKEND     = fullfile( topfolder, 'DataFiles', 'Backend' );
