%Removes p percent of points with the largest losses
function [indices, scores] = baselineLosses(losses, p)
    losses = abs(losses);
    n = length(losses);
    indices = (1:n)';
    %Sort the data in increasing order of loss
    sortedData = sortrows([indices losses], 2);
    %Find the threshold for discarding a point
    threshLoss = sortedData(ceil((1-p)*n), 2);
    if threshLoss == 0
        threshLoss = max(sortedData(:,2));
    end
    %Assign scores to each, where a scores > 1 is discarded
    sortedData = [sortedData sortedData(:,2)/threshLoss];
    
    %Re-sort by indices, extract indices and scores
    data = sortrows(sortedData);
    scores = data(:,3);
    indices = data(scores < 1,1);
end
