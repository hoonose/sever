epses = [0.005 0.01 0.015 0.02 0.03]
for eps = epses
   testSingleSuiteSynthetic(eps, sprintf('eps-%d_wd-1_exact_L2_grad_rep-1_all_attacks', eps*1000)); 
   testSingleSuiteSynthetic(eps, sprintf('eps-%d_wd-1_exact_L2_rep-1_all_attacks', eps*1000)); 
end
for eps = epses
   testSingleSuiteEnron(eps, sprintf('eps-%d_wd-9_exact_L2_grad_rep-2_all_attacks', eps*1000)); 
   testSingleSuiteEnron(eps, sprintf('eps-%d_wd-9_exact_L2_rep-2_all_attacks', eps*1000)); 
end

function testSingleSuiteSynthetic(eps, dirName)
    pathdir = mfilename('fullpath');
    pathdir = pathdir(1:end-8);

    theRatio = 5000/2474;
    num_rounds = 2;
    p_def = theRatio*eps/num_rounds;
    result_dir = sprintf('%s/results/synthetic/%s',pathdir, dirName);

    options = struct();
    options.num_rounds = num_rounds;
    options.p_def = p_def;
    options.datafile = 'data/synthetic_data.mat';
    options.name = sprintf('p_def_%d_num_rounds_%d', round(1000*options.p_def), options.num_rounds);
    options.epsilon = eps;
    options.result_dir = result_dir;
    if ~exist(options.result_dir, 'dir')
        mkdir(options.result_dir);
    end
    aggregateScores(sprintf('%s/diaries/synthetic/%s', pathdir, dirName),options);

    load(sprintf('%s/summary_p_def_%d_num_rounds_%d.mat', result_dir, round(1000*p_def), num_rounds))
    scoresAggregated
end

function testSingleSuiteEnron(eps, dirName)
    pathdir = mfilename('fullpath');
    pathdir = pathdir(1:end-8);
    theRatio = 4137.0/1209.0;
    num_rounds = 2;
    p_def = theRatio*eps/num_rounds;
    result_dir = sprintf('%s/results/enron/%s',pathdir, dirName);

    options = struct();
    options.num_rounds = num_rounds;
    options.p_def = p_def;
    options.datafile = 'data/enron_data.mat';
    options.name = sprintf('p_def_%d_num_rounds_%d', round(1000*options.p_def), options.num_rounds);
    options.epsilon = eps;
    options.result_dir = result_dir;
    if ~exist(options.result_dir, 'dir')
        mkdir(options.result_dir);
    end
    aggregateScores(sprintf('%s/diaries/enron/%s', pathdir, dirName),options);

    load(sprintf('%s/summary_p_def_%d_num_rounds_%d.mat', result_dir, round(1000*p_def), num_rounds))
    scoresAggregated
end