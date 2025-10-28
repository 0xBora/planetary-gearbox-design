% CREATE_LOAD_SPECTRUM - Convert load histogram to normalized spectrum
% Converts binned race data to normalized load spectrum for gear analysis software.
% Includes scaling factors for motor/wheel specification changes.
%
% Input: loads matrix (from 01_create_loads.m)
% Output: loadspectrum [frequency, relative_torque, relative_speed]

loadspectrum = zeros(length(find(loads)), 3);

c = 1;

% Wheel radius parameters (meters)
r_old = 0.225;  % Previous wheel size
r_new = 0.196;  % New wheel size

% Motor parameters
n_old = 20000;  % Previous motor max speed (rpm)
T_old = 21;     % Previous motor max torque (Nm)

n_new = 20000;  % New motor max speed (rpm)
T_new = 29.1;   % New motor max torque (Nm)

% Gearbox ratios
i_old = 14.557;  % Previous gearbox ratio
i_new = 12.2;    % New gearbox ratio

for i = 1:length(speeds(1, :))
    
    for n = 1:length(torques(1, :))
        
        if loads(i, n) ~= 0
            
            loadspectrum(c, 3) = speeds(1, i)/maximum_speed;
            loadspectrum(c, 2) = torques(1, n)/positive_torque;
            %loadspectrum(c, 3) = ((speeds(1, i) / i_old) * i_new * (r_old / r_new)) / n_new; % Scaling for new motor/wheel
            %loadspectrum(c, 2) = (torques(1, n) * (i_old / i_new) * (r_new / r_old)) / T_new; % Scaling for new motor/wheel
            loadspectrum(c, 1) = loads(i, n)/arrayLength;
            c = c + 1;  
        end
    end
end

