
% prior
mu_0 = 0;
sigma2_0 = 10;
%sigma2_0 = 1;

% lik - suff stat
mu_ML = 3;
N = 1;
sigma2 = 1;

% post
%sigma2_N = 1/(N/sigma2 + 1/sigma2_0)
sigma2_N = (sigma2 * sigma2_0) / (N*sigma2_0 + sigma2)
mu_N = sigma2_N*(N*mu_ML/sigma2 + mu_0/sigma2_0);

figure(1); clf
xs = -5:0.01:5;
prior = normpdf(xs, mu_0, sqrt(sigma2_0));
lik = normpdf(xs, mu_ML, sigma2);
post = normpdf(xs, mu_N, sqrt(sigma2_N));
plot(xs, prior, 'r-', 'linewidth', 1);
hold on
plot(xs, lik, 'g:o', 'linewidth', 1);
plot(xs, post, 'b-.', 'linewidth', 1);
legend('prior','lik','post')


