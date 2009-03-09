%% Test PMTK

try
%% 
bernoulliDistTest;                     cls;
bernoulli_betaSequentialUpdate;        cls;
binomialPlotDemo;                      cls;
binomial_betaPosteriorDemo;            cls;
binom_betaPostPredDemo;                cls;
cancerRatesEb;                         cls;
chainTransformerTest;                  cls;
chordalGraphDemo;                      cls;
compareJtreeToVarElim;                 cls;
compareToEnum;                         cls;
constDistTest;                         cls;
cooperYooInterventionDemo;             cls;
demoDataTable;                         cls;
demoNumericalIntNIG;                   cls;
dirichletHistPlotDemo;                 cls;
discreteDistTest;                      cls;
enumSprinkler;                         cls;
gammaPlotDemo;                         cls;
gammaRainfallDemo;                     cls;
gaussDGMdemo;                          cls;
gaussInferMuSigmaDemo;                 cls;
gaussMixPlot;                          cls;
gauss_NormInvGammDistTest;             cls;
generativeClassifierTest1;             cls;
generativeClassifierTest2;             cls;
ggmBICdemo;                            cls;
ggmDemo;                               cls;
ggmInferDemo;                          cls;
gibbsSprinklerUGM;                     cls;
graphClassDemo;                        cls;
hmmDistTest;                           cls;
inheritedDiseaseVarElim;               cls;
invGammaSampleDemo;                    cls;
invWIplot1D;                           cls;
invWIplot2D;                           cls;
Knn3ClassHeatMaps;                     cls;
laplacePlotDemo;                       cls;
linregAllMethods;                      cls;
linregGaussVsNIG;                      cls;
linreg_MvnDistTest;                    cls;
linreg_MvnInvGammaDistTest;            cls;
logregFitCrabs;                        cls;
logregSAT;                             cls;
logreg_MvnDistTest;                    cls;
mcmcMvn2dConditioning;                 cls;
misconceptionUGMdemo;                  cls;
mkAlarmNetworkDgm;                     cls;
mkFluDgm;                              cls;
mkMisconceptionUGM;                    cls;
mkSprinklerDgm;                        cls;
mvnImputationDemo;                     cls;
mvnImputationEMdemo;                   cls;
mvnPlot2Ddemo;                         cls;
mvnSeqlUpdateMuSigma1D;                cls;
mvnSeqUpdateSigma1d;                   cls;
mvnSoftCondition;                      cls;
mvtPlotDemo;                           cls;
oldFaithfulDemo;                       cls;
poissonPlotDemo;                       cls;
rainyDayDemo;                          cls;
sampleDistDemo;                        cls;
sampleHIWdemo;                         cls;
sprinklerDGMdemo;                      cls;
sprinklerUGMdemo;                      cls;
sprinklerUGMvarelim;                   cls;
studentVSGauss;                        cls;
undirectedChainFwdBackDemo;            cls;
WIplotDemo;                            cls;
% try instantiating every class...
objectCreationTest

catch ME
	clc; close all
	fprintf('PMTK Tests FAILED!\npress enter to see the error...\n\n')
	pause
	rethrow(ME)
end

cls
fprintf('PMTK Tests Passed\n')