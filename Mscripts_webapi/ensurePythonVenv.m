function ensurePythonVenv()
    pe = pyenv;
    if pe.Status == "Loaded"
        return;
    end

    [status, pyExe] = system("which python");
    if status ~= 0
        error("Python not found in PATH");
    end

    pyExe = strtrim(pyExe);

    if ~isfile(pyExe)
        error("Resolved python executable does not exist: %s", pyExe);
    end

    pyenv( ...
        "Version", pyExe, ...
        "ExecutionMode", "OutOfProcess" ...
    );
end
