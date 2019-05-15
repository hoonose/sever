%Robustly find center points for regression data. Covariates are centered using our filter 
%based on projection onto the top principal component, while we take the median for labels
function [ x_robust_mean, y_robust_mean ] = robustCentering( X_train, y_train, options )
    N_train = size(X_train, 1);
    
    m_active_indices = (1:N_train)';
    for iter = 1:4
        [indices, ~] = filterSimple(X_train(m_active_indices, :), options.p, mean(X_train));
        m_active_indices = m_active_indices(indices);
    end
    x_robust_mean = mean(X_train(m_active_indices, :));
    y_robust_mean = median(y_train);
end

