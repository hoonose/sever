function [theta, gradients, losses, theta2, err_test, bias, gradients_bias] = train(X_train, y_train, X_test, y_test, options)
    options = processOptionsTrain(options);
    fprintf(1, 'Using method "%s"\n', options.method);
    is_binary = length(unique(y_train)) <= 2;
    if ~is_binary
        k = max(y_train);
    else
        k = 1;
    end
    N_train = size(X_train, 1);
    N_test = size(X_test, 1);
    d = size(X_train, 2);

    if strcmp(options.method, 'exact')
      assert(strcmp(options.loss, 'hinge'));
      theta = sdpvar(d,k);
      bias = sdpvar(1,k);
      if ~options.use_bias
        fprintf(1, 'pinning bias to 0\n');
        bias = zeros(1,k);
      end
      z = sdpvar(N_train,1);
      Obj = 0.5 * options.decay * norm(theta,2)^2 + options.decay1 * norm(theta,2) + sum(z) / N_train;
      if options.regularize_bias
        Obj = Obj + 0.5 * options.decay * bias^2;
      end
      Constraint = [];
      if is_binary
        margins = y_train .* (X_train * theta + bias);
        Constraint = [z >= 0; z >= 1 - margins];
      else
        margins = X_train * theta + repmat(bias, [N_train 1]);
        Constraint = [z >= 0];
        for j=1:k
          for j2=1:k
            if j~=j2
              Constraint = [Constraint; z(y_train==j) >= 1 - margins(y_train==j,j) + margins(y_train==j,j2)];
            end
          end
        end
      end
      optimize(Constraint, Obj, sdpsettings('verbose', options.verbose, 'solver', 'gurobi', 'cachesolvers', 1));
      opt = double(Obj);
      theta = double(theta);
      bias = double(bias);
      [~,~,~,err_train] = nabla_Loss(X_train, y_train, theta, bias, options);
      [~,~,~,err_test]  = nabla_Loss(X_test, y_test, theta, bias, options);
      fprintf(1, 'train error: %.4f, test error: %.4f\n', err_train, err_test);
      [gradients, losses, gradients_bias, errs] = nabla_Loss(X_train, y_train, theta, bias, setfield(options, 'aggregate', 0));
      fprintf(1, 'claimed training losses: %.4f and %.4f and %.4f\n', opt, sum(double(z))/N_train, mean(losses));
      theta2 = 1 * ones(d,k);
    else
      theta = zeros(d,k);
      theta2 = 1e-4 * ones(d,k);
      bias = zeros(1,k);
      bias2 = 1e-4 * ones(1,k);
      for epoch=1:options.num_epochs
          pi = randperm(N_train);
          for t=1:options.batch_size:N_train
              t2 = t+options.batch_size-1;
              if t+options.batch_size > N_train
                  t2 = N_train;
              end
              Xb = X_train(pi(t:t2), :);
              yb = y_train(pi(t:t2));
              [g, ~, g_bias, ~] = nabla_Loss(Xb, yb, theta, bias, options);
              g = g + options.decay * theta + options.decay1 * theta / (norm(theta, 'fro') + 1e-9);
              theta2 = theta2 + g.^2;
              bias2 = bias2 + g_bias.^2;
              if strcmp(options.method, 'adagrad')
                theta = theta - options.eta * (g ./ sqrt(theta2));
                if options.use_bias
                  bias = bias - options.eta * (g_bias ./ sqrt(bias2));
                end
              else
                if strcmp(options.method, 'sgd')
                  theta = theta - options.eta * g;
                  if options.use_bias
                    bias = bias - options.eta * g_bias;
                  end
                else
                  assert(false);
                end
              end
          end
          [~,~,~,err_train] = nabla_Loss(X_train, y_train, theta, bias, options);
          [~,~,~,err_test]  = nabla_Loss(X_test, y_test, theta, bias, options);
          fprintf(1, 'Error (epoch %d): %.4f, %.4f\n', epoch, err_train, err_test);
      end
      [gradients, losses, gradients_bias, errs] = nabla_Loss(X_train, y_train, theta, bias, setfield(options, 'aggregate', 0));
    end
end

function options = processOptionsTrain(options)
  if ~isfield(options, 'method')
    options.method = 'adagrad';
  end
  if ~isfield(options, 'batch_size')
    options.batch_size = 20;
  end
  if ~isfield(options, 'eta')
    options.eta = 0.02;
  end
  if ~isfield(options, 'decay') || strcmp(options.decay, 'generalization')
    options.decay = 0.0;
  end
  if ~isfield(options, 'decay1')
    options.decay1 = 0.0;
  end
  if ~isfield(options, 'use_bias')
    options.use_bias = 1;
  end
  if ~isfield(options, 'regularize_bias')
    options.regularize_bias = 0;
  end
  if ~isfield(options, 'verbose')
    options.verbose = 2;
  end
  if ~isfield(options, 'num_epochs')
    options.num_epochs = 3;
  end
end
