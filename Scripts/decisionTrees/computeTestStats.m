function scores = computeTestStats(T, P, label, classifier_id)
    confusion_matrix = [sum( T(T == 1) &  P(T == 1)), sum( T(T == 1) & ~P(T == 1));
                        sum(~T(T == 0) &  P(T == 0)), sum( ~T(T == 0) &  ~P(T == 0))];
    prec = confusion_matrix(1,1)/ ( confusion_matrix(1,1) +confusion_matrix(2,1));
    rec = confusion_matrix(1,1)/(confusion_matrix(1,1) + confusion_matrix(1,2));

    f_1_score = harmmean([prec,rec]);
    f_2_score = (1 +4)* (prec * rec)/(4*prec + rec);
    accuracy = (confusion_matrix(1,1) + confusion_matrix(2,2))/sum(confusion_matrix, 'all');
    b_accuracy = (rec + (confusion_matrix(2, 2)/(confusion_matrix(2, 2) + confusion_matrix(2, 1))))/2;
    
    scores = table( classifier_id, label, prec, rec, f_1_score, f_2_score, accuracy, b_accuracy);
end

    



    



    

