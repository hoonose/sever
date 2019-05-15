clear
dirNames = ls('results/enron');
dirs = {};
defs = {'loss', 'gradientCentered', 'SVD'};

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
    rsepsList = [9 17 26 34 51];
    for j = 1:length(epsList)
        eps = epsList(j);
        rseps = rsepsList(j);
        relDirs = {};
         for j = 1:length(dirs)
             dir = dirs{j};
             strEps = num2str(eps);
             if strcmp(strEps,dir(5:5+length(strEps)-1))
                relDirs = [relDirs; dir];
             end
         end

         summary1 = sprintf('results/enron/%s/summary_p_def_%d_num_rounds_2',relDirs{1}, rseps);
         summary2 = sprintf('results/enron/%s/summary_p_def_%d_num_rounds_2', relDirs{2}, rseps);
         
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
         load(sprintf('results/enron/%s/%s_scores_p_def_%d_num_rounds_2.mat',dir,bestIndex(1:end-4),rseps));
         none = [none getfield(scoresCur,'none')];
         xCentered = [xCentered getfield(scoresCur,'xCentered')];
         loss = [loss getfield(scoresCur,'loss')];
         gradient = [gradient getfield(scoresCur,'gradient')];
         gradientCentered = [gradientCentered getfield(scoresCur,'gradientCentered')];
         SVD = [SVD getfield(scoresCur,'SVD')];
    end

    figure(1); clf;
    epsList = epsList/1000;
    plot([0.005 0.03], [0.03 0.03], epsList, none, epsList, xCentered, epsList, loss, epsList, gradient, epsList, gradientCentered, epsList, SVD, 'LineWidth', 2);
    title(sprintf('Strongest attacks against %s on Enron',defs{i}));
    set(gca,'LooseInset',get(gca,'TightInset'));
    set(gca,'FontSize', 18);
    xlabel('Outlier fraction epsilon');
    ylabel('Test error');
    ys = ylim;
    ylim([0 ys(2)]);
    %print(gcf, sprintf('acc-vs-eps-enron-%s',defs{i}), '-dpng');
    
    if i ~= 3
        folder = sprintf('svm_enron_%s',defs{i});
    else
        folder = 'svm_enron_sever';
    end
    if ~exist(folder, 'dir')
        mkdir(folder);            
    end
    
    epsList = [0 epsList];
    none = [0.03 none];
    xCentered = [0.03 xCentered];
    loss = [0.03 loss];
    gradient = [0.03 gradient];
    gradientCentered = [0.03 gradientCentered];
    SVD = [0.03 SVD];

    writeErrs(folder, 'uncorrupted.txt', epsList, [0.03 0.03 0.03 0.03 0.03 0.03]);
    writeErrs(folder, 'corrupted.txt', epsList, none);
    writeErrs(folder, 'l2.txt', epsList, xCentered);
    writeErrs(folder, 'loss.txt', epsList, loss);
    writeErrs(folder, 'gradient.txt', epsList, gradient);
    writeErrs(folder, 'gradientCentered.txt', epsList, gradientCentered);
    writeErrs(folder, 'sever.txt', epsList, SVD);
end

%Consider diaries/enron/eps-30_wd-9_exact_L2_rep-2_all_attacks/29.mat
%training: +1 = 1209, -1 = 2928
%attack: +1 = 85, -1 = 39
%Iter 1: 16 +1's removed, new Ngood = 1193
%Iter 2: 13 +1's removed, new Ngood = 1180


clear
for iter = 1:3
    load(sprintf('results/enron/eps-30_wd-9_exact_L2_rep-2_all_attacks/29_svd_scores_iter%d.mat',iter));
    active_indices = 1:length(scores);
    scores = scores/max(scores);

    figure(1); clf; hold on;
    if iter ~= 3
        bw = 0.01;
    else
        bw = 0.025;
    end
    histogram(scores(active_indices <= Ngood),0:bw:(quantile(scores, 0.995)+.03),'facecolor','blue','facealpha',.5,'edgecolor','none');
    histogram(repmat(scores(active_indices > Ngood), [10 1]),0:bw:(quantile(scores, 0.995)+.03),'facecolor','red','facealpha',.5,'edgecolor','none');    
    oldXlim = xlim;
    xlim([0 oldXlim(2)]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    set(gca,'FontSize', 18)
    set(gca, 'xticklabel', []);
    set(gca, 'yticklabel', []);    
    title(sprintf('SVM: Scores for Sever on Enron with hidden outliers, iter. %d',iter));
    box on

    print(gcf, sprintf('hist-enron-sever-hidden%d',iter), '-dpng');
end

%Consider diaries/enron/eps-10_wd-9_exact_L2_grad_rep-2_all_attacks/13.mat
%This is the strongest attack at 0.01 vs gradientCentered
%41 poisoned data points, all in +1 class

clear
cdfSVD = [];
cdfxCentered = [];
cdfGradientCentered = [];
epsList = 0:0.01:0.30;
defs = {'xCentered', 'gradientCentered', 'svd'};

for i = 1:length(defs)
    load(sprintf('results/enron/eps-10_wd-9_exact_L2_grad_rep-2_all_attacks/13_%s_scores.mat',defs{i}));
    active_indices = 1:length(scores);
    figure(1); clf; hold on;
    histogram(scores(active_indices <= Ngood),0:.03:(quantile(scores, 0.995)+.03),'facecolor','blue','facealpha',.8,'edgecolor','none');
    histogram(repmat(scores(active_indices > Ngood), [10 1]),0:.03:(quantile(scores, 0.995)+.03),'facecolor','red','facealpha',.8,'edgecolor','none');
    set(gca,'LooseInset',get(gca,'TightInset'));
    set(gca,'FontSize', 18)
    set(gca, 'xticklabel', []);
    set(gca, 'yticklabel', []);
    if i == 1
        title('Scores for l2 on Enron with 1% outliers');
        %print(gcf, 'hist-enron-l2', '-dpng');
    elseif i == 2
        title('Scores for gradientCentered on Enron with 1% outliers');
        %print(gcf, 'hist-enron-gradientCentered', '-dpng');
    else
        title('Scores for Sever on Enron with 1% outliers');
        %print(gcf, 'hist-enron-sever', '-dpng');
    end
    for eps = epsList
        thresh = quantile(scores,1-eps);
        removedFrac = length(find(find(scores > thresh) > 1209))/41;
        if i == 1
            cdfxCentered = [cdfxCentered removedFrac];
        elseif i == 2
            cdfGradientCentered = [cdfGradientCentered removedFrac];
        else
            cdfSVD = [cdfSVD removedFrac];
        end
    end
end
figure(1); clf;
plot(epsList, cdfxCentered, epsList, cdfGradientCentered, epsList, cdfSVD, 'LineWidth', 2);
legend({'l2', 'gradientCentered', 'Sever'}, 'Location', 'best');
xlabel('Fraction of overall dataset removed');
ylabel('Fraction of outliers removed');
title('Fraction of outliers removed at various levels of pruning');
set(gca,'LooseInset',get(gca,'TightInset'));
set(gca,'FontSize', 18)
%print(gcf, 'cdf-enron-pruning', '-dpng');

folder = 'cdf_enron_pruning';
if ~exist(folder, 'dir')
    mkdir(folder);   
end
writeErrs(folder, 'l2.txt', epsList, cdfxCentered);
writeErrs(folder, 'gradientCentered.txt', epsList, cdfGradientCentered);
writeErrs(folder, 'sever.txt', epsList, cdfSVD);

