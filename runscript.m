% example url: http://malachite.rss.chalmers.se/rest_api/v4/freqmode_info/2015-04-01/AC2/1/7123991206/
function []=runscript(url)
   %run('Mscripts_qsystem/q2_init.m');
   LOG = get_scan_log(url)
   L1B = get_scan_l1b_data(LOG.Info.URLS.URL_spectra)

   % Extract freq mode from url
   urlparts = strsplit(url, '/')
   if isequal(urlparts(end), {''})
      freqmode = cellfun(@str2num, urlparts(end-2))
   else
      freqmode = cellfun(@str2num, urlparts(end-1))
   end

   [L2,L2I] = q2_inv( LOG.Info, L1B, q_std(freqmode))
   save('l2.mat', '-ascii', 'L2')
   save('l2i.mat', '-ascii', 'L2I')
return
