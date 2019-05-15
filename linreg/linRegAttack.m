function [ X_bad, y_bad ] = linRegAttack( X_good, y_good, n_bad, mag, s )

    %%% Breaks synthetic at p = 0.02, qsar at p = 0.05
    
    [n_good, d] = size(X_good);
    zero_grad_direction = (y_good.') * X_good * (1 / n_bad);
    
    bad_direction = zero_grad_direction;

     X_bad = ( repmat(bad_direction, n_bad, 1) + mag^4 * norm(bad_direction) * randn(n_bad, d) / (10 * sqrt(d)) ) * (1 / (s * mag));
    y_bad = -s * ones(n_bad, 1);


end
