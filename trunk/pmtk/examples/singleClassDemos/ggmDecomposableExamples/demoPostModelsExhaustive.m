function demoPostModelsExhaustive(varargin)
    % Examples
    % demoExhaustive('n',10,'d',5,'graphType','chain')
    % demoExhaustive('n',100,'d',4,'graphType','loop')
    % demoExhaustive('n',100,'d',4,'graphType','aline4')
    [doPrint, n, d, graphType] = process_options(...
        varargin, 'doPrint', false, 'n', 10, 'd', 4, 'graphType', 'chain');
    seeds = 1:3;
    for i=1:length(seeds)
        [loss(i,:), nll(i,:), names] =  helperPostModelsExhaustive('seed', seeds(i), ...
            'd', d, 'n', n, 'graphType', graphType);
    end
    figure(4);clf
    subplot(1,2,1); boxplot(loss, 'labels', names); title('KL loss')
    subplot(1,2,2); boxplot(nll, 'labels', names); title('nll')
    suptitle(sprintf('d=%d, n=%d, graph=%s, ntrials = %d', ...
        d, n, graphType, length(seeds)))
end

function [loss, nll, names] = helperPostModelsExhaustive(varargin)
    [seed, n, d, graphType] = process_options(...
        varargin, 'seed', 0, 'n', 10, 'd', 4, 'graphType', 'chain');
    Phi = 0.1*eye(d); delta = 5; % hyper-params
    setSeed(seed);
    Gtrue = undirectedGraph('type', graphType, 'nnodes', d);
    truth = ggm(Gtrue, [], []);
    Atrue = Gtrue.adjMat;
    truth = mkRndParams(truth);
    Y = sample(truth, n);

    prec{1} = inv(truth.Sigma); names{1} = 'truth';
    prec{2} = inv(cov(Y)); names{2} = 'emp';
    obj = ggmDecomposable([], hiwDist([], delta, Phi), []);
    [logpostG, GGMs, mapG, mapPrec, postG, postMeanPrec, postMeanG] = ...
        computePostAllModelsExhaustive(obj, Y);
    prec{3} = postMeanPrec; names{3} = 'mean';
    prec{4} = mapPrec; names{4} = 'mode';

    % predictive accuracy
    nTest = 1000;
    Ytest = sample(truth, nTest);
    for i=1:4
        SigmaHat = inv(prec{i});
        model = mvnDist(mean(Y), SigmaHat);
        nll(i) = negloglik(model, Ytest);
    end

    figure(1);clf;
    bar(postG);
    trueNdx = [];
    for i=1:length(GGMs)
        if isequal(GGMs{i}.G.adjMat, Atrue)
            trueNdx = i; break;
        end
    end
    if isempty(trueNdx)
        title(sprintf('p(G|D), truth=non decomposable'));
    else
        title(sprintf('p(G|D), truth=%d', trueNdx));
    end

    figure(2);clf;
    for i=1:4
        SigmaHat = inv(prec{i});
        M = SigmaHat * inv(truth.Sigma);
        loss(i) = trace(M) - log(det(M)) - d; % KL loss
        subplot(2,2,i);
        %imagesc(prec{i}); colormap('gray');
        hintonDiagram(prec{i});
        title(sprintf('%s, KLloss = %3.2f, nll =%3.2f', names{i}, loss(i), nll(i)));
        hold on
    end

    [pmax, Gmax] = max(postG);
    Gmap = GGMs{Gmax}.G;
    Amap = Gmap.adjMat;
    %draw(Gmap); title('Gmap')
    hamming = sum(abs(Amap(:) - Atrue(:)));
    figure(3);clf
    subplot(2,2,1); hintonDiagram(Atrue); title('true G')
    subplot(2,2,2); hintonDiagram(Amap); title(sprintf('G map, hamdist=%d', hamming))
    subplot(2,2,3); hintonDiagram(postMeanG); title('post mean G');

    restoreSeed;
end