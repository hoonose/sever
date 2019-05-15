clear
dirNames = ls('results/synthetic');
dirs = {};
defs = {'loss', 'SVD'};

while length(dirNames)>1
    [dir,~,~,nextindex]=sscanf(dirNames, '%s  ', 1);
    dirNames = dirNames(nextindex:end);
    dirs = [dirs;dir];
end

%Choose which defense we're going to be targeting
for i = 1:length(defs)
    def = defs{i};
    none = [];
    xCentered = [];
    loss = [];
    gradient = [];
    gradientCentered = [];
    SVD = [];
    epsList = [5 10 15 20 30];
    for eps = epsList
        relDirs = {};
         for j = 1:length(dirs)
             dir = dirs{j};
             strEps = num2str(eps);
             if strcmp(strEps,dir(5:5+length(strEps)-1))
                relDirs = [relDirs; dir];
             end
         end

         summary1 = sprintf('results/synthetic/%s/summary_p_def_%d_num_rounds_2.mat',relDirs{1}, eps);
         summary2 = sprintf('results/synthetic/%s/summary_p_def_%d_num_rounds_2.mat', relDirs{2}, eps);
         
         load(summary1);
         bestValue1 = getfield(scoresAggregated, def);
         load(summary2);
         bestValue2 = getfield(scoresAggregated, def);

         if bestValue1 >= bestValue2
             load(summary1);
             dir = relDirs{1};
         else
             load(summary2);
             dir = relDirs{2};
         end
         bestIndex = getfield(bestIndices, def);
         load(sprintf('results/synthetic/%s/%s_scores_p_def_%d_num_rounds_2.mat',dir,bestIndex(1:end-4),eps));
         if (strcmp(def,'SVD'))&&(eps==30) %In this case, bestValue is 0.072 for results/synthetic/eps-30_wd-1_exact_L2_grad_rep-1_all_attacks/8.mat
             load('results/synthetic/eps-30_wd-1_exact_L2_grad_rep-1_all_attacks/8_scores_p_def_30_num_rounds_2.mat');
             scores = scoresCur;
         end
         none = [none getfield(scoresCur,'none')];
         xCentered = [xCentered getfield(scoresCur,'xCentered')];
         loss = [loss getfield(scoresCur,'loss')];
         gradient = [gradient getfield(scoresCur,'gradient')];
         gradientCentered = [gradientCentered getfield(scoresCur,'gradientCentered')];
         SVD = [SVD getfield(scoresCur,'SVD')];
    end
    figure(1); clf;
    epsList = epsList/1000;
    plot([0.005 0.03], [0.058 0.058], epsList, none, epsList, xCentered, epsList, loss, epsList, gradient, epsList, gradientCentered, epsList, SVD, 'LineWidth', 2);
    if i == 1
        legend({'uncorrupted', 'corrupted', 'l2', 'loss', 'gradient', 'gradientCentered', 'Sever'}, 'Location', 'east');
    else
        legend({'uncorrupted', 'corrupted', 'l2', 'loss', 'gradient', 'gradientCentered', 'Sever'});
    end
    if i == 1
        title(sprintf('Strongest attacks against %s on synthetic',defs{i}));
    else 
        title('Strongest attacks against Sever on synthetic');
    end
    ys = ylim;
    ylim([0 ys(2)]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    set(gca,'FontSize', 18)
    xlabel('Outlier fraction epsilon');
    ylabel('Test error');
    print(gcf, sprintf('acc-vs-eps-synthetic-%s',defs{i}), '-dpng');
    
    if i == 1
        folder = sprintf('svm_synth_%s',defs{i});
    else
        folder = 'svm_synth_sever';
    end
    if ~exist(folder, 'dir')
        mkdir(folder);            
    end
    
    epsList = [0 epsList];
    none = [0.058 none];
    xCentered = [0.058 xCentered];
    loss = [0.058 loss];
    gradient = [0.058 gradient];
    gradientCentered = [0.058 gradientCentered];
    SVD = [0.058 SVD];

    writeErrs(folder, 'uncorrupted.txt', epsList, [0.058 0.058 0.058 0.058 0.058 0.058]);
    writeErrs(folder, 'corrupted.txt', epsList, none);
    writeErrs(folder, 'l2.txt', epsList, xCentered);
    writeErrs(folder, 'loss.txt', epsList, loss);
    writeErrs(folder, 'gradient.txt', epsList, gradient);
    writeErrs(folder, 'gradientCentered.txt', epsList, gradientCentered);
    writeErrs(folder, 'sever.txt', epsList, SVD);
end
