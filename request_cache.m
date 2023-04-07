function [success, file, fn] = request_cache(funcname, varargin)

mkdir('.cache')
h = hashargs(varargin);
fn = sprintf('.cache/%s_%s.mat', funcname, h);
fprintf("Results stored in %s\n", fn);

if isfile(fn)
    fprintf("Loading from cached result: %s\n", fn);
    success = true;
    file = load(fn);
else
    success = false;
    file = 0;
end

end