function scores = balancedFoldCrossValidateDT(X, y, k, classifier, label, classifier_id)

if floor(mean(y)) == 0
part = floor(linspace(1, length(y(y == 1))+1, k+1));
else 
part = floor(linspace(1, length(y(y == 0))+1, k+1));
end

P = randperm(length(y));
X = X(P, :);
y = y(P, :);

true_y = find(y == 1);
false_y = find(y == 0);

all_idx = 1:part(end)-1;
true_y = true_y(all_idx);
false_y = false_y(all_idx);

scores = table();



for i = 1:k
    test_idx = union(true_y(part(i):part(i + 1) - 1), false_y(part(i):part(i + 1) - 1));
    train_idx = union(true_y(setdiff(all_idx, test_idx)), false_y(setdiff(all_idx, test_idx)));
    X_test = X(test_idx, :);
    X_train = X(train_idx, :);
    y_test = y(test_idx, :);
    y_train = y(train_idx, :);
    classifier = classifier.train(X_train, y_train);
    y_pred = classifier.predict(X_test);
    scores = [scores; computeTestStats(y_test, y_pred, label, classifier_id)];
end
end

