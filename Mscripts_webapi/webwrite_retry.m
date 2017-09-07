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
%     max_retries  the number of tries before failure
%
% Example Usage:
%
%      response = webwrite_retry(target_url, data, ...
%          weboptions('ContentType', 'json', 'Timeout', 60), 5)
%
% Created by Joakim Möller 2017-06-27
% Bugfix and better error reporting by Joakim Möller 2017-09-07


function web_request = webwrite_retry(source_url, data, webwrite_options, ...
        max_retries)
    min_pause = 3;
    max_pause = 60;
    wait_seconds = min_pause + rand(1, max_retries) * (max_pause - min_pause);
    for secs = wait_seconds
        try
            web_request = webwrite(source_url, data, webwrite_options);
            return
        catch errmsg
            disp(errmsg.message);
            disp(sprintf('Retrying %s in %0.0fs', source_url, secs));
            pause(secs);
        end
    end
    disp(sprintf('Failed to send data to %s', source_url));
    exit(1);
end
