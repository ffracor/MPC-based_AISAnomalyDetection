%% INIT
clear all
close all
clc

folder = fileparts(which("hawaii_first_example.m")); 
addpath(genpath(folder));

%% HYPERPARAMETERS, REFERENCE ROUTE, THRESHOLD

% sampling time and receding horizon
hp.N = 15;
hp.Ts = 60;

% matrix Q
hp.qx = 1;
hp.qy = 1;
hp.qv = 0;
hp.qpsi = 0;

% matrix R
hp.r1 = 0;
hp.r2 = 0;

% state boundaries (third is computed online)
hp.xl = [-1e9 -1e9 0 0 -10];
hp.xu = [1e9 1e9 7 10*pi+0.1 10];

% load reference route
load("routes_honolulu_lihue.mat")
n_rif = 6;
r = trips{n_rif, 1};

% load routes to learn the threshold J_th
n_j1 = 7; n_j2 = 39;

rj = trips{n_j1,1};
result = MPC_func(hp, r, rj);
J = result.J;

rj = trips{n_j2,1};
result = MPC_func(hp, r, rj);
J = [J; result.J];

% compute threshold J_th
Jth = max(J);

% HYPERPARAMETERS FOR KNN
epsilon = 0.05;
rt.train_x = [trips{n_j1,1}.utmX; trips{n_j2,1}.utmX];
rt.train_y = [trips{n_j1,1}.utmY; trips{n_j2,1}.utmY];

% plot of reference and train routes
figure
geoscatter(r.lat, r.lon, 25, "blue", "filled")
hold on
geoscatter(trips{n_j1,1}.lat, trips{n_j1,1}.lon, 25, "yellow",  "filled")
geoscatter(trips{n_j2,1}.lat, trips{n_j2,1}.lon, 25, [0.8500 0.3250 0.0980]	,  "filled")
legend("Reference route", "First tuning route", "Second tuning route", "interpreter", "latex")

%%

% SIMULATED ANOMALOUS ROUTE
load("simulated_route.mat")
new_route = R;

% MPC RESULTS
result = MPC_func(hp, r, new_route);
J_bool = result.J > Jth;
J_bool = [zeros(hp.N-1,1); J_bool(1:end-hp.N+1)];
geo_plot(r, new_route, J_bool)

% performance MPC
fpr_mpc = sum(J_bool == 1 & new_route.label == 0)/sum(new_route.label == 0);
fnr_mpc = sum(J_bool == 0 & new_route.label == 1)/sum(new_route.label == 1);
acc_mpc = sum(J_bool == new_route.label)/size(J_bool,1);

% CPAD results
J_bool = knn_func(rt, new_route, epsilon);
geo_plot(r, new_route, J_bool)

% performance CPAD
fpr_cpad = sum(J_bool == 1 & new_route.label == 0)/sum(new_route.label == 0);
fnr_cpad = sum(J_bool == 0 & new_route.label == 1)/sum(new_route.label == 1);
acc_cpad = sum(J_bool == new_route.label)/size(J_bool,1);

% display performance
fprintf("\t\t Accuracy \t False Positive Rate \t False Negative Rate\n")
fprintf("MPC \t %f \t %f \t\t\t\t %f\n", acc_mpc, fpr_mpc, fnr_mpc)
fprintf("CPAD \t %f \t %f \t\t\t\t %f\n", acc_cpad, fpr_cpad, fnr_cpad)

%%

% REAL ROUTE WITHOUT ANOMALIES
n = 14;
new_route = trips{n,1};

% MPC Results
result = MPC_func(hp, r, new_route);
J_bool = result.J > Jth;
J_bool = [zeros(hp.N-1,1); J_bool(1:end-hp.N+1)];
geo_plot(r, new_route, J_bool)

% CPAD Results
J_bool = knn_func(rt, new_route, epsilon);
geo_plot(r, new_route, J_bool)

%%

% REAL ROUTE WITH ANOMALIES
n = 12;
new_route = trips{n,1};

% MPC RESULTS
result = MPC_func(hp, r, new_route);
J_bool = result.J > Jth;
J_bool = [zeros(hp.N-1,1); J_bool(1:end-hp.N+1)];
geo_plot(r, new_route, J_bool)

% CPAD RESULTS 
J_bool = knn_func(rt, new_route, epsilon);
geo_plot(r, new_route, J_bool)
