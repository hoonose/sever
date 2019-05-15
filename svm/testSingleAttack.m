eps = 0.010;
pathdir = mfilename('fullpath');
pathdir = pathdir(1:end-17);
load(sprintf('%s/data/enron_data.mat', pathdir));
attackNumber = 13;
attackName = sprintf('eps-%d_wd-9_exact_L2_grad_rep-2_all_attacks/%d.mat',eps*1000, attackNumber);
load(attackName);
result_dir = sprintf('%s/results/enron/eps-%d_wd-9_exact_L2_grad_rep-2_all_attacks',pathdir, eps*1000);
if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end

theRatio = 4137.0/1209.0;
options.num_rounds = 2;
options.p_def = theRatio*eps/options.num_rounds;
options.def_ids = 1:6;
scoresCur = evaluateDefenses(X_train, y_train, X_attack, y_attack, X_test, y_test, options)
save(sprintf('%s/%d_scores_%s.mat', result_dir, attackNumber, sprintf('p_def_%d_num_rounds_%d', round(1000*options.p_def), options.num_rounds)), 'scoresCur')