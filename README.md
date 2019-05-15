# Sever: A Robust Meta-Algorithm for Stochastic Optimization
A MATLAB implementation of [Sever: A Robust Meta-Algorithm for Stochastic Optimization](https://arxiv.org/abs/1803.02815).

Prerequisites 
===
This project requires installation of the following packages:
* [Gurobi](http://www.gurobi.com/)
* [YALMIP](https://yalmip.github.io/)

Explanation of Files
===

Filter files (`filters` directory)
---
The following are different methods for filtering points.
* `baselineGradient.m`: A baseline that removes the points with the largest gradients.
* `baselineLosses.m`: A baseline that removes the points with the largest losses.
* `baselineOracleL2.m`: A baseline that removes the points which have the largest L2 norm with respect to some given point. Can be used in either the gradient or data space.
* `filterSimple.m`: Our method, which projects gradients onto the top principal component and then removes points based on their resulting magnitude.

SVM files (`svm` directory)
---
The following are the code and data for our SVM evaluation.
* `data`: Folder containing the two datasets, corresponding to the Enron dataset and our synthetic dataset.
* `diaries`: Folder containing a collection of attacks for the two datasets. Subdirectories first split based on dataset, and then based on corruption fraction and method used for generating attacks. Each of these folders contains a variety of attacks, corresponding to different settings of hyperparameters during generation.
* `testSingleAttack.m`, `testSingleSuite.m`, and `testAll.m`: Scripts for testing a single attack, a suite of attacks (i.e., all attacks for a particular corruption fraction and a generation method), and all attacks. 
* `aggregateScores.m` and `evaluateDefenses.m`: Parse and set various options, and then run the actual defenses and measure their accuracy.
* `train.m`: Train a (non-robust) classifier.
* `nabla_Loss.m`, `nabla_Loss_multiclass.m`, `process.m`: Compute gradients for single and multiclass classification. 
* `filterByClass.m`: Runs the given filter function on a specified class.

Regression files (`linreg` directory)
---
* `data`: Folder containing the drug discovery dataset.
* `scriptOptions`: Folder containing different choices of parameters for the attacks, tuned to attack different defenses on different datasets. Documentation for which parameter choice is supposed to have which outcome is in `testAll.m`, and the options are parsed by `parseOptionsLinReg.m`
* `testAll.m`: Scripts for running the attacks (with options as specified in scriptOptions) against all defenses.
* `linReg.m`: Trains a (non-robust) linear classifier.
* `linRegAttack.m`: A simple data poisoning attack on linear regression, as described in the paper.
* `filterLinReg.m`: Runs the filter with a chosen defense on the dataset given.
* `robustCentering.m`: Uses robust mean estimation to robustly center the data points, as described in the paper.
* `compute_gradients.m`: Given a dataset, a model, and a ridge parameter, computes the gradients of the model evaluated at the datapoints and the ridge parameter.
* `squaredLoss.m`: Computes squared loss of model on dataset.

Plotting scripts (`plot_scripts` directory)
---
Figures in the paper can be approximately reproduced by running the following scripts. Note that these scripts currently operate on pre-computed data, which we include for convenience, but could be re-computed by running the appropriate scripts in other directories.
* `plotEnron.m`: Plots for SVM results on Enron dataset.
* `plotSVMSynthetic.m`: Plots for SVM results on synthetic dataset.
* `plotFigsLinReg.m`: Plots for linear regression results on drug discovery dataset and synthetic dataset.
* `writeErrs.m`: Writes accuracies to file, for plotting by other methods.

Reference
===
This repository is an implementation of our paper [Sever: A Robust Meta-Algorithm for Stochastic Optimization](https://arxiv.org/abs/1803.02815) in [ICML 2019](https://icml.cc/Conferences/2019), authored by [Ilias Diakonikolas](http://www.iliasdiakonikolas.org/), [Gautam Kamath](http://www.gautamkamath.com/), [Daniel M. Kane](https://cseweb.ucsd.edu/~dakane/), [Jerry Li](http://www.mit.edu/~jerryzli/), [Jacob Steinhardt](https://cs.stanford.edu/~jsteinhardt/), and [Alistair Stewart](http://www.alistair-stewart.com/).
