clear all;

load results/linreg/results-1.mat

figure(1);
plot(range, plot_errs(:, 1), '-k', 'LineWidth', 2);
hold on
plot(range, plot_errs(:, 2), '--k', 'LineWidth', 2);
plot(range, plot_errs(:, 3), '-b', 'LineWidth', 2);
plot(range, plot_errs(:, 4), '-g', 'LineWidth', 2);
plot(range, plot_errs(:, 6), '-c', 'LineWidth', 2);
plot(range, plot_errs(:, 7), '-m', 'LineWidth', 2);
ylim([1 2])

legend({'Uncorrupted','Corrupted','l2', 'gradient','loss', 'Sever'}, 'Position',[0.2 0.65 0.1 0.2])
set(gca,'LooseInset',get(gca,'TightInset'));
set(gca,'FontSize', 18)
xlabel('eps')
ylabel('test error')
title('eps vs Test Error, drug discovery')

load results/linreg/results-2.mat

figure(2);
plot(range, plot_errs(:, 1), '-k', 'LineWidth', 2);
hold on
plot(range, plot_errs(:, 2), '--k', 'LineWidth', 2);
plot(range, plot_errs(:, 3), '-b', 'LineWidth', 2);
plot(range, plot_errs(:, 4), '-g', 'LineWidth', 2);
plot(range, plot_errs(:, 6), '-c', 'LineWidth', 2);
plot(range, plot_errs(:, 7), '-m', 'LineWidth', 2);
ylim([1 2])

legend({'Uncorrupted','Corrupted','l2', 'gradient','loss', 'Sever'}, 'Position',[0.2 0.65 0.1 0.2])
set(gca,'LooseInset',get(gca,'TightInset'));
set(gca,'FontSize', 18)
xlabel('eps')
ylabel('test error')
title('eps vs Test Error, drug discovery')

load results/linreg/results-3.mat

figure(3);
plot(range, plot_errs(:, 1), '-k', 'LineWidth', 2);
hold on
plot(range, plot_errs(:, 2), '--k', 'LineWidth', 2);
plot(range, plot_errs(:, 3), '-b', 'LineWidth', 2);
plot(range, plot_errs(:, 4), '-g', 'LineWidth', 2);
plot(range, plot_errs(:, 6), '-c', 'LineWidth', 2);
plot(range, plot_errs(:, 7), '-m', 'LineWidth', 2);
ylim([1 2])

legend({'Uncorrupted','Corrupted','l2', 'gradient','loss', 'Sever'}, 'Position',[0.2 0.65 0.1 0.2])
set(gca,'LooseInset',get(gca,'TightInset'));
set(gca,'FontSize', 18)
xlabel('eps')
ylabel('test error')
title('eps vs Test Error, drug discovery')

load results/linreg/results-4.mat

figure(4);
plot(range, plot_errs(:, 1), '-k', 'LineWidth', 2);
hold on
plot(range, plot_errs(:, 2), '--k', 'LineWidth', 2);
plot(range, plot_errs(:, 3), '-b', 'LineWidth', 2);
plot(range, plot_errs(:, 4), '-g', 'LineWidth', 2);
plot(range, plot_errs(:, 6), '-c', 'LineWidth', 2);
plot(range, plot_errs(:, 7), '-m', 'LineWidth', 2);
ylim([0 3])

legend({'Uncorrupted','Corrupted','l2', 'gradient','loss', 'Sever'}, 'Position',[0.2 0.65 0.1 0.2])
set(gca,'LooseInset',get(gca,'TightInset'));
set(gca,'FontSize', 18)
xlabel('eps')
ylabel('test error')
title('eps vs Test Error, synthetic data')

