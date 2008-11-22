classdef ProbDist
% This class represents an abstract proability distribution, e.g. a pdf or pmf.
% All PMTK probability distributions inherit directly or indirectly from ProbDist.
    
    methods(Abstract = true)
    % These are methods that every probability distribution must implement.
    % Where possible, sublcasses should also implement the following:
    % mean()
    % mode()
    % var()
    % sample()
        logprob();
        ndims();
    end
    
    %%  Main methods
    methods
    % Methods available to all subclasses include:    
    % marginal()
    % negloglik()
    % cvScore()
    % plot()
        function marginal(obj,varargin)
            error('not yet implemented'); 
        end
        
        function fit(obj,varargin)
           error('not yet implemented'); 
        end
        
        function predict(obj,varargin)
           error('not yet implemented'); 
        end
    
    
        function nll = negloglik(obj,X)
            % The negative log likelihood of a data set
            % nll = -(1/n)sum_i(log p(X_i | params))
            % where X_i is the ith case, (e.g. X(i) or X(i,:) or X(:,:,i)) and n is
            % the number of cases.
            nll = -mean(logprob(obj, X),1);
        end
        
        function [mu, stdErr] = cvScore(obj, X, varargin)
            %CV Score using nll loss of the model.
            [nfolds] = process_options(varargin, 'nfolds', 5);
            [n d] = size(X);
            [trainfolds, testfolds] = Kfold(n, nfolds);
            score = zeros(1,n);
            for k = 1:nfolds
                trainidx = trainfolds{k}; testidx = testfolds{k};
                Xtest = X(testidx,:);  Xtrain = X(trainidx, :);
                obj = fit(obj, 'data', Xtrain);
                score(testidx) = logprob(obj,  Xtest);
                %fprintf('fold %d, logprob %5.3f, mu %5.3f, sigma %5.3f\n', k, L(k), obj.mu, obj.sigma2);
            end
            mu = mean(score);
            stdErr = std(score,0,2)/sqrt(n);
        end
        
    end
    
    
    methods
        %% Plotting Methods
        function [h,p] = plot(obj, varargin)
        % plot a density function in 2d
        % handle = plot(pdf, 'name1', val1, 'name2', val2, ...)
        % Arguments are
        % xrange  - [xmin xmax] for 1d or [xmin xmax ymin ymax] for 2d
        % useLog - true to plot log density, default false
        % plotArgs - args to pass to the plotting routine, default {}
        % useContour - true to plot contour, false (default) to plot surface
        % npoints - number of points in each grid dimension (default 50)
        % eg. plot(p,  'useLog', true, 'plotArgs', {'ro-', 'linewidth',2})
            [xrange, useLog, plotArgs, useContour, npoints, scaleFactor] = process_options(...
                varargin, 'xrange', plotRange(obj), 'useLog', false, ...
                'plotArgs' ,{}, 'useContour', true, 'npoints', 100, 'scaleFactor', 1);
            if ~iscell(plotArgs), plotArgs = {plotArgs}; end
            if ndims(obj)==1
                xs = linspace(xrange(1), xrange(2), npoints);
                p = logprob(obj, xs);
                if ~useLog
                    p = exp(p);
                end
                p = p*scaleFactor;
                h = plot(xs, p, plotArgs{:});
            else
                [X1,X2] = meshgrid(linspace(xrange(1), xrange(2), npoints)',...
                    linspace(xrange(3), xrange(4), npoints)');
                [nr] = size(X1,1); nc = size(X2,1);
                X = [X1(:) X2(:)];
                p = logprob(obj, X);
                if ~useLog
                    p = exp(p);
                end
                p = reshape(p, nr, nc);
                if useContour
                    [c,h] = contour(X1, X2, p, plotArgs{:});
                else
                    h = surf(X1, X2, p, plotArgs{:});
                end
            end
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