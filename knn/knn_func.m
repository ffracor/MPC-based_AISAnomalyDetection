function [J_bool] = knn_func(rt, route_test, epsilon)
% Function that evaluates one route using the CPAD algorithm
alpha = [];

test_x = route_test.utmX;
test_y = route_test.utmY;
T = size(test_x,1);
k = 1;
ris = zeros(T,1);

for t = 1:T

    x = test_x(t);
    y = test_y(t);
    d = sqrt((rt.train_x - x).^2 + (rt.train_y - y).^2);
    new_alpha = sum(mink(d,k));
    p_y = 0;

    if t > 1
        p_y = sum(alpha >= new_alpha)/(size(alpha,1)+1);
    
        if p_y < epsilon
            ris(t) = 1;
        end
    end

    alpha = [alpha; new_alpha];
end

J_bool = ris;

end

