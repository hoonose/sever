function [ theta, g, losses, err_test ] = linReg( X_train, y_train, X_test, y_test, r, output_flag )
    
    if ~exist('output_flag','var')
        output_flag = 1;
    end

    [N_train, d] = size(X_train);
    N_test = size(X_test, 1);
    theta = ridge(y_train, X_train, r, 0);
    Xaug = [ones(N_train, 1), X_train];
       
    g = compute_gradients(X_train, y_train, theta, r);
    g_test = compute_gradients(X_test, y_test, theta, r);
    [losses, err_train] = squaredLoss(X_train, y_train, theta);
    [~, err_test] = squaredLoss(X_test, y_test, theta);
    if output_flag == 1
        fprintf(1, 'Train error: %.4f, Test error %.4f\n', err_train, err_test);
        fprintf(1, 'Train gradient: %.4f, Test gradient: %.4f\n', norm(mean(g) / N_train), norm(mean(g_test) / N_test));
    end
end