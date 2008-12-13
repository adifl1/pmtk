%% Plotting Binomial Distributions
thetas = [1/2 1/4 3/4 0.9];
N = 10;
figure;
for i=1:4
    subplot(2,2,i)
    b = BinomDist(N,thetas(i));
    plot(b);
    title(sprintf('theta=%5.3f', thetas(i)))
end
