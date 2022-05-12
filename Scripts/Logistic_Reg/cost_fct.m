function [J, grad] = cost_fct(theta, X, y)

J = -sum(log((1./(1+exp(-X*theta))).^y) + log((1./(1+exp(X*theta))).^(1-y)));

grad = X' * (1./(1+exp(-X*theta)) - y);

end
