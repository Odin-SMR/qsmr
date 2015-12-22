% returns a vector with freqmodes that were
% observed for a given date range
% 
% Usage:
%      y = get_measuredfreqmodes4daterange(mjd1,mjd2,webapi_url)
% 
% Out:  
%      y  vector with freqmodes
% In:    
%     mjd1  start date 
%     mjd2  end data
%     webapi_url optional default is to search data from the odin
%     live database
%   
% Example Usage:
%
%      mjd1 = datenum('2015-01-03') - datenum('1858-11-17');
%      mjd2 = datenum('2015-01-04') - datenum('1858-11-17');
%      freqmodes = get_measuredfreqmodes4daterange(mjd1,mjd2)
%
%      webapi_url = get_webapi_url(); %connect to test database
%      freqmodes = get_measuredfreqmodes4daterange(mjd1,mjd2,webapi_url)
% 
%      see also odin_webapi_demo.m for usage
%
% Created by Bengt Rydberg 2015-12-17


function freqmodes = get_measuredfreqmodes4daterange(mjd1,mjd2,webapi_url)

if nargin<3
  webapi_url = 'http://malachite.rss.chalmers.se';
end

mjd0 = datenum('1858-11-17');
datenum1 = mjd0 + mjd1;
datenum2 = mjd0 + mjd2;

datevec = datenum1:datenum2;


freqmodes = [];

for i = 1 : length(datevec)
  datei = datestr(datevec(i),'yyyy-mm-dd');
  url = [ webapi_url,'/rest_api/v4/freqmode_info/',datei];
  y = get_date_info(url);
  if ~isempty(y.Info)
    freqmodes = [freqmodes, [y.Info(:).FreqMode]];
  end
end

freqmodes = unique(freqmodes);
