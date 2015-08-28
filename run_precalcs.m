function run_precalcs

P = p_std;
Q = q_std;

R = q2_init_r;
R.WORK_FOLDER = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( R.WORK_FOLDER ) );

precs = [ 200 100 50 25 ]*1e-3;
  
q2_precalc_abslookup( o_std(1), P, R, precs );

return

q2_precalc_antenna( o_std(q2_fbands), P );
q2_precalc_backend( o_std(1), P );
q2_precalc_bdx_apriori( o_std(1), P ); 

precs = [ 25 50 100 200 ]*1e-3;
  
q2_precalc_fgrid( o_std(q2_fbands), P, R, precs );
q2_precalc_abslookup( o_std(q2_fbands), P, R, precs );