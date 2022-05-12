classdef decisionTreeClassifier
    properties
        Tree;
        min_nodes_split;
        max_depth;
        prune;
    end
    methods
  %% Constructor
  function opt = decisionTreeClassifier(min_nodes_split, max_depth, prune)
            if ~exist("min_nodes_split", 'var') min_nodes_split = 1; end
            if ~exist("max_depth", "var") max_depth = inf; end
            if ~exist("prune", "var") prune = true; end
                opt.max_depth = max_depth; 
                opt.min_nodes_split = min_nodes_split;
                opt.prune=prune;
        end
  %% Computes the Entropy of X
        function E_x = computeEntropy(opt, X, split)
            X = X >= split;
            p_x_1 = mean(X);
            p_x_0 = 1 - p_x_1;
            if p_x_1 > 0 && p_x_0 > 0
                E_x = p_x_0 * log2(1/p_x_0) + p_x_1 * log2(1/p_x_1);
            else
                E_x = 0;
            end
        end
%% Computes the Conditional Entropy of X given Y
        function E_x_y  = computeConditionalEntropy(opt, X, Y, split)
            p_y_1 = mean(Y);
            p_y_0 = 1 - p_y_1;
            E_x_y = p_y_0 * computeEntropy(opt, X(~Y), split) + p_y_1 * computeEntropy(opt, X(Y), split);
        end
%% Optimizes The value of X used to split by testing all X
function [I_x_y_max, split_opt] = ComputeMaxMutualInfo(opt, X, Y)
            [sort_X, I] = sort(X, 'ascend');
            sort_Y = Y(I);
            I_x_y_max = -inf;
            split_opt = -inf;
            for i = (1+opt.min_nodes_split):(length(X)-opt.min_nodes_split+1)
                if sort_Y(i - 1) ~= sort_Y(i)
                    E_x_y = computeConditionalEntropy(opt, sort_X, sort_Y, sort_X(i));
                    I_x_y = computeEntropy(opt, sort_X, sort_X(i)) - computeConditionalEntropy(opt, sort_X, sort_Y, sort_X(i));
                    if(E_x_y  > I_x_y_max)
                        I_x_y_max = I_x_y;
                        split_opt = sort_X(i);
                    end
                end
            end
end

 %% Builds the Decision tree of max depth. 
        function [sub_tree, Name] = computeSubTree(opt, X, X_label, Y, Name, side_label,depth)
            if ~exist("Name", "var") Name = 1; end
            if ~exist("side_label", "var") side_label = nan; end
            if ~exist("depth", "var") depth = 0; end
            max_depth = opt.max_depth;
            sub_tree = digraph();
            num_yes=sum(Y);
            num_no = sum(~Y);
            %Determine MaxMutualInfo for each feature in X;
            if range(Y) > 0  && depth < max_depth - 1  && num_yes >= opt.min_nodes_split && num_no >= opt.min_nodes_split%% Determine if Y is all one type. 
                depth = depth + 1;
                MI = zeros(size(X,2), 1);
                Splits = zeros(size(X,2), 1);
                for i = 1:size(X,2)
                    [MI(i), Splits(i)] = ComputeMaxMutualInfo(opt, X(:,i), Y);
                end
                root_i = find(max(MI) == MI, 1);
                sub_tree = addnode(sub_tree, table({num2str(Name)}, X_label(root_i), Splits(root_i), side_label(1), nan,'VariableNames', {'Name', 'Variable', 'Split_Val', 'Node Type', 'Num_Cases'}));
                root_idx = Name;

                % Splitdata and compute Trees
                X_r_idx = X(:, root_i) >= Splits(root_i);
                X_r = X(X_r_idx, :);
                Y_r = Y(X_r_idx, :);
                X_l = X(~X_r_idx, :);
                Y_l = Y(~X_r_idx, :);

                %Traverse Left
                if ~isempty(Y_l)
                    new_node = Name + 1; 
                    [sub_tree_l, new_node_idx] = computeSubTree(opt, X_l, X_label, Y_l, new_node, 0, depth);
                    if isempty(sub_tree_l.Edges)
                        sub_tree = digraph([sub_tree.Edges], [sub_tree.Nodes; sub_tree_l.Nodes]);
                    elseif isempty(sub_tree.Edges)
                        sub_tree = digraph([sub_tree_l.Edges], [sub_tree.Nodes; sub_tree_l.Nodes]);
                    else
                        sub_tree = digraph([sub_tree.Edges; sub_tree_l.Edges], [sub_tree.Nodes; sub_tree_l.Nodes]);
                    end
                    sub_tree = sub_tree.addedge({num2str(root_idx)},{num2str(new_node)}, table(0, 'VariableName', {'Edge_direction'}));
                    Name = new_node_idx;
                    
                end
                %Traverse Right
                if ~isempty(Y_r)
                    new_node = Name + 1; 
                    [sub_tree_r, new_node_idx] = computeSubTree(opt, X_r, X_label, Y_r, new_node, 1, depth);
                    if isempty(sub_tree_r.Edges)
                        sub_tree = digraph([sub_tree.Edges], [sub_tree.Nodes; sub_tree_r.Nodes]);
                    elseif isempty(sub_tree.Edges)
                        sub_tree = digraph([sub_tree_r.Edges], [sub_tree.Nodes; sub_tree_r.Nodes]);
                    else
                        sub_tree = digraph([sub_tree.Edges; sub_tree_r.Edges], [sub_tree.Nodes; sub_tree_r.Nodes]);
                    end
                    sub_tree = sub_tree.addedge({num2str(root_idx)}, {num2str(new_node)}, table(1, 'VariableName', {'Edge_direction'}));
                    Name = new_node_idx; 
                end
            else
                sub_tree = addnode(sub_tree, table({num2str(Name)}, "", round(mean(Y)), 3, length(Y), 'VariableNames', {'Name', 'Variable', 'Split_Val', 'Node Type', 'Num_Cases'}));
            end
        end
        %% Used to Predict X_new (matrix) via a recursion through tree 
        function [pred_X] = predict(opt, X_new)
            pred_X = opt.predictRecurse(X_new);    
        end

        function [pred_X] = predictRecurse(opt, X_new, start_node, pred_X, idx)
            % Tree Props
            n = height(X_new);
            if ~exist("start_node", "var"), start_node = 1; end
            if ~exist("idx", "var"), idx = [1:n]'; end
            if ~exist("pred_X", "var"), pred_X = nan(n, 1); end

            var = opt.Tree.Nodes.Variable(start_node);     
            split = opt.Tree.Nodes.Split_Val(start_node);
            linked_nodes = opt.Tree.Edges(opt.Tree.outedges(start_node), :);

            % right side
            idx_r = idx(X_new.(var) >= split);
            X_r = X_new(X_new.(var) >= split, :);
            start_r = opt.Tree.findnode(linked_nodes.EndNodes{2, 2});
            if ~isempty(X_r)
                if opt.Tree.Nodes.("Node Type")(start_r) == 3
                    pred_X(idx_r) = opt.Tree.Nodes.Split_Val(start_r);
                else 
                    pred_X = predictRecurse(opt, X_r, start_r, pred_X, idx_r);
                end
            end

            % left side 
            idx_l = idx(X_new.(var) < split);
            X_l = X_new(X_new.(var) < split, :);
            start_l = opt.Tree.findnode(linked_nodes.EndNodes{1, 2});
            if ~isempty(X_l)
                if opt.Tree.Nodes.("Node Type")(start_l) == 3
                    pred_X(idx_l) = opt.Tree.Nodes.Split_Val(start_l);
                else 
                    pred_X = predictRecurse(opt, X_l, start_l, pred_X, idx_l);
                end
            end
        end
         %% Train the Data on X to predict Y, limit to max depth. Max_depth defualt is 5.   
         function[opt] = train(opt, X, Y)
             if opt.prune
                opt = trainAndPrune(opt, X, Y);
             else
                opt = trainNoPrune(opt, X, Y);
             end
         end
         
         function [opt] = trainNoPrune(opt, X, Y)
            max_depth = opt.max_depth;
            X_labels = X.Properties.VariableNames;
            X = table2array(X);
            Y = logical(Y);
            %%% Grows a full Tree;
            [opt.Tree] = computeSubTree(opt, X, X_labels, Y, 1, nan, 0);
        end
        %% Train a large tree then prunes unnessary nodes. Does this by spliting data into train and test. 
        %% Remove nodes that do not effect accuracy of test. 
        function opt = trainAndPrune(opt, X, Y, split)
            if ~exist("split", 'var'), split = .8; end
            max_depth = opt.max_depth;

            P = randperm(length(Y));
            X = X(P, :);
            Y = Y(P, :);
            
            y_true = find(Y == 1);
            y_false  = find(Y == 0);
            
            train_idx = union(y_true(1:floor(length(y_true)*split)), y_false(1:floor(length(y_false)*split)));
            test_idx = setdiff(1:length(Y), train_idx);

            X_train = X(train_idx, :);
            Y_train = Y(train_idx, :);

            opt = trainNoPrune(opt, X_train, Y_train);

            X_test = X(test_idx, :);
            Y_test = Y(test_idx, :);

            opt = pruneTree(opt, X_test, Y_test);
        end

        %% Computes Accuracy
        function acc = computeAcc(opt, Test_X, Test_y)
            if isempty(opt.Tree)
                error('Classifier is untrained. Please train before predicting.')
            end
            
            y_pred = opt.predict(Test_X);

            acc = sum((Test_y == y_pred))/length(Test_y);
        end

        function bacc = computeBalAcc(opt, Test_X, Test_y)
            if isempty(opt.Tree)
                error('Classifier is untrained. Please train before predicting.')
            end
            
            y_pred = opt.predict(Test_X);
            yes = Test_y == 1;
            no = Test_y == 0;
            bacc = 0.5 * sum(Test_y(yes) == y_pred(yes))/sum(Test_y(yes)) + ...
                  0.5 * sum(Test_y(no) == y_pred(no))/length(Test_y(no));

            
        end
        
        
        %% Prunes Tree of nodes that do not effect accuracy of Test_y predictions. (slow)
        function [opt] = pruneTree(opt, Test_X, Test_y)
            if isempty(opt.Tree)
                error('Classifier is untrained. Please train before predicting.')
            end
            tree = opt.Tree;

            bacc = opt.computeBalAcc(Test_X, Test_y);

            leaves = tree.Nodes(tree.Nodes.("Node Type") == 3, :);
            yes_nodes = leaves.Split_Val== 1;
            no_nodes = leaves.Split_Val== 0;
            branches = tree.Nodes(tree.Nodes.("Node Type") == 0 | tree.Nodes.("Node Type") == 1, :);
            
            
            while ~isempty(branches)
                temp_tree = tree;
                branch = find(strcmp(tree.Nodes.Name, branches.Name(1)));
                outs = ismember(leaves.Name, tree.bfsearch(tree.Nodes.Name{branch}));
                num_yes = sum(leaves.Num_Cases(outs & yes_nodes));
                num_no = sum(leaves.Num_Cases(outs & no_nodes));
                temp_tree.Nodes.("Node Type")(branch) = 3;
                temp_tree.Nodes.Split_Val(branch) = round(num_yes/(num_no + num_yes));
                temp_tree.Nodes.Num_Cases(branch) = num_yes + num_no;
                temp_tree.Nodes.Variable(branch) = "";
                temp_tree = temp_tree.rmnode(setdiff(temp_tree.bfsearch(tree.Nodes.Name{branch}),tree.Nodes.Name{branch}));

                T = decisionTreeClassifier();
                T.Tree = temp_tree;
                new_bacc = T.computeAcc(Test_X, Test_y);
                if new_bacc >= bacc
                    bacc = new_bacc;
                    branches=branches(~ismember(branches.Name, tree.bfsearch(tree.Nodes.Name{branch})),:); 
                    tree = temp_tree;
                else
                    branches = branches(2:end, :);
                end 

            end
            opt.Tree=tree;
        end

            
            
    end
end
