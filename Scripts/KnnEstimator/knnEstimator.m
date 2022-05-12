classdef knnEstimator
    properties
        k
        metric
        net
        weight
    end
    methods
        function opt  = knnEstimator(k, metric, weight)
            if ~exist("k", 'var'), k =10; end
            if ~exist("metric", 'var'), metric = "euclidean"; end
            if ~exist("weight", 'var'), weight = false; end
            opt.k = k;
            opt.metric = metric;
            opt.weight = weight;
        end
        function opt = train(opt, X)
            X = normalize(X); 
            [idx, dist] = knnsearch(X, X, "K", opt.k+1, "Distance",opt.metric);
            idx = idx(:, 2:end);
            dist = dist(:, 2:end);
            from = reshape(repmat((1:length(X))', 1, 10)', [], 1);
            to = reshape(idx', [], 1);
            dist_vec = reshape(dist', [], 1);
            opt.net = digraph(from, to, dist_vec);
        end

        function pred_Y = predict(opt, Y)
            pred_Y = nan(size(Y));
            for i = 1:length(Y)
                out_edges = opt.net.Edges(opt.net.outedges(i), :);
                knn_neighbors =  out_edges.EndNodes(:,2);
                if opt.weight 
                    sims =  (out_edges.Weight).^(-1);
                    props = sims/sum(sims);
                    pred_Y(i) = props' * Y(knn_neighbors);
                else
                    pred_Y(i) = mean(Y(knn_neighbors));
                end
            end
            pred_Y = normalize(pred_Y) * std(Y) + mean(Y);
        end
            

        
    end


end
