% returns a structure with log information
% of scans from the given dates and freqmode
%
% Usage:
%
% info = get_logdata4freqmode(freqmode,mjd1,mjd2,webapi_url)
%
% Out:  
%     info  structure with logdata
%     a link to field descriptions to come..
%      AltEnd:  
%      AltStart 
%      DateTime 
%      FreqMode 
%      LatEnd 
%      LatStart
%      LonEnd 
%      LonStart 
%      MJDEnd 
%      MJDStart 
%      NumSpec 
%      ScanID 
%      SunZD 
%      URLS
%         URLs to l1b and aux data
% In:    
%     mjdvec vector with mjd
%     freqmode  scalar 
%     webapi_url optional default is to search data from the odin
%     live database
%   
% Example Usage:
%
%      mjd1 = datenum('2015-01-03') - datenum('1858-11-17');
%      mjd2 = datenum('2015-01-04') - datenum('1858-11-17');
%      freqmode = 2
%      info = get_logdata4freqmode(freqmode,mjd1:mjd2)
%
%      webapi_url = get_webapi_url(); %connect to test database
%      info = get_logdata4freqmode(freqmode,mjd1:mjd2,webapi_url)
% 
% Created by Bengt Rydberg 2015-12-17

function info = get_logdata4freqmode(freqmode,mjdvec,webapi_url)

if nargin<3
  webapi_url = 'http://malachite.rss.chalmers.se';
end


mjd0 = datenum('1858-11-17');

datevec = mjd0 + mjdvec;

urls = [];
n = 1;
for i = 1 : length(datevec)
  datei = datestr(datevec(i),'yyyy-mm-dd');
  url = [ webapi_url,'/rest_api/v4/freqmode_info/',datei];
  y = get_date_info(url);
  if isempty(y.Info)
    continue
  end
  freqmodes = [y.Info(:).FreqMode];
  ind = find(freqmodes==freqmode);
  if ~isempty(ind)
    urls{n} = y.Info(ind).URL;
    n = n + 1;
  end
end

if n==1
  info = [];
  return
end

n = 1;
for i = 1:length(urls)
  y = webread(urls{i}, weboptions('ContentType','json','Timeout',120));
  for j = 1 : length(y.Info)
     info(n) = y.Info(j);
     n = n + 1;
  end
end

