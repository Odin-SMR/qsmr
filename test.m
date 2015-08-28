function [Q,R] = test(fband)
%
if nargin < 1, fband = 1; end

%- Init Qsmr
%
r = q2_init( false );
%
if ~isempty(r), disp(r), return, end


%- Init R
%
R = q2_init_r;


%- Set and check Q
%
Q = q_std;
r = q2_check_q( Q, R );
%
if ~isempty(r), disp(r), return, end


%- Set workfolder
%
[R,r] = q2_create_workfolder( Q, R );
%
if ~isempty(r), disp(r), return, end
%
cu = onCleanup( @()delete_tmpfolder( R.WORK_FOLDER ) );




