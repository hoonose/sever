clear;

%%% Hard parameters for SEVER on qsar
load scriptOptions/1.mat
%%% Typical case parameters for qsar. Causes all defenses but l2 and Sever
%%% to have high error
%load scriptOptions/2.mat
%%% Typical case parameters for qsar. Causes all defenses but gradient and Sever
%%% to have high error
%load scriptOptions/3.mat
%%% Typical case parameters for synthetic (worst case is similar)
%load scriptOptions/4.mat

if strcmp(scriptOptions.data, 'synthetic')
    %%% Generating synthetic data
    d = 500;
    n_clean = 5000;
    n_test = 500;
    if scriptOptions.generateCenteredData
        fprintf('Producing centered data...\n');
    else
        fprintf('Producing uncentered data...\n');
    end
    [th, X_train_good, y_train_good, X_test_init, y_test_init] = generateSyntheticDataLinReg(d, n_clean, n_test, scriptOptions.generateCenteredData);
elseif strcmp(scriptOptions.data, 'qsar')
    %%% Loading qsar data
    load data/qsar.mat;
    n_clean = size(X_train, 1);
    X_train_good = X_train;
    y_train_good = y_train;
    X_test_init = X_test;
    y_test_init = y_test;
else
    fprintf('Unknown data source, terminating...\n')
    return
end

r = scriptOptions.r;
n_rep = scriptOptions.n_rep;
filterFncs = scriptOptions.filterFncs;
useG = scriptOptions.useG;
nDefenses = size(filterFncs, 2) + 2;

range = 0:0.005:0.1;
errs = zeros(size(range, 2), nDefenses);
ii = 1;
for err = range
    errs_tmp = zeros(n_rep, nDefenses);
    
    for jj = 1:n_rep
        [~, ~, ~, uncorrupted_loss] = linReg(X_train_good, y_train_good, X_test_init, y_test_init, r);
        errs_tmp(jj, 1) = uncorrupted_loss;
        n_bad = floor(err * n_clean);
        
        s = scriptOptions.s(err);
        mag = scriptOptions.mag;
        
        [X_train_bad, y_train_bad] = linRegAttack( X_train_good, y_train_good, n_bad, 1, s );
        X_train = [X_train_good; X_train_bad];
        y_train = [y_train_good; y_train_bad];
        X_test = X_test_init;
        y_test = y_test_init;

        [~, ~, ~, corrupted_loss] = linReg(X_train, y_train, X_test, y_test, r);
        errs_tmp(jj, 2) = corrupted_loss;
        
        N_train = size(X_train, 1);
        N_test = size(X_test, 1);
        active_indices = (1:N_train)';

        options = struct();
        options.ridge = r;
        options.p = err / 2;
        options.n_clean = n_clean;
        options.iter = scriptOptions.iter;
        options.debug = scriptOptions.debug;
        
        if scriptOptions.centering
            [x_robust_mean, y_robust_mean] = robustCentering(X_train, y_train, options);
            X_train = X_train - repmat(x_robust_mean, [N_train, 1]);
            y_train = y_train - y_robust_mean;
            X_test = X_test - repmat(x_robust_mean, [N_test, 1]);
            y_test = y_test - y_robust_mean;
        end

        filterIter = 3;

        for fncs = filterFncs
            options.filterFnc = fncs{1};
            options.useG = useG(filterIter - 2);
            fprintf(1, '\n\nUsing filter type: %s, use grad: %s\n', options.filterFnc, mat2str(useG(filterIter - 2)));
            [theta, ~, err_test] = filterLinReg(X_train, y_train, X_test, y_test, options);
            errs_tmp(jj, filterIter) = err_test;
            filterIter = filterIter + 1;
        end
        
    end
       
    errs(ii, :) = median(errs_tmp);
    ii = ii + 1;
end

plot_errs = errs;

figure()
plot(range, plot_errs(:, 1), '-k', 'LineWidth', 2);
hold on
for ii = 2:nDefenses
    plot(range, plot_errs(:, ii), 'LineWidth', 2);
end

ylim(scriptOptions.ylim)
legend(scriptOptions.legend)