classdef GaussInfEng < InfEng
% Exact inference in multivariate Gaussians
% Model must support the following method
% [mu,Sigma,domain] = convertToMvnDist(model);
 
properties
  mu; Sigma; domain;
end

  %% main methods
  methods
    function eng = GaussInfEng()
      eng.mu = []; eng.Sigma = []; eng.domain = [];
    end
     
     function eng = condition(eng, model, visVars, visValues)
       [mu, Sigma, domain] = convertToMvnDist(model);
       V = lookupIndices(visVars, domain);
       hidVars = mysetdiff(domain, visVars);
       [muHgivenV, SigmaHgivenV] = gaussianConditioning(...
         mu, Sigma, V, visValues);
       eng.mu = muHgivenV; eng.Sigma = SigmaHgivenV; eng.domain = hidVars;
     end
    
    function postQuery = marginal(eng, queryVars)
       mu = eng.mu; Sigma = eng.Sigma; domain = eng.domain;
       Q = lookupIndices(queryVars, domain);
       postQuery = MvnDist(mu(Q), Sigma(Q,Q), 'domain', queryVars); %#ok
    end
  
    function samples = sample(eng, n)
      % Samples(i,:) is i'th sample of the *hidden* nodes 
      if(nargin < 2), n = 1; end;
      mu = eng.mu; Sigma = eng.Sigma; 
      A = chol(Sigma,'lower'); % could be cached
      Z = randn(length(mu),n);
      samples = bsxfun(@plus,mu(:), A*Z)'; %#ok
    end
    
    function L = logprobUnnormalized(eng, X)
      % L(i) = log p(X(i,:) | params)
      %if nargin < 3, normalize = true; end
      mu = eng.mu; Sigma = eng.Sigma;
      if numel(mu)==1
        X = X(:); % ensure column vector
      end
      [N d] = size(X);
      if length(mu) ~= d
        error('X should be N x d')
        % if some components have been observed, X needs to be expanded...
      end
      X = bsxfun(@minus,X,rowvec(mu));
      L =-0.5*sum((X*inv(Sigma)).*X,2);
      %if normalize
      %    L = L - lognormconst(eng);
      %end
    end

    function logZ = lognormconst(eng)
      mu = eng.mu; Sigma = eng.Sigma;
      d = length(mu);
      logZ = (d/2)*log(2*pi) + 0.5*logdet(Sigma); % could be pre-computed
    end
    
     function mu = mean(eng)
       mu = eng.mu;
    end

    function mu = mode(eng)
      mu = eng.mu;
    end

    function C = cov(eng)
      C = eng.Sigma;
    end
    
    function C = var(eng)
      C = diag(eng.Sigma);
    end


    
  end % methods

end