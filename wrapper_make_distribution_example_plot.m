%%% Wrapper make distrubition example plot
addpath('Scripts/naiveBayes')
CT_D=readtable('Data/OppScrData_indicator_date_filt_no_ct.csv');
CT_data = table2array(CT_D(:, ["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", ...
    "VATArea_cm2_", "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", ...
    "L3SMI_cm2_m2_", "AoCaAgatston", "LiverHU_Median_"]));
CT_death = table2array(CT_D(:, "DeathIndicator"));


titles = ["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", ...
    "VATArea_cm2_", "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", ...
    "L3SMI_cm2_m2_", "AoCaAgatston", "LiverHU_Median_"];
titles = strrep(titles, "_", " ");



[rows, ~] = find(CT_data < 0);
CT_data = CT_data(setdiff(1:length(CT_data), rows), :);
CT_death = CT_death(setdiff(1:length(CT_death), rows), :);


bayes = naiveBayesClassifier(11, "Gamm");
bayes.distributions{10} = 'Exp';
bayes.distributions{11} = 'Norm';
bayes = bayes.train(CT_data, CT_death);


bayes_norm = naiveBayesClassifier(11);
bayes_norm= bayes_norm.train(CT_data, CT_death);
X_plot = linspace(0,max(CT_data(:,4)), 1000);

t = tiledlayout(1,2);
nexttile()
hold on
histogram(CT_data(CT_death ==1 ,4), 'Normalization', 'pdf')
histogram(CT_data(CT_death ==0 ,4), 'Normalization', 'pdf')

params = bayes_norm.params{4};
plot(X_plot, normpdf(X_plot, params(1,1), sqrt(params(1,2))), 'r-');
plot(X_plot, normpdf(X_plot, params(2,1), sqrt(params(2,2))), 'b-');
ax = gca();
title(ax, "Normal Distribution Fit to Data")
nexttile()
hold on
histogram(CT_data(CT_death ==1 ,4), 'Normalization', 'pdf')
histogram(CT_data(CT_death ==0 ,4), 'Normalization', 'pdf')

params = bayes.params{4};
plot(X_plot, exppdf(X_plot, params(1,1)), 'r-');
plot(X_plot, exppdf(X_plot, params(2,1)), 'b-');

ax = gca();

title(t, "VAT Area fit to normal and Gamma Distribution");
l = legend("Death", "Alive");
l.Location = "eastoutside";





