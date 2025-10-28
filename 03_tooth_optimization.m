% PLANETARY_GEAR_OPTIMIZATION - Two-stage planetary gearbox tooth optimization
%
% This script performs an exhaustive search through the discrete design space
% of two-stage compound planetary gearbox configurations. Each combination of
% tooth counts, modules, and pressure angles is evaluated against geometric,
% mechanical, and assembly constraints.
%
% DESIGN CONFIGURATION:
%   - Two-stage compound planetary (1.5-stage configuration)
%   - 3 planets per stage at 120° spacing
%   - Both planets on same shaft (compound planet)
%   - Input: Sun gear (stage 1)
%   - Output: Ring gear (stage 2)
%
% OUTPUT:
%   combinations - Matrix where each row is one valid design [N x 19]:
%       Column 1:  i           - Total gear ratio
%       Column 2:  i_1         - Stage 1 ratio (planet1/sun)
%       Column 3:  i_2         - Stage 2 ratio (ring/planet2)
%       Column 4:  a_lower     - Minimum center distance (mm)
%       Column 5:  a_upper     - Maximum center distance (mm)
%       Column 6:  modul_1     - Module stage 1 (mm)
%       Column 7:  modul_2     - Module stage 2 (mm)
%       Column 8:  alpha_n     - Pressure angle (degrees)
%       Column 9:  z_s         - Sun tooth count
%       Column 10: z_p1        - Planet 1 tooth count
%       Column 11: z_p2        - Planet 2 tooth count
%       Column 12: z_h         - Ring gear tooth count (stored as -z_h)
%       Column 13: x_st1_lower - Min profile shift sum stage 1
%       Column 14: x_st1_upper - Max profile shift sum stage 1
%       Column 15: x_st2_lower - Min profile shift sum stage 2
%       Column 16: x_st2_upper - Max profile shift sum stage 2
%       Column 17: sigma       - Tooth root stress ratio
%       Column 18: d_outer_1   - Outer diameter stage 1 (mm)
%       Column 19: d_outer_2   - Outer diameter stage 2 (mm)
%
% USAGE:
%   1. Adjust design parameters in the "Design Parameters" section below
%   2. Run the script: planetary_gear_optimization
%   3. Review combinations matrix for valid designs
%   4. Export selected designs to KISSsoft/KISSsys for detailed analysis
%
% REFERENCES:
%   - ISO 6336:2019 (gear load capacity calculation)
%   - ISO 53:1998 (standard basic rack tooth profile)

clear;

% ============================================================================
% DESIGN PARAMETERS
% ============================================================================

i_target = 12.2; % Target gear ratio
i_delta = 2; % Deviation in percent
i_st_delta = 30; % Stage deviation in percent

sigma_min = 0.5;

d_max = 110; % Maximum diameter of the gearbox in millimeters
d_min_RWDR = 74; % With wall thickness

s_an_min_factor = 0.2; % Minimum tooth head thickness factor; Standard: 0.3. Reduced, as it can be counteracted with head reduction
epsilon_min = 1.20; % Minimum profile coverage

alpha_n_min = 20; % Pressure angle
alpha_n_max = 20; % Pressure angle
alpha_it = 2;

d_thickness_h = 3; % Material thickness under tooth base of the ring gear
d_thickness_p = 2; % Material thickness under tooth base of the planets
d_thickness_s = 2; % Material thickness under tooth base of the sun

d_screw = 6; % Screw diameter
s_air = 1.0; % Minimum gap between gearing and wall
t_min = 1.5; % Minimum wall thickness

df_s_min = 8; % Sun shaft not too thin
da_s_max = 17; % Sun assembly through Varilip
d_p2_shaft_min = 8; % Inner diameter of HK0810 needle bearing

moduls_1 = [0.8, 0.85, 0.9, 0.95, 1.0]; % Considered modules
moduls_2 = [0.8, 0.85, 0.9, 0.95, 1.0, 1.125, 1.25]; % Considered modules

z_s_min = 13;
z_s_max = 17;

z_p1_min = 30;
z_p1_max = 50;

z_p2_min = 13;
z_p2_max = 25;

z_h_min = 45;
z_h_max = 100;

x_st1_min = 0.8;
x_st1_max = 1.0;

x_st2_min = -0.8;
x_st2_max = 0.8;

a_iteration = 0.2;
a_delta = 2.0;

planets = 3;

%----

modul_1 = 0;
modul_2 = 0;

alpha_n = 0;

a_lower = 0;
a_upper = 0;

x_st1_lower = 0;
x_st2_lower = 0;
x_st1_upper = 0;
x_st2_upper = 0;

%----

n = 1;
possible = true;
combinations = zeros(1, 19);

for q1 = 1:length(moduls_1(1, :)) % Iteration loop for module of the first stage
    
    modul_1 = moduls_1(1, q1);
    
    for q2 = 1:length(moduls_2(1, :)) % Iteration loop for module of the second stage
        
        modul_2 = moduls_2(1, q2);
        
        for z_s = z_s_min:z_s_max % Iteration loop for sun
            
            for z_p1 = z_p1_min:z_p1_max % Iteration loop for planet 1
                
                for z_p2 = z_p2_min:z_p2_max % Iteration loop for planet 2
                    
                    for z_h = z_h_min:z_h_max % Iteration loop for ring gear
                        
                        for alpha_n = alpha_n_min:alpha_it:alpha_n_max % Iteration loop for pressure angle
                            
                            possible = true;
                         
                            a_lower = 0;

                            x_st1_lower = 0;
                            x_st2_lower = 0;
                            x_st1_upper = 0;
                            x_st2_upper = 0;
                            
                            % Total gear ratio
                            i = (z_p1/z_s) * (-z_h/z_p2);
                            
                            i_1 = z_p1/z_s; % Gear ratio stage 1
                            i_2 = z_h/z_p2; % Gear ratio stage 2
                            
                            % Check difference of stage gear ratio
                            if abs(i_2) < (abs(i_1) * (1 - i_st_delta * 0.01)) || abs(i_2) > (abs(i_1) * (1 + i_st_delta * 0.01))
                               %possible = false;
                            end
                            
                            % Check gear ratio
                            if abs(i) < (i_target * (1 - i_delta * 0.01)) || abs(i) > (i_target * (1 + i_delta * 0.01))
                                possible = false;
                            end
                            
                            % Check division angle
                            if mod((z_s * z_p2 + z_p1 * (-z_h)) / (planets * gcd(z_p1, z_p2)), 1) ~= 0
                                possible = false;
                            end
                            
                            % Check if gearing pairs are coprime
                            if gcd(z_s, z_p1) ~= 1 || gcd(z_p2, z_h) ~= 1
                                possible = false;
                            end
                            
                            % Zero axis distance
                            a_d1 = modul_1 / 2 * (z_s + z_p1);
                            a_d2 = modul_2 / 2 * (z_p2 - z_h);
                            
                            a_min = (a_d1 + abs(a_d2))/2 - a_delta;
                            a_max = (a_d1 + abs(a_d2))/2 + a_delta;
                            
                            % Check axis distance difference
                            if possible && ((abs(a_d2) >= a_min && abs(a_d2) <= a_max) && (abs(a_d1) >= a_min && abs(a_d1) <= a_max))
                                
                                for a = a_min:a_iteration:a_max
                                    
                                    possible = true;
                                    
                                    alpha_t = alpha_n; % Corresponds to alpha_n, since no helix angle
                                    inv_alpha_t = involute(alpha_t);
                                    
                                    % Operating pressure angle
                                    alpha_wt1 = acosd((z_s + z_p1) * modul_1 * cosd (alpha_t) / (2*a));
                                    inv_alpha_wt1 = involute(alpha_wt1);
                                    
                                    alpha_wt2 = acosd(abs(z_p2 - z_h) * modul_2 * cosd (alpha_t) / (2*a));
                                    inv_alpha_wt2 = involute(alpha_wt2);
                                    
                                    % Profile shift sum sun - planet 1
                                    x_st1 = ((z_s + z_p1) * (inv_alpha_wt1 - inv_alpha_t)) / (2*tand(alpha_n));
                                    x1_st1 = 0;
                                    x2_st1 = 0;
                                    
                                    % Calculate profile shift sum planet 2 - ring gear
                                    x_st2 = real(((z_p2 - z_h) * (inv_alpha_wt2 - inv_alpha_t)) / (2*tand(alpha_n)));
                                    
                                    x1_st2 = x_st2;
                                    
                                    x2_st2_min = 0;
                                    x2_st2_max = x_st2;
                                    
                                    % Check profile shift sum
                                    if x_st1 < x_st1_min || x_st1 > x_st1_max
                                        possible = false;
                                    end
                                    
                                    if x_st2 < x_st2_min || x_st2 > x_st2_max
                                        possible = false;
                                    end
                                    
                                    if possible
                                        
                                        % Pitch diameter
                                        d_s = z_s * modul_1;
                                        d_p1 = z_p1 * modul_1;
                                        d_p2 = z_p2 * modul_2;
                                        d_h = z_h * modul_2;
                                        
                                        % Reference profile tooth height
                                        h_aP1 = modul_1;
                                        h_aP2 = modul_2;
                                        
                                        % Reference profile foot height
                                        h_fP1 = 1.25 * modul_1;
                                        h_fP2 = 1.25 * modul_2;
                                        
                                        k1 = a - a_d1 - modul_1 * x_st1;
                                        k2 = a - abs(a_d2) - modul_2 * x_st2;
                                        
                                        % Base circle diameter
                                        db_s = d_s * cosd(alpha_t);
                                        db_p1 = d_p1 * cosd(alpha_t);
                                        db_p2 = d_p2 * cosd(alpha_t);
                                        
                                        % Addendum circle diameter
                                        da_s = d_s + (2 * x1_st1 * modul_1) + (2 * h_aP1) + (2 * k1);
                                        da_p1 = d_p1 + (2 * x2_st1 * modul_1) + (2 * h_aP1) + (2 * k1);
                                        da_p2 = d_p2 + (2 * x1_st2 * modul_2) + (2 * h_aP2) + (2 * k2);
                                        da_h = d_h - (2 * x2_st2_min * modul_2) - (2 * h_aP2) - (2 * k2);
                                        
                                        % Dedendum circle diameter
                                        df_s = d_s + (2 * x1_st1 * modul_1) - (2 * h_fP1);
                                        df_p1 = d_p1 + (2 * x2_st1 * modul_1) - (2 * h_fP1);
                                        df_p2 = d_p2 + (2 * x1_st2 * modul_2) - (2 * h_fP2);
                                        df_h = d_h - (2 * x2_st2_max * modul_2) + (2 * h_fP2);
                                        
                                        % Profile coverage
                                        epsilon = (z_s / (2 * pi()) * (sqrt((da_s / db_s)^2 - 1) - tand(alpha_wt1))) + (z_p1 / (2 * pi()) * (sqrt((da_p1 / db_p1)^2 - 1) - tand(alpha_wt1)));
                                        
                                        % Some other strange angle
                                        alpha_at_s = acosd(db_s / da_s);
                                        alpha_at_p1 = acosd(db_p1 / da_p1);
                                        alpha_at_p2 = acosd(db_p2 / da_p2);
                                        
                                        % Tooth thickness
                                        s_t_s = modul_1 * (pi() / 2 + 2 * x1_st1 * tand(alpha_n));
                                        s_t_p1 = modul_1 * (pi() / 2 + 2 * x2_st1 * tand(alpha_n));
                                        s_t_p2 = modul_2 * (pi() / 2 + 2 * x1_st2 * tand(alpha_n));
                                        
                                        % Face tooth thickness
                                        s_at_s = da_s * (s_t_s / d_s + involute(alpha_t) - involute(alpha_at_s));
                                        s_at_p1 = da_p1 * (s_t_p1 / d_p1 + involute(alpha_t) - involute(alpha_at_p1));
                                        s_at_p2 = da_p2 * (s_t_p2 / d_p2 + involute(alpha_t) - involute(alpha_at_p2));
                                        
                                        % Tooth head thickness
                                        s_an_s = s_at_s;
                                        s_an_p1 = s_at_p1;
                                        s_an_p2 = s_at_p2;
                                        
                                        % Check that the planet gears 1 do not touch each other; Valid for three planets
                                        if da_p1 > a * cosd(30) * 2
                                            possible = false;
                                        end
                                        
                                        % Check that the planet gears 2 do not touch each other; Valid for three planets
                                        if da_p2 > a * cosd(30) * 2
                                            possible = false;
                                        end
                                        
                                        % Check minimum profile coverage
                                        if epsilon < epsilon_min
                                            %possible = false;
                                        end
                                        
                                        % Check tooth head thickness
                                        if s_an_s < s_an_min_factor * modul_1 || s_an_p1 < s_an_min_factor * modul_1 %|| s_an_p2 < s_an_min_factor * modul_2
                                            possible = false;
                                        end
                                        
                                        % Check sun's dedendum circle diameter
                                        if df_s < df_s_min
                                            possible = false;
                                        end
                                        
                                        % Check planet 2's shaft diameter for bearing
                                        if df_p2 < d_p2_shaft_min
                                            possible = false;
                                        end
                                        
                                        % Check sun's addendum circle diameter for assembly through Varilip
                                        if da_s_max < da_s
                                            possible = false;
                                        end
                                        
                                        % Check maximum diameter
                                        if d_max < da_p1 + 2 * a || d_max < df_h + 2 * d_thickness_h
                                            possible = false;
                                        end
                                        
                                        % Check installation space for screwing the planet carrier
                                        if (da_p1 + d_screw)/2 + s_air + t_min > ((a*sind(60))^2 + ((da_h - d_screw)/2 - s_air - t_min - a*cosd(60))^2)^(1/2)
                                            possible = false;
                                        end
                                        
                                        % Check installation space ring gear under RWDR
                                        if df_h + (d_thickness_h + s_air) * 2 > d_min_RWDR
                                            possible = false;
                                        end
                                        
                                        % Tooth root stress ratio at constant b/m
                                        sigma = (z_p2/z_p1) * (abs((z_s + z_p1)/(-z_h + z_p2)))^3;
                                    
                                        if sigma < sigma_min
                                            possible = false;
                                        end
                                    end
                                    
                                    if possible
                                        
                                        if a_lower == 0
                                            a_lower = a;
                                            x_st1_lower = x_st1;
                                            x_st2_lower = x_st2;
                                        end
                                        
                                        a_upper = a;
                                                                                
                                        if x_st1_lower > x_st1
                                            x_st1_lower = x_st1;
                                        end
                                        
                                        if x_st2_lower > x_st2
                                            x_st2_lower = x_st2;
                                        end
                                        
                                        if x_st1_upper < x_st1
                                            x_st1_upper = x_st1; 
                                        end
                                        
                                        if x_st2_upper < x_st2
                                            x_st2_upper = x_st2;
                                        end
                                    end
                                end
                            end
                            
                            if a_lower ~= 0
                                
                                % Entry in list
                                combinations(n, 1) = i;
                                combinations(n, 2) = i_1;
                                combinations(n, 3) = i_2;
                                combinations(n, 4) = a_lower;
                                combinations(n, 5) = a_upper;
                                combinations(n, 6) = modul_1;
                                combinations(n, 7) = modul_2;
                                combinations(n, 8) = alpha_n;
                                combinations(n, 9) = z_s;
                                combinations(n, 10) = z_p1;
                                combinations(n, 11) = z_p2;
                                combinations(n, 12) = -z_h;
                                combinations(n, 13) = x_st1_lower;
                                combinations(n, 14) = x_st1_upper;
                                combinations(n, 15) = x_st2_lower;
                                combinations(n, 16) = x_st2_upper;
                                combinations(n, 17) = sigma;
                                combinations(n, 18) = da_p1 + 2 * a_upper;
                                combinations(n, 19) = df_h + 2 * d_thickness_h;
                                
                                n = n + 1;
                            end
                        end
                    end
                end
            end
        end
    end
end

disp("finished");

function inv = involute(alpha)
inv = tand(alpha) - alpha * (pi() / 180);
end
