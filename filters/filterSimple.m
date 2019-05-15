function [indices, scores] = filterSimple(g, p, m) 
    %Find the top principal component
    k = 1;
    N_filt = size(g,1);
    gcentered = (g - repmat(m, [N_filt, 1])) / sqrt(N_filt);
    [~, ~, V_p] = svds(gcentered, k);
    projection = V_p(:,1:k);
    
    %Scores are the magnitude of the projection onto the top principal component
    scores = gcentered * projection;
    scores = sqrt(sum(scores.^2, 2));
    
    %Remove the p fraction of largest scores
    %If this would remove all the data, remove nothing
    indices = (1:N_filt)';
    if quantile(scores, 1-p) > 0
        scores = scores / quantile(scores, 1-p);
        indices = indices(scores < 1.0);
    else
        scores = scores / max(scores);
    end
end
