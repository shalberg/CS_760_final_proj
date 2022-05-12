%%% Wrapper Plot Distributions
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

% bayes = naiveBayesClassifier(10, "Wieb");
% bayes.distributions{9} = 'Exp';
% bayes = bayes.train(CT_data, CT_death);
% figure(1)
% t = tiledlayout(3,4);
% for i = 1:size(CT_data, 2)
%     nexttile()
%     hold on
%     histogram(CT_data(CT_death ==0 ,i), 'Normalization', 'pdf')
%     histogram(CT_data(CT_death ==1 ,i), 'Normalization', 'pdf')
%     X_plot = linspace(0,max(CT_data(:,i)), 1000);
%     params = bayes.params{i};
%     if i == 9
%         plot(X_plot, exppdf(X_plot, params(1,1)), 'b-');
%         plot(X_plot, exppdf(X_plot, params(2,1)), 'r-');
%     else
%         plot(X_plot, wblpdf(X_plot, params(1,1), params(1,2)), 'b-');
%         plot(X_plot, wblpdf(X_plot, params(2,1), params(2,2)), 'r-');
%     end
% end

bayes = naiveBayesClassifier(11, "Gamm");
bayes.distributions{10} = 'Exp';
bayes.distributions{11} = 'Norm';
bayes = bayes.train(CT_data, CT_death);

figure(1)
clf 
t = tiledlayout(3,4);


for i = 1:size(CT_data, 2)
    nexttile()
    hold on
    histogram(CT_data(CT_death ==0 ,i), 'Normalization', 'pdf')
    histogram(CT_data(CT_death ==1 ,i), 'Normalization', 'pdf')
    params = bayes.params{i};
    X_plot = linspace(0,max(CT_data(:,i)), 1000);
    if i == 10
        plot(X_plot, exppdf(X_plot, params(1,1)), 'b-');
        plot(X_plot, exppdf(X_plot, params(2,1)), 'r-');
    elseif i == 11
        plot(X_plot, normpdf(X_plot, params(1,1), sqrt(params(1,2))), 'b-');
        plot(X_plot, normpdf(X_plot, params(2,1), sqrt(params(2,2))), 'r-');
    else
        plot(X_plot, gampdf(X_plot, params(1,1), params(1,2)), 'b-');
        plot(X_plot, gampdf(X_plot, params(2,1), params(2,2)), 'r-');
    end
    ax = gca();
    title(ax, titles(i))
end


All_D = readtable('Data/OppScrData_indicator_date_filt_no_ct_no_clinic.csv');
All_data = table2array(All_D(:,["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "AgeAtCT", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_"]));
All_death = table2array(All_D(:, "DeathIndicator"));


[rows, ~] = find(All_data < 0);
All_data = All_data(setdiff(1:length(All_data), rows),:);
All_death = All_death(setdiff(1:length(All_death), rows),:);



Bayes_gamma = naiveBayesClassifier(size(All_data, 2), "Gamm");
Bayes_gamma.distributions{10} = 'Exp';
Bayes_gamma.distributions{13} = 'Bern';
Bayes_gamma.distributions{15} = 'Bern';
Bayes_gamma.distributions{16} = 'Bern';
Bayes_gamma.distributions{17} = 'Exp';
Bayes_gamma.distributions{19} = 'Exp';
Bayes_gamma =  Bayes_gamma.train(All_data, All_death);


figure(2)
clf
t = tiledlayout(4,5);
titles = ["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "AgeAtCT", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_"];
titles=strrep(titles, '_', ' ');

for i = 1:size(All_data, 2)
    nexttile
    hold on
    histogram(All_data(All_death ==0 ,i), 'Normalization', 'pdf')
    histogram(All_data(All_death ==1 ,i), 'Normalization', 'pdf')
    params = Bayes_gamma.params{i};
    X_plot = linspace(0,max(All_data(:,i)), 1000);
    if i == 10 || i == 17 || i == 19 
        plot(X_plot, exppdf(X_plot, params(1,1)), 'b-');
        plot(X_plot, exppdf(X_plot, params(2,1)), 'r-');
    elseif i == 13 || i == 15 || i == 16 
    else
        plot(X_plot, gampdf(X_plot, params(1,1), params(1,2)), 'b-');
        plot(X_plot, gampdf(X_plot, params(2,1), params(2,2)), 'r-');
    end
    ax = gca();
    title(ax, titles(i))
end


