function g = compute_gradients(X, y, theta, r)
    N = size(X, 1);
    Xaug = [ones(N, 1), X];
    losses = y - Xaug * theta;
    g = diag(losses) * Xaug + r * repmat(theta', N, 1);
end 
