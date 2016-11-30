% returns a vector with freqmodes that were
% observed for given dates
% 
% Usage:
%      y = get_measuredfreqmodes4daterange(mjd,webapi_url)
% 
% Out:  
%      y  cell array of structs
%         the struct has fields 
%         mjd (scalar)
%         freqmodes (vector)
%        
% In:    
%     mjd vector of mjd 
%     webapi_url optional default is to search data from the odin
%     live database
%   
% Example Usage:
%
%      mjd1 = datenum('2015-01-03') - datenum('1858-11-17');
%      mjd2 = datenum('2015-01-04') - datenum('1858-11-17');
%      freqmodes = get_measuredfreqmodes4daterange(mjd1:mjd2)
%
%      webapi_url = get_webapi_url(); %connect to test database
%      freqmodes = get_measuredfreqmodes4daterange(mjd1:mjd2,webapi_url)
% 
% Created by Bengt Rydberg 2015-12-17


function freqmodes = get_measuredfreqmodes4daterange(mjd,webapi_url)

if nargin<2
  webapi_url = 'http://malachite.rss.chalmers.se';
end

mjd0 = datenum('1858-11-17');

datevec = mjd0 + mjd;

freqmodes = {};
n = 1;
for i = 1 : length(datevec)
  datei = datestr(datevec(i),'yyyy-mm-dd');
  url = [ webapi_url,'/rest_api/v4/freqmode_info/',datei];
  y = get_date_info(url);
  if ~isempty(y.Info)
    Y.mjd = mjd(i);
    Y.freqmodes = [y.Info(:).FreqMode];
    freqmodes{i} = Y;
    n = n + 1;
  end 
end

