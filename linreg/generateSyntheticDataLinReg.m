function [ th, X_train, y_train, X_test, y_test ] = generateSyntheticDataLinReg( d, n_clean, n_test, centered )
    th = randn(d, 1) / sqrt(d);

    if centered
        X_train = randn(n_clean, d);
        X_test = randn(n_test, d);
    else
        X_train = randn(n_clean, d) + ones(n_clean, d);
        X_test = randn(n_test, d) + ones(n_test, d);
    end

    X_train = randn(n_clean, d);
    X_test = randn(n_test, d);

    y_train = X_train * th + randn(n_clean, 1) * (1 / 10);
    y_test = X_test * th + randn(n_test, 1) * (1 / 10);
    
    if not(centered)
        y_train = y_train + 5;
        y_test = y_test + 5;
    end
end

