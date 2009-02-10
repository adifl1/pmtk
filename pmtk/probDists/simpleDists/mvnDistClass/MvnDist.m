classdef MvnDist < ParamJointDist 
% multivariate normal p(X|mu,Sigma) 

  properties
    mu; Sigma;
    prior;
  end
 
  %% main methods
  methods
      
      
      
    function m = MvnDist(mu, Sigma,  varargin)
      if nargin == 0
        mu = []; Sigma = [];
      end
      [m.infEng, m.domain, m.prior] = process_options(varargin, ...
        'infEng', GaussInfEng(), 'domain', 1:numel(mu), 'prior', 'none');
      m.mu = mu; m.Sigma = Sigma;
    end

    function [mu,Sigma,domain] = convertToMvnDist(m)
      mu = m.mu; Sigma = m.Sigma; domain = m.domain; 
    end
    
    function L = logprobUnnormalized(model, X)
      % L(i) = log p(X(i,:) | params) + log Z, columns are the hidden
      % variables
      mu = model.mu; Sigma = model.Sigma;
      X = insertVisData(model,X);
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
    
    function fc = makeFullConditionals(obj, visVars, visVals)
      d = length(obj.mu);
      if nargin < 2
        % Sample from the unconditional distribution
        visVars = []; visVals = [];
      end
      V = visVars; H = mysetdiff(1:d, V);
      x = zeros(1,d); x(V) = visVals;
      fc = cell(length(H),1);
      for i=1:length(H)
        fc{i} = @(xh) fullCond(obj, xh, i, H, x);
      end
    end

    function p = fullCond(obj, xh, i, H, x)
      assert(length(xh)==length(H))
      x(H) = xh; % insert sampled hidden values into hidden slot
      x(i) = []; % remove value for i'th node, which will be sampled
      d = length(obj.mu);
      dom = 1:d; dom(i) = []; % specify that all nodes are observed except i
      [muAgivenB, SigmaAgivenB] = gaussianConditioning(obj.mu, obj.Sigma, dom, x);
      %xi = normrnd(muAgivenB, sqrt(SigmaAgivenB));
      p = GaussDist(muAgivenB, SigmaAgivenB);
    end
    
     function xinit = mcmcInitSample(model, visVars, visVals) 
       if nargin < 2
         xinit = mvnrnd(model.mu, model.Sigma);
         return;
       end
       % Ideally we would draw an initial sample conditional on the
       % observed data.
       % Instead we sample the hidden nodes from their prior
       domain = model.domain;
       hidVars = mysetdiff(domain, visVars);
       V = lookupIndices(visVars, domain);
       H = lookupIndices(hidVars, domain);
       xinit = mvnrnd(model.mu(H), model.Sigma(H,H)); 
     end
    
    function obj = mkRndParams(obj, d)
      if nargin < 2, d = ndimensions(obj); end
      if(~isscalar(d) || d~=round(d))
          perm = randperm(size(d,1));
          obj.mu = d(perm(1),:);
          obj.Sigma = 0.05*cov(d);
          obj.domain = 1:size(d,2);
      else
          obj.mu = randn(d,1);
          obj.Sigma = randpd(d);
          obj.domain = 1:d;
      end
    end
    
    function d = ndimensions(m)
         d= length(m.mu); % m.ndims;
    end


     function obj = fit(obj,varargin)
       % Fit the distribution via the specified method
       %
       % FORMAT:
       %
       %  obj = fit(obj,'name1',val1,'name2',val2,...);
       %
       % INPUT:
       %
       % 'data'     -        data(i,:) is case i
       % 'suffStat' -        the sufficient statistics of the data made via
       %                     SS = mkSuffStat(MvnDist(),data). If not specified, this
       %                     is automatically calculated.
       %
       % 'prior'    -        This can be a string chosen from
       %       {'none', 'covshrink'}
       %      or an MvnInvWishartDist object.
       %  If prior = none, we compute the MLE, otherwise a MAP estimate.
       %
       % 'covtype'  -        Restrictions on the covariance: 'full' | 'diag' |
       %                     'isotropic'

       [X,SS,prior,covtype] = process_options(varargin,...
         'data'              ,[]         ,...
         'suffStat'          ,[]         ,...
         'prior'             ,obj.prior         ,...
         'covtype'           ,'full');
       
       if(~strcmpi(covtype,'full')),error('Restricted covtypes not yet implemented');end
       if isempty(SS), SS = MvnDist.mkSuffStat(X); end
       switch class(prior)
         case 'char'
           switch prior
             case 'none'
               obj.mu = SS.xbar;
               obj.Sigma = SS.XX;
             case 'covshrink',
               obj.mu =  mean(X);
               obj.Sigma =  covshrink(X);
             otherwise
               error(['unknown prior ' prior])
           end
         case 'MvnInvWishartDist'  % MAP estimation
           m = Mvn_MvnInvWishartDist(prior);
           m = fit(m, 'suffStat',SS);
           post = m.muSigmaDist; % paramDist(m); % NIW
           m = mode(post);
           obj.mu = m.mu;
           obj.Sigma = m.Sigma;
           otherwise
           error('unknown prior ')
       end
     end


     function [postmu, logevidence] = softCondition(pmu, py, A, y)
         % Bayes rule for MVNs
         Syinv = inv(py.Sigma);
         Smuinv = inv(pmu.Sigma);
         postSigma = inv(Smuinv + A'*Syinv*A);
         postmu = postSigma*(A'*Syinv*(y-py.mu) + Smuinv*pmu.mu);
         postmu = MvnDist(postmu, postSigma);
         %evidence = mvnpdf(y(:)', (A*pmu.mu + py.mu)', py.Sigma + A*pmu.Sigma*A');
         logevidence = logprob(MvnDist(A*pmu.mu + py.mu, py.Sigma + A*pmu.Sigma*A'), y(:)');
     end
    
    
     function xrange = plotRange(obj, sf)
         if nargin < 2, sf = 3; end
         %if ndimensions(obj) ~= 2, error('can only plot in 2d'); end
         mu = mean(obj); C = cov(obj);
         s1 = sqrt(C(1,1));
         x1min = mu(1)-sf*s1;   x1max = mu(1)+sf*s1;
         switch length(mu) % ndimensions(obj)
             case 1,  xrange = [x1min x1max];
             case 2,
                 s2 = sqrt(C(2,2));
                 x2min = mu(2)-sf*s2; x2max = mu(2)+sf*s2;
                 xrange = [x1min x1max x2min x2max];
             otherwise
                 error('can only plot 1 or 2d');
         end
     end
    
    
  end % methods

 

  methods(Static = true)
      function suffStat = mkSuffStat(X,weights)
          % SS.n
          % SS.xbar = 1/n sum_i X(i,:)'
          % SS.XX(j,k) = 1/n sum_i XC(i,j) XC(i,k)
          if(nargin > 1) % weighted sufficient statistics, e.g. for EM
              suffStat.n = sum(weights,1);
              suffStat.xbar = sum(bsxfun(@times,X,weights))'/suffStat.n;  % bishop eq 13.20
              X = bsxfun(@minus,X,suffStat.xbar');
              suffStat.XX = bsxfun(@times,X,weights)'*X/suffStat.n;
              if(0) % sanity check
                  XXtest = zeros(size(X,2));
                  for i=1:size(X,1)
                      XXtest = XXtest + weights(i)*(X(i,:)'*X(i,:));       % bishop eq 13.21
                  end
                  XXtest = XXtest/suffStat.n;
                  assert(approxeq(XXtest,suffStat.XX));
              end
          else
              n = size(X,1);
              suffStat.n = n;
              suffStat.xbar = sum(X,1)'/n; % column vector
              X = bsxfun(@minus,X,suffStat.xbar');
              suffStat.XX = (X'*X)/n;
          end
      end

  end
  
  
end