classdef tsneEstimator
    properties
        metric
        embedding 
    end
    
    methods
        function opt = tsneEstimator(metric)
        if ~exist("metric", 'var'), metric = "euclidean"; end
        opt.metric = metric;
        end

        function opt = train(opt, X)
            X = normalize(X);
            opt.embedding = tsne(X, 'Distance', opt.metric, "NumDimensions", 2);
        end

        function pred_Y = predict(opt, Y)
            S = fit(opt.embedding, Y, "lowess");
            pred_Y= rescale(S(opt.embedding),min(Y), max(Y));                           
        end

    end


end