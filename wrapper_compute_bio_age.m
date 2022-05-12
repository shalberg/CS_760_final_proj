addpath('Scripts/KnnEstimator/')
rng(2022)

%% CT data only 
CT_D=readtable('Data/OppScrData_indicator_date_filt_no_ct.csv');
CT_data = table2array(CT_D(:, ["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", ...
    "VATArea_cm2_", "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", ...
    "L3SMI_cm2_m2_", "AoCaAgatston", "LiverHU_Median_"]));
CT_age = CT_D.AgeAtCT;

CT_death = table2array(CT_D(:, "DeathIndicator"));
CT_cancer = table2array(CT_D(:, "CancerIndicator"));
CT_alz  = table2array(CT_D(:, "AlzheimersIndicator"));
CT_diab = table2array(CT_D(:, "Type2DiabetesIndicator"));
CT_hd = table2array(CT_D(:, "HeartFailureIndicator"));

CT_has_cond = CT_death | CT_cancer | CT_alz | CT_diab | CT_hd; 

n  = length(CT_age);
[rows, ~] = find(CT_data < 0);
CT_data = CT_data(setdiff(1:n, rows), :);
CT_age = CT_age(setdiff(1:n, rows));
CT_death = logical(CT_death(setdiff(1:n, rows)));
CT_has_cond = CT_has_cond(setdiff(1:n, rows), :);


tsne_est =tsneEstimator();
knn_est_unweighted = knnEstimator(10, "euclidean");
knn_est_weighted = knnEstimator(10, "euclidean", true);

tsne_est = tsne_est.train(CT_data);
knn_est_unweighted = knn_est_unweighted.train(CT_data);
knn_est_weighted = knn_est_weighted.train(CT_data);

embedding = tsne_est.embedding;

pred_age_tsne = tsne_est.predict(CT_age);
pred_age_knn_unweighted = knn_est_unweighted.predict(CT_age);
pred_age_knn_weighted = knn_est_weighted.predict(CT_age);


figure(1)
clf
t= tiledlayout(2, 2);
title(t, "CT Data Only")
colorbar

nexttile()
scatter(embedding(:,1),embedding(:,2), 5, CT_age, "filled")
title("Actual Age")
c = caxis;
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];


nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_tsne, "filled")
title("Biological Age computed via a Lowess Regression")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];


nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_knn_unweighted, "filled")
title("Biological Age computed via a KNN Estimation (unweighted)")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];

nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_knn_weighted, "filled")
title("Biological Age computed via a KNN Estimation (weighted)")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];
c = colorbar();
c.Layout.Tile='east';
c.Label.String= "Age";
c.FontSize = 14;

saveas(gcf, "Results/CT_data_bio_age.png")
age_diff_tsne_CT = pred_age_tsne - CT_age;
age_diff_knn_unweighted_CT = pred_age_knn_unweighted - CT_age;
age_diff_knn_weighted_CT =pred_age_knn_weighted - CT_age;


%% With Clinical Data 
Clinical_D = readtable('Data/OppScrData_indicator_date_filt_no_ct_no_clinic.csv');
Clinical_data = table2array(Clinical_D(:,["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_"]));
Clinical_age = Clinical_D{:,"AgeAtCT"};

Clinical_death = table2array(Clinical_D(:, "DeathIndicator"));
Clinical_cancer = table2array(Clinical_D(:, "CancerIndicator"));
Clinical_alz  = table2array(Clinical_D(:, "AlzheimersIndicator"));
Clinical_diab = table2array(Clinical_D(:, "Type2DiabetesIndicator"));
Clinical_hd = table2array(Clinical_D(:, "HeartFailureIndicator"));

Clinical_has_cond = Clinical_death | Clinical_cancer | Clinical_alz | Clinical_diab | Clinical_hd;

n  = length(Clinical_data);
[rows, ~] = find(Clinical_data < 0);
Clinical_data = Clinical_data(setdiff(1:n, rows),:);
Clinical_age = Clinical_age(setdiff(1:n, rows),:);
Clinical_death = Clinical_death(setdiff(1:n, rows),:);
Clinical_has_cond = Clinical_has_cond(setdiff(1:n, rows), :);

tsne_est = tsne_est.train(Clinical_data);
knn_est_unweighted = knn_est_unweighted.train(Clinical_data);
knn_est_weighted = knn_est_weighted.train(Clinical_data);

embedding = tsne_est.embedding;



pred_age_tsne = tsne_est.predict(Clinical_age);
pred_age_knn_unweighted = knn_est_unweighted.predict(Clinical_age);
pred_age_knn_weighted = knn_est_weighted.predict(Clinical_age);


figure(2)
t=tiledlayout(2,2);
title(t, "CT and Clinical Data")
clf 

nexttile()
scatter(embedding(:,1),embedding(:,2), 5, Clinical_age, "filled")
title("Actual Age")
c = caxis;
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];


nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_tsne, "filled")
title("Biological Age computed via a Lowess Regression")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];


nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_knn_unweighted, "filled")
title("Biological Age computed via a KNN Estimation (unweighted)")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];

nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_knn_weighted, "filled")
title("Biological Age computed via a KNN Estimation (weighted)")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];
c = colorbar();
c.Layout.Tile='east';
c.Label.String= "Age";
c.FontSize = 14;

saveas(gcf, "Results/Clinical_data_bio_age.png")
age_diff_tsne_Clin = pred_age_tsne - Clinical_age;
age_diff_knn_unwieghted_Clin = pred_age_knn_unweighted - Clinical_age;
age_diff_knn_weighted_Clin =pred_age_knn_weighted - Clinical_age;


%% Conditions 

Conditions_D = readtable('Data/OppScrData_indicator_date_filt_no_ct_no_clinic.csv');
Conditions_data = table2array(Conditions_D(:,["L1_HU_BMD", "TATArea_cm2_", "TotalBodyAreaEA_cm2_", "VATArea_cm2_", ...
    "SATArea_cm2_", "VAT_SATRatio", "MuscleHU", "MuscleArea_cm2_", "L3SMI_cm2_m2_", ...
    "AoCaAgatston", "LiverHU_Median_", "BMI", "Sex", "Tobacco", ...
    "AlcoholAbuseIndicator", "FRS10_yearRisk___", "FRAX10yFxProb_Orange_w_DXA_", ...
    "FRAX10yHipFxProb_Orange_w_DXA_", "CancerIndicator", "AlzheimersIndicator", ...
    "Type2DiabetesIndicator", "HeartFailureIndicator"]));
Conditions_death = table2array(Clinical_D(:, "DeathIndicator"));
Conditions_age = Clinical_D{:,"AgeAtCT"};

n  = length(Conditions_data);
[rows, ~] = find(Conditions_data < 0);
Conditions_data = Conditions_data(setdiff(1:n, rows),:);
Conditions_age = Conditions_age(setdiff(1:n, rows),:);
Conditions_death = Conditions_death(setdiff(1:n, rows), :);

tsne_est = tsne_est.train(Conditions_data);
knn_est_unweighted = knn_est_unweighted.train(Conditions_data);
knn_est_weighted = knn_est_weighted.train(Conditions_data);

embedding = tsne_est.embedding;



pred_age_tsne = tsne_est.predict(Conditions_age);
pred_age_knn_unweighted = knn_est_unweighted.predict(Conditions_age);
pred_age_knn_weighted = knn_est_weighted.predict(Conditions_age);

figure(3)
t = tiledlayout(2,2);
title(t, "CT and Clinical Data with Condition Indicators")
clf 

nexttile()
scatter(embedding(:,1),embedding(:,2), 5, Conditions_age, "filled")
title("Actual Age")
c = caxis;
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];


nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_tsne, "filled")
title("Biological Age computed via a Lowess Regression")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];


nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_knn_unweighted, "filled")
title("Biological Age computed via a KNN Estimation (unweighted)")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];

nexttile()
scatter(embedding(:,1),embedding(:,2), 5, pred_age_knn_weighted, "filled")
title("Biological Age computed via a KNN Estimation (weighted)")
caxis(c);
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];
c = colorbar();
c.Layout.Tile='east';
c.Label.String= "Age";
c.FontSize = 14;
saveas(gcf, "Results/Conditions_data_bio_age.png")

age_diff_tsne_Cond = pred_age_tsne - Conditions_age;
age_diff_knn_unwieghted_Cond = pred_age_knn_unweighted - Conditions_age;
age_diff_knn_weighted_Cond =pred_age_knn_weighted - Conditions_age;

save('predict_bio_age.mat')

clf
plot(embedding(~Clinical_death, 1), embedding(~Clinical_death, 2), '.b')
hold on
plot(embedding(logical(Clinical_death), 1), embedding(logical(Clinical_death), 2), '.r')
l=legend("Alive", "Dead")
ax=gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.TickLength = [ 0 0];
ax.FontSize = 14;

saveas(gcf, 'Results/Conditons_death.png')








