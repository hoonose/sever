function [gradient, loss, gradient_bias, err] = nabla_Loss_multiclass(X, y, theta, bias, options)
    n = size(X,1);
    d = size(X,2);
    k = size(theta, 2);
    scores = X * theta + repmat(bias, [n 1]);
    if strcmp(options.loss, 'hinge')
      [b_indices, m_indices, b_scores, m_scores] = process(scores, y, k);
      mults = ((m_indices - b_indices) .* repmat(logical(b_scores - m_scores < 1), [1 k]));
      losses = max(0, 1 - (b_scores - m_scores));
      errs = 1 - ((b_scores - m_scores) > 0);
    else
      if strcmp(options.loss, 'logistic')
        b_indices = repmat(yb, [1 k]) == repmat(1:k, [size(yb,1) 1]);
        b_scores = sum(scores .* b_indices, 2);
        [~,ym] = max(scores, [], 2);
        m_indices = repmat(ym, [1 k]) == repmat(1:k, [size(ym,1) 1]);
        m_scores = sum(scores .* m_indices, 2);
        lses = m_scores + log(sum(exp(scores - repmat(m_scores, [1 k])), 2));
        mults = -exp(b_scores - lses);
        losses = lses - b_scores;
        errs = (ym ~= yb);
      else
        assert(false);
      end
    end
    if options.aggregate
      gradient = X' * mults / n;
      gradient_bias = ones(1, n) * mults / n;
      loss = sum(losses) / n;
      err = sum(errs) / n;
    else
      mults_diag = spdiags(reshape(mults, [n*k 1]), 0, n*k, n*k);
      gradient = spalloc(n, d*k, 2*n*d);
      gradient_bias = spalloc(n, k, 2*n);
      for i=1:k
          di = d*(i-1) + (1:d);
          ni = n*(i-1) + (1:n);
          gradient(:,di) = mults_diag(ni,ni) * X;
          gradient_bias(:,i) = mults(:,i);
      end
      loss = losses;
      err = errs;
    end
end
