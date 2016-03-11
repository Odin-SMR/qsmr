function Q = q_dev(varargin)

Q = q_std( varargin{:} );

datadir              = '/home/patrick/Outdata2/Qsmr2';
Q.FOLDER_ABSLOOKUP   = fullfile( datadir, 'AbsLookup' );  
Q.FOLDER_BDX         = fullfile( datadir, 'SpeciesApriori', 'Bdx' );  
Q.FOLDER_FGRID       = fullfile( datadir, 'Fgrid' );  

Q.ABSLOOKUP_OPTION   = '200mK_linear'; %'100mK_linear';

Q.FOLDER_ARTSXMLDATA = '/home/patrick/SVN/ARTS/arts-xml-data';

Q.FOLDER_WORK        = '/home/patrick/WORKAREA';
