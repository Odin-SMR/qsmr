% Run calculation and send results as json to an api if target_url
% is provided. If not, write results to .mat files.
% example source url:
% http://malachite.rss.chalmers.se/rest_api/v4/freqmode_info/2015-04-01/AC2/1/7123991206/
function []=runscript(source_url, target_url, target_username, target_password)
   %run('Mscripts_qsystem/q2_init.m');
   LOG = get_scan_log(source_url)
   L1B = get_scan_l1b_data(LOG.Info.URLS.URL_spectra)

   % Extract freq mode from url
   urlparts = strsplit(source_url, '/')
   if isequal(urlparts(end), {''})
      freqmode = cellfun(@str2num, urlparts(end-2))
   else
      freqmode = cellfun(@str2num, urlparts(end-1))
   end

   [L2,L2I] = q2_inv( LOG.Info, L1B, q_docker(freqmode))

   if nargin < 2
      save('L2.mat', 'L2')
      save('L2I.mat', 'L2I')
   else
       options = weboptions('MediaType','application/json', 'Username', ...
                            target_username, 'Password', target_password)
       data = struct('L2', L2, 'L2I', L2I)
       response = webwrite(target_url, data, options)
return
