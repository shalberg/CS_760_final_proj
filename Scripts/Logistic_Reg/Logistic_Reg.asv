format long g
data = readtable("OppScrData_indicator_date_filt_no_ct.csv");

X = table2array(data(:, 33:43));
X = [ones(size(X, 1), 1) X];
y = table2array(data(:,"DeathIndicator"));

theta = (-1 + 2 * rand(12,1));

options = optimset('MaxIter', 400);

[theta] = ...
        conjugate_grad (@(t)(cost_fct(t, X, y)), ...
             theta, options);

fprintf('Theta:\n'); fprintf('%f\n',theta);

disp(sum((X*theta > 0) == y) / length(y) * 100);

