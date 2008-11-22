classdef VecDist < ProbDist
  % probability density function on vector-valued rv's (joint distributions)
  % The main methods that this supports which ProbDist does not are
  %   enterEvidence
  %   marginal
  % The sample method also uses this engine.
  % The child must define stateInfEng.
  % and must also support getModelParams.

  
  properties
    stateInfEng;
  end

  
  %%  Main methods
  methods
    function m = VecDist(varargin)
    end

    
    function [postQuery] = conditional(obj, visVars, visValues, queryVars)
      % p(XQ|Xvis=vis) doesn't change state of model
      obj = enterEvidence(obj, visVars, visValues);
      if nargin < 4, queryVars = mysetdiff(1:ndims(obj), visVars); end
      [postQuery] = marginal(obj, queryVars);
    end
         
    function obj = enterEvidence(obj, visVars, visValues)
      % change state to p(x|V=v) 
      %obj.stateInfEng = setParams(obj.stateInfEng, obj.mu, obj.Sigma);
      obj.stateInfEng = setParams(obj.stateInfEng, getModelParams(obj));
      obj.stateInfEng = enterEvidence(obj.stateInfEng, visVars, visValues);
    end
    
    function [X, obj] = sample(obj, n)
      % X(i,:) = sample for i=1:n
      if nargin < 2, n = 1; end
      obj.stateInfEng = setParams(obj.stateInfEng, getModelParams(obj));
      [X, obj.stateInfEng] = sample(obj.stateInfEng, n);
    end
      
    function [postQuery, obj] = marginal(obj, queryVars)
      % p(Q|V=v)  
      obj.stateInfEng = setParams(obj.stateInfEng, getModelParams(obj));
      [postQuery, obj.stateInfEng] = marginal(obj.stateInfEng, queryVars);
    end
    
    
%     function nll = negloglik(obj, X)
%       % Negative log likelihood of a data set
%       % nll = -sum_i log p(X(i,:) | params)
%        if(ndims(X) == 3)
%          nll = -sum(logprob(obj, X),1) / size(X,3);  % e.g. distribution over matrices like Wishart  
%        else
%          nll = -sum(logprob(obj, X),1) / size(X,1);  % everybody else
%        end
%     end
 
%     function [h,p] = plot(obj, varargin)
%       % plot a density function in 2d
%       % handle = plot(pdf, 'name1', val1, 'name2', val2, ...)
%       % Arguments are
%       % xrange  - [xmin xmax] for 1d or [xmin xmax ymin ymax] for 2d
%       % useLog - true to plot log density, default false
%       % plotArgs - args to pass to the plotting routine, default {}
%       % useContour - true to plot contour, false (default) to plot surface
%       % npoints - number of points in each grid dimension (default 50)
%       % eg. plot(p,  'useLog', true, 'plotArgs', {'ro-', 'linewidth',2})
%       if 0 % ndims(obj)==1
%         objScalar = convertToScalarDist(obj);
%         [h,p]  = plot(objScalar, varargin{:});
%         return;
%       end
%       [xrange, useLog, plotArgs, useContour, npoints, scaleFactor] = process_options(...
%         varargin, 'xrange', plotRange(obj), 'useLog', false, ...
%         'plotArgs' ,{}, 'useContour', true, 'npoints', 100, 'scaleFactor', 1);
%       if ~iscell(plotArgs), plotArgs = {plotArgs}; end
%       if ndims(obj)==1
%         xs = linspace(xrange(1), xrange(2), npoints);
%         p = logprob(obj, xs(:));
%         if ~useLog
%           p = exp(p);
%         end
%         p = p*scaleFactor;
%         h = plot(xs, p, plotArgs{:});
%       else 
%         [X1,X2] = meshgrid(linspace(xrange(1), xrange(2), npoints)',...
%           linspace(xrange(3), xrange(4), npoints)');
%         [nr] = size(X1,1); nc = size(X2,1);
%         X = [X1(:) X2(:)];
%         p = logprob(obj, X);
%         if ~useLog
%           p = exp(p);
%         end
%         p = reshape(p, nr, nc);
%         if useContour
%           [c,h] = contour(X1, X2, p, plotArgs{:});
%         else
%           h = surf(X1, X2, p, plotArgs{:});
%         end
%       end
%     end
   
     
     
     function Xc = impute(obj, X)
       % Fill in NaN entries of X using posterior mode on each row
       [n d] = size(X);
       Xc = X;
       for i=1:n
         hidNodes = find(isnan(X(i,:)));
         if isempty(hidNodes), continue, end;
         visNodes = find(~isnan(X(i,:)));
         visValues = X(i,visNodes);
         %postH = conditional(obj, visNodes, visValues); % now representsp(h|v)
         obj = enterEvidence(obj, visNodes, visValues); % now represents p(h|v)
         postH = marginal(obj, hidNodes);
         mu = mode(postH);
         Xc(i,hidNodes) = mu(:)';
       end
     end
       
     function demoImputation(model, varargin)
       % model is a child class of VecDist
      [d, seed, pcMissing] = process_options(varargin, 'd', 10, 'seed', 0, 'pcMissing', 0.3);
      setSeed(seed);
      model = mkRndParams(model, d);
      n = 5;
      Xfull = sample(model, n);
      %missing = rand(n,d) < pcMissing;
      missing = zeros(n,d);
      missing(:, 1:floor(pcMissing*d)) = 1;
      Xmiss = Xfull;
      Xmiss(find(missing)) = NaN;
      XmissImg = Xmiss;
      XmissImg(find(missing)) = 0;
      Ximpute = impute(model, Xmiss); % all the work happens here
      figure; nr = 1; nc = 3; 
      subplot(nr,nc,1); imagesc(Xfull); title('full data'); colorbar
      subplot(nr,nc,2); imagesc(XmissImg); title(sprintf('%3.2f pc missing', pcMissing)); colorbar
      %subplot(2,2,3); imagesc(missing); 
      subplot(nr,nc,3); imagesc(Ximpute); title('imputed data'); colorbar
      set(gcf,'position',[10 500 600 200])
      restoreSeed;
     end
  end
  
  
  methods
      
      function xrange = plotRange(obj, sf)
          if nargin < 2, sf = 3; end
          %if ndims(obj) ~= 2, error('can only plot in 2d'); end
          mu = mean(obj); C = cov(obj);
          s1 = sqrt(C(1,1));
          x1min = mu(1)-sf*s1;   x1max = mu(1)+sf*s1;
          if ndims(obj)==2
              s2 = sqrt(C(2,2));
              x2min = mu(2)-sf*s2; x2max = mu(2)+sf*s2;
              xrange = [x1min x1max x2min x2max];
          else
              xrange = [x1min x1max];
          end
      end
      
      
      
  end
  
 


end