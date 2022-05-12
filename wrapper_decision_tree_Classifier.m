addpath('Scripts/decisionTrees/')

%%Clinical Data Only 

CT_D=readtable('Data/OppScrData_indicator_date_filt_no_ct.csv');
CT_data = CT_D(:, ["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", ...
    "VATArea_cm2_", "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", ...
    "L3SMI_cm2_m2_", "AoCaAgatston", "LiverHU_Median_"]);

CT_death = CT_D{:, "DeathIndicator"};
CT_cancer = CT_D{:, "CancerIndicator"};
CT_alz  = CT_D{:, "AlzheimersIndicator"};
CT_diab = CT_D{:, "Type2DiabetesIndicator"};
CT_hd = CT_D{:, "HeartFailureIndicator"};


n  = length(CT_death);
[rows, ~] = find(table2array(CT_data) < 0);
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
DT = decisionTreeClassifier(1, 10, false);
scores_dt = table();
for i = 1:length(Conditions)
    scores_dt = [scores_dt; balancedFoldCrossValidateDT(CT_data, Conditions{i, 1}, 5, DT,Conditions{i, 2}, "decision tree")];
end

DT_prune = decisionTreeClassifier(1, 10);
scores_dt_prune = table();
for i = 1:length(Conditions)
    scores_dt_prune = [scores_dt_prune; balancedFoldCrossValidateDT(CT_data, Conditions{i, 1}, 5, DT_prune,Conditions{i, 2}, "decision tree with pruning")]
end


%% All Data 
Clinical_D=readtable('Data/OppScrData_indicator_date_filt_no_ct_no_clinic.csv');
Clinical_data = Clinical_D(:,["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "AgeAtCT", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_"]);

Clinical_death = Clinical_D{:, "DeathIndicator"};
Clinical_cancer = Clinical_D{:, "CancerIndicator"};
Clinical_alz  = Clinical_D{:, "AlzheimersIndicator"};
Clinical_diab = Clinical_D{:, "Type2DiabetesIndicator"};
Clinical_hd = Clinical_D{:, "HeartFailureIndicator"};


n  = length(Clinical_death);
[rows, ~] = find(table2array(Clinical_data) < 0);
Clinical_data = Clinical_data(setdiff(1:n, rows),:);
Clinical_death = Clinical_death(setdiff(1:n, rows),:);
Clinical_cancer = Clinical_cancer(setdiff(1:n, rows),:);
Clinical_alz  = Clinical_alz(setdiff(1:n, rows),:);
Clinical_diab = Clinical_diab(setdiff(1:n, rows),:);
Clinical_hd = Clinical_hd(setdiff(1:n, rows),:);

Conditions = {Clinical_death, "death with clinical"; ...
              Clinical_cancer, "cancer with clinical"; ...
              Clinical_alz, "alzheimers with clinical"; ... 
              Clinical_diab, "diabetes with clinical"; ... 
              Clinical_hd, "heart disease with clinical"};

DT = decisionTreeClassifier(1, 10, false);
scores_dt_with_clinical = table();
for i = 1:length(Conditions)
    scores_dt_with_clinical = [scores_dt_with_clinical; balancedFoldCrossValidateDT(Clinical_data, Conditions{i, 1}, 5, DT,Conditions{i, 2}, "decision tree")]
end

DT_prune = decisionTreeClassifier(1, 10);
scores_dt_prune_with_clinical = table();
for i = 1:length(Conditions)
    scores_dt_prune_with_clinical = [scores_dt_prune_with_clinical; balancedFoldCrossValidateDT(Clinical_data, Conditions{i, 1}, 5, DT_prune,Conditions{i, 2}, "decision tree with pruning")]
end


%% With Conditions 
Conditions_D = readtable('Data/OppScrData_indicator_date_filt_no_ct_no_clinic.csv');
Conditions_data = Conditions_D(:,["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "AgeAtCT", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_", "DeathIndicator", "CancerIndicator", ...
    "AlzheimersIndicator", "Type2DiabetesIndicator", "HeartFailureIndicator"]);

holdout_idx = 20:24;
Conditions = {"death", "cancer", "alzheimers", "diabetes","heart disease"};

scores_dt_with_conditions = table();
DT = decisionTreeClassifier(1, 10, false);
for i = 1:length(holdout_idx)
    curr_data = Conditions_data(:,setdiff(1:24, [20, holdout_idx(i)])); %% always remove death
    training_data = Conditions_data{:, holdout_idx(i)};
    scores_dt_with_conditions =[scores_dt_with_conditions; balancedFoldCrossValidateDT(curr_data, training_data, 5, DT, Conditions{i}, "decision trees")]
end


DT_prune = decisionTreeClassifier(1, 10);
scores_dt_prune_with_conditions = table();
scores_dt_prune_with_conditions = table();
for i = 1:length(Conditions)
    curr_data = Conditions_data(:,setdiff(1:24, [20, holdout_idx(i)])); %% always remove death
    training_data = Conditions_data{:, holdout_idx(i)};
    scores_dt_prune_with_conditions = [scores_dt_prune_with_conditions; balancedFoldCrossValidateDT(curr_data, training_data, 5, DT_prune, Conditions{i}, "decision tree with pruning")]
end

save('Results/decision_tree_scores.mat')
