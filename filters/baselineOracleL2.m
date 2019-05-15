%Oracle removes all points which are far from the known mean. 
%Can work in either data space or gradient space
function [indices, scores] = baselineOracleL2(data, p, m)
    n = size(data, 1);
    indices = (1:n)';
    norms = sqrt(sum(data.^2, 2) - 2*data * m' + norm(m,2)^2);
    
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
