% CREATE_LOADS - Bin race telemetry into load histogram
% Takes synchronized torque/speed data from race logs and creates
% a 2D histogram for load spectrum analysis.
%
% Input: RL_Torque_sync, RL_Velocity_sync (from workspace)
% Output: loads matrix (speed bins × torque bins)

negative_torque = -21; %Nm
positive_torque = 21; %Nm
minimum_speed = 0; %U/min
maximum_speed = 20000; %U/min

arrayLength = length(RL_Torque_sync);

torque_intervall = 1; %Nm
speed_intervall = 1000; %U/min

speeds = minimum_speed:speed_intervall:maximum_speed;
torques = negative_torque:torque_intervall:positive_torque;

loads = zeros(length(speeds), length(torques));

for i = 1:arrayLength

    T = RL_Torque_sync(i, 1);
    n = RL_Velocity_sync(i, 1);
    
    x = find(torques >= T - (torque_intervall/2), 1, "first");
    y = find(speeds >= n - (speed_intervall/2), 1, "first");
    
    loads(y, x) = loads(y, x) + 1;
end
