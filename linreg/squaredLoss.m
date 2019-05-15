function [losses, error] = squaredLoss(X, y, theta)
    N = size(X, 1);
    Xaug = [ones(N, 1), X];
    losses = y - Xaug * theta;
    error = norm(losses).^2 * (1 / N);
end