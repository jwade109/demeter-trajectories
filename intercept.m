function v1 = intercept(r1, r2, dt, mu)

%% Constants
dnu = acos(dot(r1, r2)/(norm(r1)*norm(r2)));
k = norm(r1)*norm(r2)*(1 - cos(dnu));
l = norm(r1) + norm(r2);
m = norm(r1)*norm(r2)*(1 + cos(dnu));

%% functions
a = @(p) m.*k.*p./((2.*m - l^2).*p.^2 + 2.*k.*l.*p - k.^2);
f = @(p) 1 - norm(r2)./p.*(1 - cos(dnu));
g = @(p) norm(r1).*norm(r2).*sin(dnu)./sqrt(mu*p);
% assuming a(p) > 0
dE = @(p) acos(1 - norm(r1)./a(p).*(1 - f(p)));
t = @(p) g(p) + sqrt(a(p).^3./mu).*(dE(p) - sin(dE(p)));

%% loop initialization
p_i = k/(l + sqrt(2*m));
p_ii = k/(l - sqrt(2*m));
P = [(2*p_i + p_ii)/3, (p_i + 2*p_ii)/3];
T = t(P);
epsilon = 1e-8;
iter = 0;
maxiter = 1000;
err = Inf;

%% fruit loops
while err > epsilon && iter < maxiter
    iter = iter + 1;
    P0 = P(iter);
    T0 = t(P0);
    P1 = P(iter+1);
    T1 = t(P1);
    if T1 == T0
        break
    end
    nP = P1 + (dt - T1)*(P1 - P0)/(T1 - T0);
    P = [P nP];
    T = [T t(nP)];
    err = abs(T(end) - dt);
end

%% lagrange coefficients
p = P(end);
f = 1 - norm(r2)/p*(1 - cos(dnu));
g = norm(r1)*norm(r2)*sin(dnu)/sqrt(mu*p);

%% velocities
v1 = (r2 - f*r1)/g;

end