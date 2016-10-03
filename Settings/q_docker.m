function Q = q_docker(fmode)

config = getenv('QSMR_CONFIG');
invemode = getenv('QSMR_INVEMODE');

if strcmp(config, ''), config = 'q_std'; end
if strcmp(invemode, ''), invemode = 'stnd'; end

disp(sprintf('Using config %s with freqmode %d and invmode %s', ...
             config, fmode, invemode));

Q = eval(sprintf('%s(%d,''%s'')', config, fmode, invemode));

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
