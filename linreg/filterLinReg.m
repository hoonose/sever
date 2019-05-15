function [th, scores, err_test, active_indices, active_scores] = filterLinReg( X_train, y_train, X_test, y_test, options )
    
    options = processOptionsTrain(options);

    N_train = size(X_train, 1);
    active_indices = (1:N_train)';
            
    
    for iter=1:options.iter

        fprintf(1, '%d/%d points left (%d/%d bad)\n', length(active_indices), N_train, sum(active_indices > options.n_clean), N_train - options.n_clean);
        [th, gradients, losses, err_test] = linReg(X_train(active_indices,:), y_train(active_indices), X_test, y_test, options.ridge);
        fprintf(1, 'norm of theta = %4d, bias = %4d\n', norm(th), abs(th(1)));
        gradients_mean = mean(gradients, 1);
        
        if options.useG
            [indices, scores] = options.filterFnc(gradients, losses, gradients_mean);
        else
            [indices, scores] = options.filterFnc(X_train(active_indices, :), losses, mean(X_train(active_indices, :)));
        end
        
        remaining_good = size(find(active_indices <= options.n_clean), 1);
        
        if options.debug
            figure(iter); hold on
            histogram(scores(1:remaining_good),0:.03:(quantile(scores, 0.995)+.05),'facecolor','blue','facealpha',.5,'edgecolor','none');
            histogram(scores((remaining_good + 1):size(scores, 1)),0:.03:(quantile(scores, 0.995)+.05),'facecolor','red','facealpha',.5,'edgecolor','none');
            hold off
        end
        
        active_scores = scores(indices);
        active_indices = active_indices(indices);
    end

end

function options = processOptionsTrain(options)
  if ~isfield(options, 'ridge')
    options.ridge = 0;
  end
  if ~isfield(options, 'p')
      options.p = 0.3;
  end
  if ~isfield(options, 'iter')
      options.iter = 8;
  end
  if ~isfield(options, 'centering')
      options.centering = true;
  end
  if ~isfield(options, 'debug')
      options.debug = false;
  end
  if ~isfield(options, 'useG')
      options.useG = true;
  end
  if ~isfield(options, 'figureNum')
      options.figureNum = 1;
  end
  if ~isfield(options, 'filterFnc')
      options.filterFnc = @(g, l, mu) filterMAD(g, options.p, mu);
  elseif strcmp(options.filterFnc, 'losses')
      options.filterFnc = @(g, l, mu) baselineLosses(l, options.p);
  elseif strcmp(options.filterFnc, 'l2')
      options.filterFnc = @(g,l,mu) baselineOracleL2(g, options.p, mu);
  elseif strcmp(options.filterFnc, 'grad')
      options.filterFnc = @(g,l,mu) baselineGradient(g, options.p);
  elseif strcmp(options.filterFnc, 'simple') 
      options.filterFnc = @(g, l, mu) filterSimple(g, options.p, mu);
  else
      fprintf(1, 'Invalid filter function, using filter default\n');
      options.filterFnc = @(g, l, mu) filterSimple(g, options.p, mu);
  end 
end

