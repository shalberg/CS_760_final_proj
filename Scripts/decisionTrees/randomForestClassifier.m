classdef randomForestClassifier 
    properties
        Trees
        dt_class
        num_tree
        split
        prune
    end
    methods
        function opt = randomForestClassifier(min_samples, max_depth, num_tree, split, prune)
            if ~exist("min_samples", "var"), min_samples = 1; end
            if ~exist("max_depth", "var"), max_depth = inf; end
            if ~exist("num_tree", "var"), max_depth = 10; end
            if ~exist("split", "var"), max_depth = split; end
            if ~exist("prune", "var"), max_depth = prune; end
            opt.Trees={};
            opt.num_tree = num_tree;
            opt.split = split;
            opt.prune = prune;
            opt.dt_class = decisionTreeClassifier(min_samples, max_depth, prune);
        end

        function opt = train(opt, X, Y)

            for i = 1:opt.num_tree
                P = randperm(length(Y));
                X = X(P, :);
                Y = Y(P, :);
                
                y_true = find(Y == 1);
                y_false  = find(Y == 0);
                if length(y_true) < length(y_false)
                    min_set = length(y_true);
                else
                    min_set = length(y_false);
                end
                train_idx = union(y_true(1:floor(min_set*opt.split)), y_false(1:floor(min_set*opt.split))); 
                opt.Trees{i} = opt.dt_class.train(X(train_idx, :), Y(train_idx));
            end
        end

        function pred_X = predict(opt, X_new)
            if isempty(opt.Trees)
                error('Classifier is untrained. Please train before predicting.')
            end
            pred_X =zeros(height(X_new),1);
            for i = 1:length(opt.Trees)
                dt = opt.Trees{i};
                pred_X = pred_X + dt.predict(X_new);
            end
            pred_X = round(pred_X/length(opt.Trees));           
        end
    end
end