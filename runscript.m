%run('Mscripts_qsystem/q2_init.m'); 
LOG = get_scan_log('http://malachite.rss.chalmers.se/rest_api/v4/freqmode_info/2015-04-01/AC2/1/')
L1B = get_scan_l1b_data(LOG.Info(1).URLS.URL_spectra)
[L2,L2I] = q2_inv( LOG.Info(1), L1B, q_std(1))
save('l2.mat', '-ascii', 'L2')
save('l2i.mat', '-ascii', 'L2I')

