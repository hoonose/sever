%Removes p percent of points with the largest gradient
function [indices, scores] = baselineGradient(gradients, p)
    n = size(gradients,1); %length(gradients);
    indices = (1:n)';
    norms = sqrt(sum(gradients.^2, 2));
    
    %Sort the data in increasing order of norm
    sortedData = sortrows([indices norms], 2);
    %Find the threshold for discarding a point
    threshNorm = sortedData(ceil((1-p)*n), 2);
    if threshNorm == 0
        threshNorm = max(sortedData(:,2));
    end
    %Assign scores to each, where a scores > 1 is discarded
    sortedData = [sortedData sortedData(:,2)/threshNorm];
    
    %Re-sort by indices, extract indices and scores
    data = sortrows(sortedData);
    scores = data(:,3);
    indices = data(scores < 1,1);
end