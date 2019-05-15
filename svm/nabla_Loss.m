function [gradient, loss, gradient_bias, err] = nabla_Loss(X, y, theta, bias, options)
    options = processOptionsNablaLoss(options);
    if size(theta,2) == 1
      N = size(X, 1);
      d = size(X, 2);
      yX = spdiags(y, 0, N, N) * X;
      margins = yX * theta + y * bias;
      if strcmp(options.loss, 'hinge')
        losses = max(1-margins, 0);
        mults = -(margins < 1);
      else
        if strcmp(options.loss, 'logistic')
          losses = max(-margins, 0) + log(1 + exp(-abs(margins)));
          mults = -1./(1 + exp(margins));
        else
          assert(false);
        end
      end
      errs = (margins < 0) + 0.5 * (margins == 0);
      if options.aggregate
        gradient = (mults' * yX)' / N;
        gradient_bias = (mults' * y)' / N;
        loss = sum(losses) / N;
        err = sum(errs) / N;
      else
        gradient = spdiags(mults, 0, N, N) * yX;
        gradient_bias = spdiags(mults, 0, N, N) * y;
        loss = losses;
        err = errs;
      end
    else
      [gradient, loss, gradient_bias, err] = nabla_Loss_multiclass(X, y, theta, bias, options);
    end
end

function options = processOptionsNablaLoss(options)
  if ~isfield(options, 'loss')
    options.loss = 'hinge';
  end
  if ~isfield(options, 'aggregate')
    options.aggregate = 1;
  end
end
