function [v1d, v1a, v2d, v2a] = intercept2(r1, r2, tof, mu)

f = @ (z) seconds(tof) - real(ztof(z, r1, r2, mu, 1));
g = @ (z) seconds(tof) - real(ztof(z, r1, r2, mu, -1));

[z1, ~, ~] = fzero(f, 1);
[z2, ~, ~] = fzero(g, -1);

[~, v1d, v1a] = ztof(z1, r1, r2, mu, 1);
[~, v2d, v2a] = ztof(z2, r1, r2, mu, -1);

end
