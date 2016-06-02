function Q = q_dev(varargin)

% For the moment, this is Patrick's playground

Q = q_meso( varargin{:} );

datadir              = '/home/patrick/Data/QsmrData';
Q.FOLDER_ABSLOOKUP   = fullfile( datadir, 'AbsLookup' );  
Q.FOLDER_BDX         = fullfile( datadir, 'SpeciesApriori', 'Bdx' );  
Q.FOLDER_FGRID       = fullfile( datadir, 'Fgrid' );  
Q.FOLDER_MSIS90      = fullfile( datadir, 'TemperatureApriori','MSIS90' );  

Q.ABSLOOKUP_OPTION   = '200mK_linear'; 

Q.FOLDER_WORK        = '/home/patrick/WORKAREA';
