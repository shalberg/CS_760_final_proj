### Clean Project Data
library(tidyverse)
library(readxl)
library(xlsx)

proj_Data <- read_excel("OppScrData.xlsx")

proj_Data <- proj_Data %>%
  mutate(`BMI >30`=as.integer(`BMI >30` == "Y")) %>%
  mutate(Sex = as.integer(Sex == 'Male')) %>%
  mutate(Tobacco = as.integer(Tobacco == "Yes")) %>%
  mutate(`Alcohol abuse Indicator` = as.integer(!is.na(`Alcohol abuse`)), .before = `Alcohol abuse`) %>%
  mutate(`Met Sx` = as.integer(`Met Sx` == "Y")) %>%
  mutate(`Death Indicator` = as.integer(!is.na(`DEATH [d from CT]`)), .before = `DEATH [d from CT]`) %>%
  mutate(`CVD Indicator` = as.integer(!is.na(`CVD DX`)), .before = `CVD DX`) %>%
  mutate(`Heart failure Indicator` = as.integer(!is.na(`Heart failure DX`)), .before =`Heart failure DX`) %>% 
  mutate(`MI Indicator` = as.integer(!is.na(`MI DX`)), .before = `MI DX`) %>%
  mutate(`Type 2 Diabetes Indicator` = as.integer(!is.na(`Type 2 Diabetes DX`)), .before = `Type 2 Diabetes DX`) %>%
  mutate(`Fracture Indicator`= as.integer(!is.na(`Femoral neck fracture DX`) | !is.na(`Unspec femoral fracture DX`) 
                                          |!is.na(`Forearm fracture DX`) | !is.na(`Humerus fracture DX`)
                                          |!is.na(`Pathologic fracture DX`)), .before = `Femoral neck fracture DX`)
  proj_Data$`FRS 10-year risk (%)`<- replace(proj_Data$`FRS 10-year risk (%)`, proj_Data$`FRS 10-year risk (%)` == "X" , NA)
  
  
  proj_Data <- proj_Data %>%
  filter(`Fracture Indicator` == 1) %>%
  gather(key = "Fracture_type", value = "Fracture_Time" ,c(`Femoral neck fracture DX Date [d from CT]`, 
                                              `Unspec femoral fracture DX Date [d from CT]`,
                                              `Forearm fracture DX Date [d from CT]`,
                                              `Humerus fracture DX Date [d from CT]`,
                                              `Pathologic fracture DX Date [d from CT]`)) %>%
  group_by(`Record ID`) %>%
  mutate(`First fracture time` = min(Fracture_Time, na.rm = TRUE)) %>% 
  spread(Fracture_type, Fracture_Time) %>% 
  select(`Record ID`, `First fracture time`) %>%
  right_join(proj_Data, by = "Record ID")
  proj_Data <- proj_Data %>% relocate(`First fracture time`, .after = `Fracture Indicator`)
  
  proj_Data <- proj_Data %>%
    mutate(`Alzheimers Indicator` = as.integer(!is.na(`Alzheimers DX`)), .before = `Alzheimers DX`) %>%
    mutate(`Cancer Indicator` = as.integer(!is.na(`Primary Cancer Site`)), .before = `Primary Cancer Site`) 
  
  proj_Data_indicator_date <- proj_Data %>%
    select(`Record ID`, `Visit ID`, `PT ID`, `Clinical F/U interval  [d from CT]`,
           BMI, `BMI >30`, Sex, `Age at CT`, Tobacco, `Alcohol abuse Indicator`, 
           `FRS 10-year risk (%)`, `FRAX 10y Fx Prob (Orange-w/ DXA)`,
           `FRAX 10y Hip Fx Prob (Orange-w/ DXA)`, `Met Sx`, `Death Indicator`, `DEATH [d from CT]`,
           `CVD Indicator`, `CVD DX Date [d from CT]`, `Heart failure Indicator`,
           `Heart failure DX Date [d from CT]`, `MI Indicator`, `MI DX Date [d from CT]`, 
           `Type 2 Diabetes Indicator`, `Type 2 Diabetes DX Date [d from CT]`, `Fracture Indicator`, `First fracture time`, 
           `Alzheimers Indicator`, `Alzheimers DX Date [d from CT]`, `Cancer Indicator`,
           `Primary Cancer Dx [d from CT]`, L1_HU_BMD, `TAT Area (cm2)`, `Total Body                Area EA (cm2)`, `VAT Area (cm2)`, `SAT Area (cm2)`, 
           `VAT/SAT     Ratio`, `Muscle HU`, `Muscle Area (cm2)`, `L3 SMI (cm2/m2)`, `AoCa        Agatston`, `Liver HU    (Median)`)
  
  proj_Data_indicator_date_filt_no_ct <- proj_Data_indicator_date %>% 
    mutate(`Missing CT` =  is.na(L1_HU_BMD) | is.na(`TAT Area (cm2)`) 
                          |is.na(`Total Body                Area EA (cm2)`)
                          |is.na(`VAT Area (cm2)`) | is.na(`SAT Area (cm2)`)
                          |is.na(`VAT/SAT     Ratio`) | is.na(`Muscle HU`) 
                          |is.na(`Muscle Area (cm2)`) | is.na(`L3 SMI (cm2/m2)`)
                          |is.na(`AoCa        Agatston`) | is.na(`Liver HU    (Median)`), .before = `L1_HU_BMD`) %>%
    filter(`Missing CT` == FALSE)
  
  proj_Data_indicator_date_filt_no_ct <- proj_Data_indicator_date_filt_no_ct %>% mutate(`FRS 10-year risk (%)` = str_replace(`FRS 10-year risk (%)`, '>30%', "0.30")) %>% mutate(`FRS 10-year risk (%)` = str_replace(`FRS 10-year risk (%)`, '<1%', "0.00"))
  proj_Data_indicator_date_filt_no_ct[proj_Data_indicator_date_filt_no_ct == '_'] <- NA
  
  proj_Data_indicator_date_filt_no_ct_no_clinic <- proj_Data_indicator_date_filt_no_ct %>% 
    mutate(`Missing Clinic` = is.na(`BMI`) 
           |is.na(`BMI >30`)
           |is.na(`Sex`)
           |is.na(`Age at CT`) 
           |is.na(Tobacco) | is.na(`Alcohol abuse Indicator`)
           |is.na(`FRS 10-year risk (%)`) | is.na(`FRAX 10y Fx Prob (Orange-w/ DXA)`) | is.na(`FRAX 10y Hip Fx Prob (Orange-w/ DXA)`), .before = BMI) %>%
    filter(`Missing Clinic` == FALSE)

save(list=c("proj_Data", "proj_Data_indicator_date", "proj_Data_indicator_date_filt_no_ct"), file="proj_Data.RData")
write.csv(proj_Data_indicator_date, "OppScrData_indicator_date.csv")
write.csv(proj_Data_indicator_date_filt_no_ct, "OppScrData_indicator_date_filt_no_ct.csv")
write.csv(proj_Data_indicator_date_filt_no_ct_no_clinic, "OppScrData_indicator_date_filt_no_ct_no_clinic.csv")
  
  
    
