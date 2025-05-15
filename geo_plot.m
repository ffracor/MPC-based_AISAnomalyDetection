function [] = geo_plot(r, route, J_bool_mpc)
%GEO_PLOT Summary of this function goes here
%   Detailed explanation goes here
figure

title("MPC Aomaly Detection")
geoscatter(r.lat, r.lon, 25, "blue", "filled")
hold on
geoscatter(route.lat(J_bool_mpc == 1), route.lon(J_bool_mpc == 1), 25, "red", "filled")
geoscatter(route.lat(J_bool_mpc == 0), route.lon(J_bool_mpc == 0), 25, "green", "filled")
legend("Reference route", "Test route: anomaly detected", "Test route: no anomaly detected", "Interpreter", "Latex")


end

