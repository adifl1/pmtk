# PMTK TODO LIST #

**This page stores a running list of current high priority development items.**


---

Create a a function that could walk over the code
and produce a table (latex or html) where rows are methods and columns are
classes (or vice versa), and there is a check mark
if the class implements the method and an x otherwise.
In the html version, clicking on the check mark could bring up the source.

---

Option in viewClassTree to split up the tree into subtrees to be viewed in separate figures.

---

PMTK Unit Testing Framework

---

it would be useful if we could infer the type signature of methods.
Perhaps your new processArgs will make this easier?

---

Some of the functions rely on certain fields in the model being set,
eg when calling p=marginal(model), the field model.infEngine must be defined.
Similarly when calling fit, the fitMethod must be defined.
I wonder if we can put some %# mechanism in so that
the method can be automatically annotated as requiring that certain fields
be predefined.

---

PMTK web documentation, + info for contributing programmers about tags etc

---

Change deptoolbox to use Graphlayout instead of biograph

---

Add decision tree / random forest code to PMTK

---

debug solaris errors

---

auto generated list of util functions like existing demo documentation

---

add tied cov support for MVNs + demos

---

Write an SVM class, (interface on svmlight)

---

PMTK GUI proof of concept

---

factor out the EM code from the HMM class, by analogy to the mixtures code.

---

The other thing: VarElimInfEng calls best\_first\_elim\_order,
whereas JtreeInfEng calls ChordalGraph which calls minWeightElimOrder.
These are basically the same functions and should be merged.
It seems that minWeight is the simpler of the two, since it does not have any of that
time-stamp / stages stuff that I added to handle DBNs.

One detail you will have to deal with is the
difference between passing in node weights (=log number of states) and number of states (node sizes).
Currently when we call ChordalGraph we do not specify the nunber of states, so it
just adds up the weight of a clique, which is equal to the number of nodes in it; this is fine.
When we call VarElim, we know the numstates, so we multiply them to get the weight
of a clique, which is also fine. But if you make VarElim call minWeight, you will have
to set weight=log(nstates).

---

I think we should make NaiveBayesBernoulli a subclass of GenerativeClassifier
whose implementation is just a few lines long. This can be a placeholder
for specialized implementations.

---

Make a Gauss Factor class, so that Var Elim and Jtree will work on
Gaussian graphs or discrete graphs. Just port BNT's canonical Pot
code. Check that you get the same results as Gauss Inf Eng.

---




**recently completed items** (oldest to newest)


---

~~Use Bishop's data for logregDist.demoVisualizePredictive, use both L1, L2 and cross validate lambda~~

---

~~Change logregDist interface so that the user decides when fitting, whether to use point estimation(default) or full Bayesian.~~

---

~~Move all static demos to their own source files~~

---

~~Setup auto generation of documentation via publish~~

---

~~Improve the auto generated documentation~~

---

~~Remove @ directories from PMTK~~

---

~~Vectorize mkSymmetric function~~

---

~~Remove Private Directories~~

---

~~rewrite viewClassTree to work with the new @less naming convention~~

---

~~Setup google analytics for pmtk google code site~~

---

~~Add a delta distribution class with basic ops like mean, mode and use it with logregDist~~

---

~~Exclude trivial functions from PMTK documentation list~~

---

~~Naming convention changes: capitalize class names; add Dist to the end of the graphical model classes, use mix prefix for mixture models~~

---

~~Remove deltaDist class and use constDist class instead.~~

---

~~Modify viewClassTree to use short names, e.g. remove Dist from name~~

---

~~Modify Logregdist predict function to return a single argument, either a discretedist or a Sampledist. Fixed all demos that depended on this change. Other minor interface changes to predict.~~

---

~~Modify Linregdist predict interface - remove 'exact' , 'plugin' option~~

---

~~Combine all inferParams with fit methods and all postPredict with predict methods~~

---

~~Make Discretedist a subclass of Multinomdist~~

---

~~Debug graphClassDemo and ggmBICdemo~~

---

~~Write a general purpose model selection class, which abstracts scoring and searching~~

---

~~Enhanced OneOfK function to automatically tranform y classification data to the right format~~

---

~~Don't store models twice in model selection class (store sorted indices instead)~~

---

~~PCA Transformer Class~~

---

~~Add L1 L2 Elastic net code to linreg class~~

---

~~Apply NB to binary MNIST and plot class confusion matrix~~

---

~~Solution for representing a product of vector distributions: Product Dist!~~

---

~~Make sure prob dist vectorization semantics is consistent throughout: taken care of by Product Dist~~

---

~~Add NonParamDist and ParamDist super classes~~

---

~~Refactor PMTK to remove VecDist,ScalarDist and MatrixDist superclasses~~

---

~~implement the equation for "gamma2" using eqn 13.109~~

---

~~Rename ndims method to ndimensions~~

---

~~HMMs (port Kevin's code to PMTK) (Make only one class)~~

---

~~Make TrellisDist NonParmDist class~~

---

~~HMM Casino demo~~

---

~~Add ProductDist super class and subclasses as needed to handle vectorized
distributions - don't use non product distributions in this way anymore.~~

---

~~HMM speech recognition demos (use generative models framework)~~

---

~~Add fit/predict interface to Model Selection class.~~

---

~~rewrite demo Post Models Exhaustive using ModelSelection class~~

---

~~Prepare Demos slides and code for NIPS talk~~

---

~~Write a script to autogenerate an external source table:
filename      url      author      modified~~

---

~~Mixture Distributions (fit via EM)~~

---

~~Naive Bayes Demos~~

---

~~HMM - Refactor to use inference engine instead of trellis dist~~

---

~~Implement VarElimInfEng class~~

---

~~Optimize factor multiplication and marginalization~~

---

~~Integrate Guillaume's fwdback C code~~

---

~~KNN class~~

---

~~speed up dist2 function via batch processing/bsxfun~~

---

~~KNN demo (mnist performance as we vary the training set size)~~

---

~~Add soft evidence support to VarElimInfEng~~

---

~~Knn Demo 3-class predictive density plots for various K + softmax smoothing & local kernel weighting, etc.~~

---

~~Ensure that all the "interesting" demos are the in the examples directory, rather than being static methods~~

---

~~verify that the latest release of pmtk (1.3) can do runDemos with no errors.~~

---

~~Find a solution for mex incompatibility issues.~~

---

~~make sure PMTK works on Linux~~

---

~~add a makeTestPMTK script to auto-generate a testPMTK.m file~~

---

~~Ensure that every demo has a title~~

---

~~Clean up external authors report~~

---

~~check that you get the same results using FB on an HMM with Gaussian observations
as you do running VarElim on a chain with MixMvn leaf nodes.~~

---

~~Problem with HMM marginal method when asking for two-slice marginals since its
actually calculating xi\_summed not xi.~~

---

~~currently I believe the VE code will not let you predict a hidden leaf node, even if it is discrete. This should be fixed... (If the leaf is a Gaussian, the prediction will be a mixture of Gaussians, one for each unobserved discrete parent setting.)~~

---

~~Make sure the FB code can work with directed and undirected chains (should give same results as VE)~~

---

~~Make that demo we discussed where you compute the marginal of a node, say X2, in a chain of length 5 and then of length 10. Do the directed and undirected version. You can use an arbitrary CPD/ potential for each edge (can be tied). Then verify that the legnth of the chain affects p(X2) in the UGM case but not the DGM case.~~

---

~~port the junction tree engine over from BNT.~~

---

~~Flatten the example directory~~

---

~~rename book code demoxxx files to xxxdemo~~

---

~~rename myfoo functions to fooPmtk~~

---

~~Find a good way to have users fill out a form before downloading PMTK
(ready to set up for production use)~~

---

~~Look into running compiled matlab on~~ <http://aws.amazon.com/ec2/>

---

~~Make sure rundemos runs without graphviz installed~~

---

~~Write a download counter for PMTK~~

---

~~Write a script to parse all of the PMTK e-mail addresses~~

---

~~Demo & proof of concept processArgs in which both positional and named args are supported~~

---

~~Fix the rest of the run demos~~

---

~~InheritedDiseaseeVarElim returns
> 0.9863    0.9933    0.0137    0.5000
whereas it used to return
> [0.9863 0.8946 0.0137 0.5]
Which is correct? And why did it change?
BOTH CORRECT - calculated marginal changed from X2 to X1~~

---

~~mvnSeqlUpdateMuSigma1D fails - maybe use Cody's new MvnIG class~~

---

~~misconception UGM demo does not work with jtree or var Elim, only Enum Inf.~~

---

~~JtreeInfEng should return logZ in its condition method; need to keep track
of normalization constants on upwards pass to root, by analogy
to forwards algo for HMM (see BNT code)~~

---

~~lingaussHybridDemo does not work with jtree~~

---

~~inheritedDiseaseVarElim does not work with jtree because of cts hidden leaf X1.
Implement barren leaf functionality.
(You can disallow queries on barren leafs for simplicity.)~~

---

~~Regnerate the documentation~~

---

~~I noticed in a few places code like this~~

pred = predict(model,testData);              % pred is an object - a discrete distribution
pclass1 = pred.mu(1,:)';
This relies on knowing the name of the field is 'mu', which is not obvious.
Probably best to rename this 'T' internally.
Use the pmf() function in scripts to hide this.~~---


---~~Fix Jtree logZ bug~~---~~streamline PMTK autodocumentation

~~-factor out common code in makeRunDemos & makeTestPMTK and use includeTags and excludeTags controls~~

~~-use these tags with makeDocumentation~~

~~-rename exclude list to excludeFnNameList~~

~~-rename makeDocumentation to publishExamples~~

~~-have it just walk over runDemos~~

~~-have publishExamples also create author report, class diagram and PMTKversion.txt~~

~~-rename PMTKdocsByFuncName.html to publishedExamples.html~~

---

~~Fix UgmTabularDist.convertToTabularFactors nstates bug~~

---

~~Fix GM errors when domain is not 1:d~~

---

~~Put VarElimInfEng continuous node query support back - but hide in a subfunction~~

---

~~Implement forwards filtering backwards sampling for Jtree.~~

---

~~Make a Markov chain class to use as class conditional density for sequence
classifcation.~~

---

~~Make a Linear Dynamical System Dist, class with Kalman filter smoother
for inference. Just port this code:  www.cs.ubc.ca murphyk Software Kalman kalman.html~~

---

~~Amazon aws matlab interface + cluster config~~

---

~~changes to processArgs~~

---

- objectCreationTest fails
~~because loadPMTK does not add Old directories to the path,
but objectCreationTest still knows about them...
(it works if you manually add MixOld to the path). This should be easy to fix.~~

---

~~Also, please do a 'testPMTK' run - I haven't done it in a while, and I know I made a few changes to some constructors
last week, which may have broken a few things ...~~

---

~~- All the other testPMTK functions run, but please check that all demos run~~

---

~~Please can you make sure my new MixMvnEm works, and then change all the demos
that call the old MvnMixDist or MixtureDist (except for Cody's 2 galaxy examples) to use the new MixtureModel,
MixDiscrete or MixMvnEm code. Thanks.
(Eventually I will merge Cody's mcmc code into the new paradigm, but I still need to think through a few design issues.
Meanwhile we'll leave all the old mixtures code in place but not call it, except for mcmc.)~~

---

~~ModelDist waitbar fails on some machines/configurations but not others~~

---

~~Look into auto lambda generation (smallest singular value heuristic? scaling by N,
lars?~~
~~Demo custom search function for Model Dist class - clean up class and add Bayes model averaging.~~
~~Final amazon aws tweaks~~

---
