classdef naiveBayesClassifier
    properties
        num_features
        distributions
        params 
        p_y
    end
    methods
        function obj = naiveBayesClassifier(varargin)
            
            switch nargin
                case 1
                    obj.num_features = varargin{1};
                    X_distributions = repmat({'Norm'}, 1, obj.num_features);
                    obj.distributions = X_distributions;
                case 2
                    obj.num_features = varargin{1};
                    dists = varargin{2};
                    if length(dists) == 1
                        obj.distributions = repmat(dists, 1, obj.num_features);
                    elseif length(dists) == obj.num_features
                        obj.distributions = dists;
                    else
                        error("distribution must either have length 1 or num_features")
                    end
                case 0
                    obj.num_features = 0;
                    obj.distributions = {}; 
            end
            obj.params={};
        end


        
        
        function p = estimateParam(obj, vec, label, distribution)
           false_labels =(label == 0); 
           true_labels = (label == 1);

           switch distribution
               case 'Norm'
                   p = [mean(vec(false_labels)), var(vec(false_labels));
                        mean(vec(true_labels)),  var(vec(true_labels))];

               case 'Bern'
                   p = [mean(vec(false_labels));
                        mean(vec(true_labels))];

               case 'Exp'
                  p = [mean(vec(false_labels));
                        mean(vec(true_labels))];

               case 'Pois'
                  p = [mean(vec(false_labels));
                       mean(vec(true_labels))];
               case "Gamm"
                  gamma_fit_false = fitdist(vec(false_labels), 'Gamma');
                  gamma_fit_true = fitdist(vec(true_labels), 'Gamma'); 
                  p = [gamma_fit_false.a, gamma_fit_false.b;
                      gamma_fit_true.a, gamma_fit_true.b];
               case "Wieb"
                  wieb_fit_false = fitdist(vec(false_labels), 'Weibull');
                  wieb_fit_true = fitdist(vec(true_labels), 'Weibull'); 
                  p = [wieb_fit_false.a, wieb_fit_false.b;
                      wieb_fit_true.a, wieb_fit_true.b];
               otherwise 
                  error('Distributions must be either: Norm, Bern, Exp, Pois, Gamm, Weib')
           end
        end

        function p = computeProb(obj, vec, param, distribution)
            switch distribution
               case 'Norm'
                   p = [normpdf(vec, param(1,1), sqrt(param(1,2))), normpdf(vec, param(2,1), sqrt(param(1,2)))];
               case 'Bern'
                   p = zeros(length(vec), 2);
                   p(vec == 1, 1) = param(1);
                   p(vec == 1, 2) = param(2);
                   p(vec == 0, 1) = 1 - param(1);
                   p(vec == 0, 2) = 1 - param(2);
               case 'Exp'
                   p =[exppdf(vec, param(1)), exppdf(vec, param(2))];
               case 'Pois'
                   p = [poisspdf(vec, param(1)), poisspdf(param(2))];
               case "Gamm" 
                   p = [gampdf(vec, param(1,1), param(1,2)), gampdf(vec, param(2,1), param(2,2))]; 
               case "Weib"
                   p = [wblpdf(vec, param(1,1), param(1,2)), wblpdf(vec, param(2,1), param(2,2))]; 
                otherwise 
                   error('Distributions must be either: Norm, Bern, Exp, Pois, Gamm, Weib')
            end
        end

        function obj = train(obj, X, y)
            %%% For each variable in X Define the Distribtion of X, Given the
            %%% Distribution, the parameters are estimated for each of the options of Y
            %%% (Death), (non-Death).  The function returns a function prototype that
            %%% can be used for classification. If X_distribution is not given, then it
            %%% is assumed to be normal.
            obj.p_y = sum(y)/length(y);

            if obj.num_features == 0
                obj.num_features = size(X, 2);
                obj.distributions = repmat({'Norm'}, 1, obj.num_features);
            end

            est_params={};
            for i = 1:obj.num_features
                est_params{i} = obj.estimateParam(X(:, i ), y, obj.distributions{i}); 
            end
            obj.params = est_params;
        end

        function [pred, probs, score] = predict(obj, X_new)
            obj.p_y = 0.5;
            if isempty(obj.params)
                error('Classifier is untrained. Please train before predicting.')
            end
            %%% Estimate Probs
            for i = 1:obj.num_features
                p = obj.computeProb(X_new(:,i), obj.params{i}, obj.distributions{i});
                probs_no(:, i) = p(:, 1);
                probs_yes(:, i) = p(:, 2);
            end
            probs = [prod(probs_no, 2)*(1-obj.p_y), prod(probs_yes, 2) * obj.p_y];
            pred = probs(:,2) > probs(:, 1);
            score = probs(:,2) / probs(:,1);
        end
    end
end
       