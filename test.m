function [Q,R] = test(fband)
%
if nargin < 1, fband = 1; end

%- Init Qsmr
%
R  = q2_init;


%- Set and check Q
%
Q  = q_std;
q2_check_q( Q, R );


%- Set workfolder
%
R  = q2_create_workfolder( Q, R );
%
cu = onCleanup( @()delete_tmpfolder( R.WORK_FOLDER ) );




