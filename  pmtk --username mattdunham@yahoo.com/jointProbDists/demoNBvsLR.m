load soy;

T = chainTransformer({standardizeTransformer(false),addOnesTransformer});
LR = logregDist('nclasses', 3, 'transformer', T);

LRfit = @(Xtrain,ytrain,lambda)...
  fit(LR, 'X', Xtrain, 'y', ytrain, 'lambda',lambda,'prior','l2', 'method', 'lbfgs');

LRtest = @(Xtrain,ytrain,Xtest,lambda)...
  mode(predict(LRfit(Xtrain,ytrain,lambda),Xtest));

lambda = 0.336; % cv picks lambda = 0.336 on soy data set
if(~exist('lambda','var')) 
     modelSelector = crossValidation             ...
         ('testFunction'   ,LRtest              ,...
          'values'         ,logspace(-3,1,20)   ,...
          'Xdata'          ,X                   ,...
          'Ydata'          ,Y                   ,...
          'errorCriteria'  ,'MISCLASS');
    [modelSelector,lambda] = modelSelector.run(); 
end
LRtest = @(Xtrain,ytrain,Xtest)LRtest(Xtrain,ytrain,Xtest,lambda);

NB = naiveBayesBernoulliDist('nclasses',3);
NBfit = @(Xtrain,ytrain)...
  fit(NB,'X', Xtrain, 'Y', ytrain,...
         'classPrior'    , dirichletDist(2*ones(1,3)),...
         'featurePrior'  , betaDist(2,2));

NBtest = @(Xtrain,ytrain,Xtest)mode(predict(NBfit(Xtrain,ytrain),'X',Xtest));

rand('twister',0);
train = randperm(floor(0.8*size(X,1)));
test  = setdiff(1:size(X,1),train);

modelComparison = compareN('testFunction' ,{LRtest,NBtest},...
                           'names'        ,  {'LR','NB'},...
                           'Xtrain'       ,  X(train,:),...
                           'Ytrain'       ,  Y(train,:),...
                           'Xtest'        ,  X(test,:) ,...
                           'Ytest'        ,  Y(test,:) ,...
                           'evalPoints'   ,  1:20:numel(train),...
                           'errorCriteria', 'MISCLASS',...
                           'randomize'    , 'false',...
                           'verbose'      ,  true);

modelComparison = modelComparison.run();                       




