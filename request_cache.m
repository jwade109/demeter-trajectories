function [success, file, cache] = request_cache(funcname, varargin)

h = hashargs(varargin);
fn = sprintf('%s_%s.mat', funcname, h);
fprintf("Results stored in %s\n", fn);
location = which(fn);

if ~isempty(location)
    fprintf("Loading from cached result: %s\n", location);
    success = true;
    file = load(location);
else
    success = false;
    file = 0;
end

path = what('cache');
path = path.path;
cache = sprintf("%s\\%s", path, fn);

end