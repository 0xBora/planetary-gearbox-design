% DESIGN_SELECTION - Final design selection from detailed analysis results
% Reads gear analysis results (tooth geometry + safety factors) for both stages
% and identifies optimal combinations considering packaging constraints and efficiency.
%
% Input: z6_st1, z6_st2 (exported analysis files from gear software)
% Output: combinations matrix ranked by efficiency × safety factor product

clear;

st1 = readmatrix('z6_st1');
st2 = readmatrix('z6_st2');

%1 Nr.    %2 a      %3 m      %4 alp    %5 z1     %6 z2     %7 x      %8 x1     %9 x2
%10 da1   %11 da2   %12 df1   %13 df2   %14 eps   %15 SF1   %16 SF2   %17 SH1   %18 SH2   %19 mü

d_screw = 6; % Screw diameter
s_air = 1; % Minimum gap between gearing and wall
t_min = 2.0; % Minimum wall thickness

epsilon_min = 1.2; % Minimum profile coverage

d_thickness_h = 3; % Material thickness under tooth root of ring gear

d_p2_shaft_min = 8; % Inner diameter HK0810 needle bearing
da_s_max = 17;
d_min_RWDR = 74;

s_h_min = 0.6;
s_f_min = 0.6;

a_min = st1(1, 2);
a_max = st1(length(st1(:, 1)), 2);
a_it = 0.02;

combinations = zeros(10000000, 11);
c = 1;

possible = true;

for a = a_min:a_it:a_max
    
    for i = 1:length(st1(:, 1))
        
        if a == st1(i, 2)
            
            for n = 1:length(st2(:, 1))
                
                if a == st2(n, 2)
                    
                    possible = true;
                    
                    da_s = st1(i, 10);
                    da_p1 = st1(i, 11);
                    da_h = st2(n, 11);
                    
                    df_p2 = st2(n, 12);
                    df_h = st2(n, 13);
                    
                    % Check profile coverage
                    if epsilon_min > st1(i, 14) || epsilon_min > st2(n, 14)
                        possible = false;
                    end
                    
                    % Check shaft diameter planet 2 for bearing
                    if df_p2 < d_p2_shaft_min
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
                    
                    % Check addendum circle diameter sun for assembly through Varilip
                    if da_s_max < da_s
                        possible = false;
                    end
                    
                    if st1(i, 15) < s_f_min || st2(n, 15) < s_f_min
                        possible = false;
                    end
                    
                    if st1(i, 16) < s_f_min || st2(n, 16) < s_f_min
                        possible = false;
                    end
                    
                    if st1(i, 17) < s_h_min || st2(n, 17) < s_h_min
                        possible = false;
                    end
                    
                    if st1(i, 18) < s_h_min || st2(n, 18) < s_h_min
                        possible = false;
                    end
                    
                    if possible
                        
                        combinations(c, 1) = i;
                        combinations(c, 2) = n;
                        combinations(c, 3) = st1(i, 15);
                        combinations(c, 4) = st1(i, 17);
                        combinations(c, 5) = st1(i, 16);
                        combinations(c, 6) = st1(i, 18);
                        combinations(c, 7) = st2(n, 15);
                        combinations(c, 8) = st2(n, 17);
                        combinations(c, 9) = st2(n, 16);
                        combinations(c, 10) = st2(n, 18);
                        combinations(c, 11) = st1(i, 19) * st2(n, 19);
                        
                        c = c + 1;
                    end
                end
            end
        end
    end
end

bestRating = 0;

for k = 1:c
    if bestRating < combinations(k, 11)
        
        bestRating = combinations(k, 11);
        
        bestCombination(1, 1) = st1(combinations(k, 1), 2); % Center distance
        bestCombination(1, 2) = st1(combinations(k, 1), 3); % Module 1
        bestCombination(1, 3) = st2(combinations(k, 2), 3); % Module 2
        bestCombination(1, 4) = st1(combinations(k, 1), 4); % Alpha 1
        bestCombination(1, 5) = st2(combinations(k, 2), 4); % Alpha 2
        bestCombination(1, 6) = st1(combinations(k, 1), 5); % Sun
        bestCombination(1, 7) = st1(combinations(k, 1), 6); % Planet 1
        bestCombination(1, 8) = st2(combinations(k, 2), 5); % Planet 2
        bestCombination(1, 9) = st2(combinations(k, 2), 6); % Ring gear
        bestCombination(1, 10) = st1(combinations(k, 1), 8); % Profile shift stage 1 x1
        bestCombination(1, 11) = st1(combinations(k, 1), 9); % Profile shift stage 1 x2
        bestCombination(1, 12) = st2(combinations(k, 2), 8); % Profile shift stage 2 x1
        bestCombination(1, 13) = st2(combinations(k, 2), 9); % Profile shift stage 2 x2
        bestCombination(1, 14) = combinations(k, 3); % Bending safety factor sun
        bestCombination(1, 15) = combinations(k, 4); % Contact safety factor sun
        bestCombination(1, 16) = combinations(k, 5); % Bending safety factor planet 1
        bestCombination(1, 17) = combinations(k, 6); % Contact safety factor planet 1
        bestCombination(1, 18) = combinations(k, 7); % Bending safety factor planet 2
        bestCombination(1, 19) = combinations(k, 8); % Contact safety factor planet 2
        bestCombination(1, 20) = combinations(k, 9); % Bending safety factor ring gear
        bestCombination(1, 21) = combinations(k, 10); % Contact safety factor ring gear 
        bestCombination(1, 22) = combinations(k, 11); % Efficiency
    end
end
