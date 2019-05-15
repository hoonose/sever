function [b_indices, m_indices, b_scores, m_scores, ym] = process(batch_scores, yb, k)
    b_indices = repmat(yb, [1 k]) == repmat(1:k, [size(yb,1) 1]);
    b_scores = sum(batch_scores .* b_indices, 2);
    batch_scores(b_indices) = -realmax;
    [~,ym] = max(batch_scores, [], 2);
    m_indices = repmat(ym, [1 k]) == repmat(1:k, [size(ym,1) 1]);
    m_scores = sum(batch_scores .* m_indices, 2);
end
