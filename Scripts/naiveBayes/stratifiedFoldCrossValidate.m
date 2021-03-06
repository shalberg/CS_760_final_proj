function [scores, results] = stratifiedFoldCrossValidate(X, y, k, classifier, label, classifier_id)
    
part_true = floor(linspace(1, length(y(y == 1))+1, k+1));
    part_false = floor(linspace(1, length(y(y == 0))+1, k+1));
    
    P = randperm(length(y));
    X = X(P, :);
    y = y(P, :);
    
    true_y = find(y == 1);
    false_y = find(y == 0);


    scores = table();
    results = zeros(size(y));

    for i = 1:k
        test_idx = union(true_y(part_true(i):part_true(i + 1) - 1),false_y(part_false(i):part_false(i + 1) - 1));
        train_idx = setdiff(1:length(y), test_idx);
        X_test = X(test_idx, :);
        X_train = X(train_idx, :);
        y_test = y(test_idx, :);
        y_train = y(train_idx, :);
        classifier = classifier.train(X_train, y_train);
        y_pred = classifier.predict(X_test);
        results(test_idx) = y_pred;
        scores = [scores; computeTestStats(y_test, y_pred, label, classifier_id)];
    end
end