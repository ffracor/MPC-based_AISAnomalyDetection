%%
clear all
close all
clc

folder = fileparts(which("hawaii_second_example.m")); 
addpath(genpath(folder));

%% HYPERPARAMETERS, REFERENCE ROUTE, THRESHOLD

% sampling time and receding horizon
hp.N = 5;
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
load("routes_honolulu_kapolei.mat")
n_rif = 78;
r = trips{n_rif, 1};

% load routes to train threshold J_th
n_j1 = 36; n_j2 = 37;

rj = trips{n_j1,1};
result = MPC_func(hp, r, rj);
J = result.J;

rj = trips{n_j2,1};
result = MPC_func(hp, r, rj);
J = [J(1:end-25); result.J(1:end-25)];

% Compute J_th value
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

% REAL ROUTE WITHOUT ANOMALIES
n = 35;
new_route = trips{n,1};

% MPC results
result = MPC_func(hp, r, new_route);
J_bool = result.J > Jth;
J_bool = [zeros(hp.N-1,1); J_bool(1:end-hp.N+1)];
geo_plot(r, new_route, J_bool)

% CPAD results
J_bool = knn_func(rt, new_route, epsilon);
geo_plot(r, new_route, J_bool)

%%

% REAL ANOMALOUS ROUTE
n = 1;
new_route = trips{n,1};

% MPC results
result = MPC_func(hp, r, new_route);
J_bool = result.J > Jth;
J_bool = [zeros(hp.N-1,1); J_bool(1:end-hp.N+1)];
geo_plot(r, new_route, J_bool)

% CPAD results 
J_bool = knn_func(rt, new_route, epsilon);
geo_plot(r, new_route, J_bool)
