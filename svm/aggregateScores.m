function aggregateScores(attack_dir, optionsGlobal)
  if nargin < 2
    optionsGlobal = struct();
  end
  attack_dir
  optionsGlobal
  if isfield(optionsGlobal, 'name') && exist(sprintf('%s/summary_%s.mat', optionsGlobal.result_dir, optionsGlobal.name), 'file') == 2
    fprintf(1, 'summary_%s.mat file already exists, skipping %s...\n', optionsGlobal.name, optionsGlobal.result_dir);
    return;
  end
  ls();
  filenames = ls(attack_dir);
  filenames
  files = {};
  while length(filenames)>1
    %filenames
    [file,~,~,nextindex]=sscanf(filenames, '%s  ', 1);
    filenames = filenames(nextindex:end);
    files = [files;file];
  end
  files
  if isfield(optionsGlobal, 'datafile')
    load(optionsGlobal.datafile);
  end
  scoresAggregated = struct();
  bestIndices = struct();
  for f=1:length(files)
    filename=files{f};
    if length(filename) >= 7 && strcmp(filename(1:7), 'summary')
      continue;
    end
    if length(filename) >= 7
      continue;
    end
    fprintf(1, 'filename: %s\n', filename);
    clear scores;
    load(sprintf('%s/%s', attack_dir, filename));
    
    if isfield(optionsGlobal, 'p_def')
      options.p_def = optionsGlobal.p_def;
    else
      options.p_def = 0.025;
    end
    if isfield(optionsGlobal, 'num_rounds')
      options.num_rounds = optionsGlobal.num_rounds;
    else
      options.num_rounds = 2;
    end
    options.def_ids = 1:6;
    
    if isfield(optionsGlobal, 'name')
      fileToSaveTo = sprintf('%s/%s_scores_%s.mat', optionsGlobal.result_dir, filename(1:end-4), optionsGlobal.name);
      if exist(fileToSaveTo)
        fprintf(1, 'file %s already exists, re-using result!\n', fileToSaveTo);
        load(fileToSaveTo);
      else
        eval(['scores_', optionsGlobal.name,' = evaluateDefenses(X_train, y_train, X_attack, y_attack, X_test, y_test, options);']);
        eval(['scoresCur = scores_',optionsGlobal.name]);
        save(sprintf('%s/%s_scores_%s.mat', optionsGlobal.result_dir, filename(1:end-4), optionsGlobal.name), 'scoresCur');
      end
    else
      scoresCur = scores;
    end
    allFields = fields(scoresCur);
    for j=1:length(allFields)
      curVal = getfield(scoresCur, allFields{j});
      if isfield(scoresAggregated, allFields{j})
        oldVal = getfield(scoresAggregated, allFields{j});
        if curVal > oldVal
          bestIndices = setfield(bestIndices, allFields{j}, filename);
          scoresAggregated = setfield(scoresAggregated, allFields{j}, curVal);
        end
      else
        bestIndices = setfield(bestIndices, allFields{j}, filename);
        scoresAggregated = setfield(scoresAggregated, allFields{j}, curVal);
      end
    end
  end
  if isfield(optionsGlobal, 'name')
    save(sprintf('%s/summary_%s.mat', optionsGlobal.result_dir, optionsGlobal.name), 'bestIndices', 'scoresAggregated');
  else
    save(sprintf('%s/summary.mat', optionsGlobal.result_dir), 'bestIndices', 'scoresAggregated');
  end
end
