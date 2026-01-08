% Tries webread a number of times with a random pause
%
% Usage:
%      y = webread_retry(url, webread_options, max_retries)
%
% Out:
%      y  data from a request
%
% In:
%     url  the url to read
%     webread_options  same options set to webread_options
%     max_retries  the number of tries before failure
%
% Example Usage:
%
%      data = webread_retry(source_url, weboptions('ContentType', 'json', ...
%                                     'Timeout', 60), 5)
%
% Created by Joakim Möller 2017-06-19
% Bugfix and better error reporting by Joakim Möller 2017-09-07

function web_request = webread_retry(source_url, webread_options, max_retries)
    request = py.qsmr_system.get_url.get_json_with_retry(source_url);
    web_request = jsondecode(string(request));
end
