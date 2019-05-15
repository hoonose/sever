function [ indices, scores ] = filterByClass(gradients, losses, labels, filterFnc)
    n = size(gradients, 1);
    indices = [];
    scores = zeros(n, 1);
    allIndices = (1:n)';
    for i = unique(labels)'
        curIndices = allIndices(labels == i);
        curGradients = gradients(curIndices, :);
        curMean = mean(gradients(curIndices,:), 1);
        [curFilteredIndices, curScores] = filterFnc(curGradients, losses(curIndices), curMean);
        reindex = allIndices(curIndices);
        indices = [indices; reindex(curFilteredIndices)];
        scores(curIndices) = curScores;
    end
    indices = sort(indices);
end