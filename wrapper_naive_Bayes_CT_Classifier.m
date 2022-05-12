addpath('Scripts/naiveBayes/')

%% Clinical Data Only 
CT_D=readtable('Data/OppScrData_indicator_date_filt_no_ct.csv');
CT_data = table2array(CT_D(:, ["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", ...
    "VATArea_cm2_", "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", ...
    "L3SMI_cm2_m2_", "AoCaAgatston", "LiverHU_Median_"]));

CT_death = table2array(CT_D(:, "DeathIndicator"));
CT_cancer = table2array(CT_D(:, "CancerIndicator"));
CT_alz  = table2array(CT_D(:, "AlzheimersIndicator"));
CT_diab = table2array(CT_D(:, "Type2DiabetesIndicator"));
CT_hd = table2array(CT_D(:, "HeartFailureIndicator"));


n  = length(CT_death);
[rows, ~] = find(CT_data < 0);
CT_data = CT_data(setdiff(1:n, rows),:);
CT_death = CT_death(setdiff(1:n, rows),:);
CT_cancer = CT_cancer(setdiff(1:n, rows),:);
CT_alz  = CT_alz(setdiff(1:n, rows),:);
CT_diab = CT_diab(setdiff(1:n, rows),:);
CT_hd = CT_hd(setdiff(1:n, rows),:);

Conditions = {CT_death, "death"; ...
              CT_cancer, "cancer"; ...
              CT_alz, "alzheimers"; ... 
              CT_diab, "diabetes"; ... 
              CT_hd, "heart disease"};


Bayes_norm = naiveBayesClassifier();
scores_norm = table();
for i = 1:length(Conditions)
    scores_norm =[scores_norm; stratifiedFoldCrossValidate(CT_data, Conditions{i, 1}, 5, Bayes_norm, Conditions{i, 2}, "Naive Bayes Gaussian")];
end

scores_gamma = table();
Bayes_gamma = naiveBayesClassifier(11, "Gamm");
Bayes_gamma.distributions{10} = 'Exp';
for i = 1:length(Conditions)
    scores_gamma =[scores_gamma; stratifiedFoldCrossValidate(CT_data, Conditions{i, 1}, 5, Bayes_gamma, Conditions{i, 2}, "Naive Bayes Gamma")];
end

%% CT and Clinical Data
Clinical_D = readtable('Data/OppScrData_indicator_date_filt_no_ct_no_clinic.csv');
Clinical_data = table2array(Clinical_D(:,["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "AgeAtCT", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_"]));
Clinical_death = table2array(Clinical_D(:, "DeathIndicator"));
Clinical_cancer = table2array(Clinical_D(:, "CancerIndicator"));
Clinical_alz  = table2array(Clinical_D(:, "AlzheimersIndicator"));
Clinical_diab = table2array(Clinical_D(:, "Type2DiabetesIndicator"));
Clinical_hd = table2array(Clinical_D(:, "HeartFailureIndicator"));

n  = length(Clinical_data);
[rows, ~] = find(Clinical_data < 0);
Clinical_data = Clinical_data(setdiff(1:n, rows),:);
Clinical_death = Clinical_death(setdiff(1:n, rows),:);
Clinical_cancer = Clinical_cancer(setdiff(1:n, rows),:);
Clinical_alz  = Clinical_alz(setdiff(1:n, rows),:);
Clinical_diab = Clinical_diab(setdiff(1:n, rows),:);
Clinical_hd = Clinical_hd(setdiff(1:n, rows),:);

Conditions = {Clinical_death, "death"; ...
              Clinical_cancer, "cancer"; ...
              Clinical_alz, "alzheimers"; ... 
              Clinical_diab, "diabetes"; ... 
              Clinical_hd, "heart disease"};


Bayes_norm = naiveBayesClassifier(19);
Bayes_norm.distributions{13} = 'Bern';
Bayes_norm.distributions{15} = 'Bern';
Bayes_norm.distributions{16} = 'Bern';
scores_norm_with_clinical = table();
for i = 1:length(Conditions)
    scores_norm_with_clinical =[scores_norm_with_clinical; stratifiedFoldCrossValidate(Clinical_data, Conditions{i, 1}, 5, Bayes_norm, Conditions{i, 2}, "Naive Bayes Gaussian with Clinical")];
end

Bayes_gamma = naiveBayesClassifier(size(Clinical_data, 2), "Gamm");
Bayes_gamma.distributions{10} = 'Exp';
Bayes_gamma.distributions{13} = 'Bern';
Bayes_gamma.distributions{15} = 'Bern';
Bayes_gamma.distributions{16} = 'Bern';
Bayes_gamma.distributions{17} = 'Exp';
Bayes_gamma.distributions{19} = 'Exp';

scores_gamma_with_clinical = table();
for i = 1:length(Conditions)
    scores_gamma_with_clinical =[scores_gamma_with_clinical; stratifiedFoldCrossValidate(Clinical_data, Conditions{i, 1}, 5, Bayes_gamma, Conditions{i, 2}, "Naive Bayes Gamma with Clinical")];
end

%% Conditions (holdout) 
Conditions_D = readtable('Data/OppScrData_indicator_date_filt_no_ct_no_clinic.csv');
Conditions_data = Conditions_D(:,["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "AgeAtCT", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_", "DeathIndicator", "CancerIndicator", ...
    "AlzheimersIndicator", "Type2DiabetesIndicator", "HeartFailureIndicator"]);

n  = length(Conditions_data{:,1});
[rows, ~] = find(Conditions_data{:,:} < 0);
Conditions_data = Conditions_data(setdiff(1:n, rows),:);

holdout_idx = 20:24;
Conditions = {"death", "cancer", "alzheimers", "diabetes","heart disease"};

Bayes_norm = naiveBayesClassifier(23);
Bayes_norm.distributions{13} = 'Bern';
Bayes_norm.distributions{15} = 'Bern';
Bayes_norm.distributions{16} = 'Bern';
Bayes_norm.distributions{20} = "Bern";
Bayes_norm.distributions{21} = "Bern";
Bayes_norm.distributions{22} = "Bern";
Bayes_norm.distributions{23} = "Bern";

scores_norm_with_conditions = table();

for i = 1:length(holdout_idx)
    curr_data = Conditions_data{:,setdiff(1:24, [20, holdout_idx(i)])}; %% always remove death
    training_data = Conditions_data{:, holdout_idx(i)};
    if i > 1
        Bayes_norm.num_features = 22;
        Bayes_norm.distributions = Bayes_norm.distributions(1:22);
    end
    scores_norm_with_conditions =[scores_norm_with_conditions; stratifiedFoldCrossValidate(curr_data, training_data, 5, Bayes_norm, Conditions{i}, "Naive Bayes Gaussian with Conditions")];
end
    

Bayes_gamma = naiveBayesClassifier(23, "Gamm");
Bayes_gamma.distributions{10} = 'Exp';
Bayes_gamma.distributions{13} = 'Bern';
Bayes_gamma.distributions{15} = 'Bern';
Bayes_gamma.distributions{16} = 'Bern';
Bayes_gamma.distributions{17} = 'Exp';
Bayes_gamma.distributions{19} = 'Exp';
Bayes_gamma.distributions{20} = 'Bern';
Bayes_gamma.distributions{21} = 'Bern';
Bayes_gamma.distributions{22} = 'Bern';
Bayes_gamma.distributions{23} = 'Bern';

scores_gamma_with_conditions = table();

for i = 1:length(holdout_idx)
    curr_data = Conditions_data{:,setdiff(1:24, [20, holdout_idx(i)])}; %% always remove death
    training_data = Conditions_data{:, holdout_idx(i)};
    if i > 1
        Bayes_gamma.num_features = 22;
        Bayes_gamma.distributions = Bayes_gamma.distributions(1:22);
    end
    scores_gamma_with_conditions =[scores_gamma_with_conditions; stratifiedFoldCrossValidate(curr_data, training_data, 5, Bayes_gamma, Conditions{i}, "Naive Bayes Gamma with Conditions")];
end


save("results/bayes_scores.mat")




