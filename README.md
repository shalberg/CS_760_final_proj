# CS_760_final_proj
Code used for generations of results for Zhiwei Song and Spencer Halberg. Data is not included to avoid release of private information.


### Function Information
filter Data.R - Used to preprocess data from the proxided excel files. 

wrapper scripts - Each wrapper script was used to generate either result data or a plot for the final paper. 

Run in this order:
1. wrapper_naive_Bayes...
2. wrapper_decision_Tree ... 
3. wrapper_random_forest ... 
4. wrapper_plot_hist_with_dist ....
5. wrapper_compute_bio_age ....
6. wrapper_make_distrob_example ... 

### Scripts Directory: This directory contains the custom machine learning modules.

Each module is written as a matlab class (except logistic regression which we did not decide to present in our final).

Within each subfolder is the class, as well as the required k-folds, and the metric computation. 

### Results

Contains the output of each wrapper script. 
