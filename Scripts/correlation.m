data = readtable("OppScrData_indicator_date_filt_no_ct.csv");

L1_HU_BMD = correlations(data, 33);
TAT_Area = correlations(data, 34);
%Total_Body_Area_EA = correlations(data, 35);
VAT_Area = correlations(data, 35);
SAT_Area = correlations(data, 36);
VAT_SAT_Ratio = correlations(data, 37);
Muscle_HU = correlations(data, 38);
Muscle_Area = correlations(data, 39);
L3_SMI = correlations(data, 40);
AoCa_Agatston = correlations(data, 41);
Liver_HU = correlations(data, 42);

disp(L1_HU_BMD);
disp(TAT_Area);
%disp(Total_Body_Area_EA);
disp(VAT_Area);
disp(SAT_Area);
disp(VAT_SAT_Ratio);
disp(Muscle_HU);
disp(Muscle_Area);
disp(L3_SMI);
disp(AoCa_Agatston);
disp(Liver_HU);

function corr = correlations(data, n)
    death = data{:,30};

    CT_column = data{:, n};

    death_mean = mean(death);
    CT_column_mean = mean(CT_column);

    corr = sum((death - death_mean).*(CT_column - CT_column_mean)) ...
    / (sum((death - death_mean).^2)^0.5 ...
    * sum((CT_column - CT_column_mean).^2)^0.5);
end



