% Tries webwrite a number of times with a random pause
%
% Usage:
%      y = webwrite_retry(url, data, webwrite_options, max_retries)
%
% Out:
%      y  data from a request
%
% In:
%     url  the url to read
%     data  data-payload same format as webwrite
%     webwrite_options  same options set to webwrite
%     max_retries  the number of retries before failure
%
% Example Usage:
%
%      response = webwrite_retry(target_url, data, ...
%          weboptions('ContentType', 'json', 'Timeout', 60), 5)
%
% Created by Joakim Möller 2017-06-27

function web_request = webwrite_retry(source_url, data, webwrite_options, ...
        max_retries)
    min_pause = 3;
    max_pause = 60;
    wait_seconds = min_pause + rand(1, max_retries) * (max_pause - min_pause);
    for idx = numel(wait_seconds)
        try
            web_request = webwrite(source_url, data, webwrite_options);
            return
        catch
            pause(wait_seconds(idx));
        end
    end
    disp(sprintf('Failed to send data to %s', source_url))
    exit(1);
end
