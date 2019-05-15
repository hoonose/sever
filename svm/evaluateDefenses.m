function scores = evaluateDefenses(X_clean, y_clean, X_attack, y_attack, X_test, y_test, options)
  options = processOptionsEvaluateDefenses(options);
  p_def = options.p_def;
  defenses = {'none', 'xCentered', 'loss', 'gradient', 'gradientCentered', 'SVD'};
  filters  = {@(g,l,mu) deal(1:length(l),zeros(length(l),1)), ...
              @(g,l,mu) baselineOracleL2(g,p_def,mu), ...
              @(g,l,mu) baselineLosses(l,p_def), ...
              @(g,l,mu) baselineGradient(g,p_def), ...
              @(g,l,mu) baselineOracleL2(g,p_def,mu), ...
              @(g,l,mu) filterSimple(g,p_def,mu)};
  pickX = @(x,g) x;
  pickG = @(x,g) g;
  picks = {pickG, pickX, pickG, pickG, pickG, pickG};
  n_def = length(defenses);
  n_clean = length(y_clean);
  X_train = [X_clean; X_attack];
  y_train = [y_clean; y_attack];
  N_train = size(X_train,1);
  scores = struct();
  min_err = inf;
  if ~isfield(options, 'def_ids')
    options.def_ids = 1:6;
  end
  for i=options.def_ids
    fprintf(1, '=================\nRunning "%s" defense\n=================\n', defenses{i});
    active_indices = (1:N_train)';
    for iter=1:(options.num_rounds+1)
        fprintf(1, '%d/%d points left (%d/%d bad)\n', length(active_indices), N_train, sum(active_indices > n_clean), N_train - n_clean);
        xs = X_train(active_indices,:);
        ys = y_train(active_indices);
        [theta,gradients,losses,~,err,bias] = train(xs, ys, X_test, y_test, options);
        [indices, outlier_scores] = filterByClass(picks{i}(xs, gradients), losses, ys, filters{i});
        if length(indices) == length(active_indices) || length(indices) == 0
          break;
        end
        active_indices = active_indices(indices);
    end
    [~,train_loss] = nabla_Loss(X_train, y_train, theta, bias, setfield(options, 'aggregate', 1));
    [~,clean_loss] = nabla_Loss(X_clean, y_clean, theta, bias, setfield(options, 'aggregate', 1));
    [~,test_loss] = nabla_Loss(X_test, y_test, theta, bias, setfield(options, 'aggregate', 1));
    scores = setfield(scores, defenses{i}, err);
    if strcmp(defenses{i}, 'none')
      scores = setfield(scores, sprintf('%s_loss_train', defenses{i}), train_loss);
      scores = setfield(scores, sprintf('%s_loss_clean', defenses{i}), clean_loss);
      scores = setfield(scores, sprintf('%s_loss_test', defenses{i}), test_loss);
    end
    if ~strcmp(defenses{i}, 'SVD')
      min_err = min(min_err, err);
    end
  end
  scores = setfield(scores, 'all', min_err);
end

function options = processOptionsEvaluateDefenses(options)
  if ~isfield(options, 'p_def')
    options.p_def = 0.03; 
  end
  if ~isfield(options, 'num_rounds')
    options.num_rounds = 5;
  end
end
