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
%     max_retries  the number of retries before failure
%
% Example Usage:
%
%      data = webread_retry(source_url, weboptions('ContentType', 'json', ...
%                                     'Timeout', 60), 5)
%
% Created by Joakim Möller 2017-06-19

function web_request = webread_retry(source_url, webread_options, max_retries)
    min_pause = 3;
    max_pause = 60;
    wait_seconds = min_pause + rand(1, max_retries) * (max_pause - min_pause);
    for idx = numel(wait_seconds)
        try
            web_request = webread(source_url, webread_options);
            return
        catch
            pause(wait_seconds(idx));
        end
    end
    disp(sprintf('Failed to get data from %s', source_url))
    exit(1);
end
