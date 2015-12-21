function Q = q_joonas(fmode)
% 

Q = q_std( fmode );


topfolder            = q2_topfolder;
precalcdir           = '/home/joonask/Lookup/Qsmr2';
  
Q.FMODE              = fband;  

Q.FOLDER_ABSLOOKUP   = fullfile( precalcdir, 'AbsLookup' );  
Q.FOLDER_ANTENNA     = fullfile( precalcdir, 'Antenna' );  
Q.FOLDER_BACKEND     = fullfile( precalcdir, 'Backend' );  
Q.FOLDER_BDX         = fullfile( precalcdir, 'SpeciesApriori', 'Bdx' );  
Q.FOLDER_FGRID       = fullfile( precalcdir, 'Fgrid' );  

Q.T_SOURCE           = 'DONALETTY';

Q.ABSLOOKUP_OPTION   = '200mK';

