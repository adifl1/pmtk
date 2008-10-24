classdef ggm < gm
  % gaussian graphical model 
  
  properties
    mu;
    Sigma;
  end

  %%  Main methods
  methods
    function obj = ggm(G, mu, Sigma)
      % ggm(G, mu, Sigma) where G is of type graph
      % mu and Sigma can be [] and set later.
      if nargin < 1, G = []; end
      if nargin < 2, mu = []; end
      if nargin < 3, Sigma = []; end
      obj.G = G; obj.mu = mu; obj.Sigma = Sigma;
      obj.stateInfEng = mvnExactInfer; % ignores graph structure
    end

    function params = getModelParams(obj)
      params = {obj.mu, obj.Sigma, obj.G};
    end

    function obj = mkRndParams(obj)
      % Set Sigma to a random pd matrix such that SigmaInv is consistent
      % with G
      d = ndims(obj);
      obj.mu = randn(d,1);
      A = obj.G.adjMat;
      prec = randpd(d) .* A;
      prec = mkDiagDominant(prec);
      obj.Sigma = inv(prec);
    end

    function L = logprob(obj, X)
      % L(i) = log p(X(i,:) | params)
      L = logprob(mvnDist(obj.mu, obj.Sigma), X);
    end

    function B = bicScore(obj, X)
      % B = log p(X|model) - (dof/2)*log(N);
      N = size(X,1);
      dof = nedges(obj.G);
      L = logprob(mvnDist(obj.mu, obj.Sigma), X);
      B = sum(L) - (dof/2)*log(N);
    end

    function obj = fit(obj, varargin)
      % Point estimate of parameters given graph
      % m = fit(model, 'name1', val1, 'name2', val2, ...)
      % Arguments are
      % data - data(i,:) = case i
      [X, SS] = process_options(...
        varargin, 'data', [], 'suffStat', []);
      obj.mu = mean(X);
      [precMat, covMat] = gaussIPF(X, obj.G.adjMat);
      obj.Sigma = covMat;
    end

    function obj = fitStructure(obj, varargin)
      [method, lambda, X] = process_options(...
        varargin, 'method', 'L1BCD', 'lambda', 1e-3, 'data', []);
      switch method
        case 'L1BCD', [precMat, covMat] = L1precisionBCD(X, 'regularizer', lambda);
          obj.mu = mean(X);
          obj.Sigma = covMat;
          obj.G = undirectedGraph(precmatToAdjmat(precMat));
        otherwise
          error(['unknown method ' method])
      end
    end

    function X = sample(obj, n)
      % X(i,:) = i'th case
      X = sample(mvnDist(obj.mu, obj.Sigma), n);
    end


    function d = nnodes(obj)
      % num dimensions (variables)
      d = nnodes(obj.G);
    end

  end

  %% Demos
  methods(Static = true)
    function demo()
      d = 10;
      G = undirectedGraph('type', 'loop', 'nnodes', d);
      obj = ggm(G, [], []);
      obj = mkRndParams(obj);
      n = 1000;
      X = sample(obj, n);
      S = cov(X);
      L = inv(S);
      figure;
      subplot(1,2,1); imagesc(G.adjMat); colormap('gray'); title('truth')
      subplot(1,2,2); imagesc(L); colormap('gray'); title('empirical prec mat')
    end
    
    function demoBIC()
      setSeed(0);
      d = 4;
      G = undirectedGraph('type', 'loop', 'nnodes', d);
      obj = ggm(G, [], []);
      obj = mkRndParams(obj);
      n = 100;
      X = sample(obj, n);
      modelL1 = fitStructure(ggm, 'data', X, 'lambda', 1e-3);
      adjL1 = modelL1.G.adjMat;
      Gs = mkAllUG(undirectedGraph(), d);
      for i=1:length(Gs)
        if isequal(Gs{i}, G), truendx = i; end
        if isequal(Gs{i}, modelL1.G), L1ndx = i; end
        models{i} = fit(ggm(Gs{i}), 'data', X);
        BIC(i) = bicScore(models{i}, X);
      end
      logZ = logsumexp(BIC(:));
      postG = exp(BIC - logZ);
      
      figure;
      h=bar(postG);
      title(sprintf('p(G|D), true model is red, L1 is green'))
      Nmodels = length(BIC);
      set(gca,'xtick',0:5:Nmodels)
      % Find all models with 10% of maximum (could truncate this)
      [pbest, ndxbest] = max(postG);
      ndxWindow = find(postG >= 0.1*pbest);
      line([0 64],[0.1*pbest 0.1*pbest]);
      colorbars(h,truendx,'r');
      colorbars(h,L1ndx,'g');
      %colorbars(h,ndxWindow,'g');
      
      % Compute test set log likelihood for different mehtods
      Xtest = sample(obj, 1000);
      loglikBest = sum(logprob(models{ndxbest}, Xtest));
      loglikL1 = sum(logprob(modelL1, Xtest));
      loglikBMA = 0;
      for i=ndxWindow(:)'
        loglikBMA = loglikBMA + sum(logprob(models{i}, Xtest))*postG(i);
      end
      fprintf('NLL best %5.3f, L1 %5.3f, BMA over %d = %5.3f\n', ...
        -loglikBest, -loglikL1, length(ndxWindow), -loglikBMA);
    end

    function demoInfer()
      d = 10;
      G = undirectedGraph('type', 'loop', 'nnodes', d);
      obj = ggm(G, [], []);
      obj = mkRndParams(obj);
      V = 1:2; H = mysetdiff(1:d, V); xv = randn(2,1);
      obj = enterEvidence(obj, V, xv);
      pobj = marginal(obj, H);
      obj2 = mvnDist(obj.mu, obj.Sigma);
      obj2 = enterEvidence(obj2, V, xv);
      pobj2 = marginal(obj2, H);
      assert(approxeq(mean(pobj), mean(pobj2)))
      assert(approxeq(cov(pobj), cov(pobj2)))
    end
  end

end