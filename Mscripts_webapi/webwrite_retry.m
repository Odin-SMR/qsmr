
% Writes a MATLAB struct to a JSON file on disk
%
% Usage:
%      webwrite_retry(filename, data)
%
% In:
%     filename  the path to the JSON file to write
%     data      struct to encode and write
%
% Example Usage:
%      webwrite_retry('output.json', data)
%
% Replaces previous webwrite-based retry logic for local file-based workflow

function webwrite_retry(filename, data)
    try
        jsonText = jsonencode(data);
        % Import the Python module explicitly and call save_parquet
        dataset_mod = py.importlib.import_module('qsmr_system.dataset');
        dataset_mod.save_parquet(jsonText, filename);
    catch errmsg
        disp(['Failed to call dataset.save_parquet for file: ', filename]);
        disp(errmsg.message);
    end
end
