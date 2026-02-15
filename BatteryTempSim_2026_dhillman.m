%% Sunstang Battery Thermal Analysis - Multi-Scenario Solver
%  Drew Hillman
%  Ref: Panasonic NCR18650B (40p30s) | Ram-Air Cooling Model

clear; clc; close all;

%% 1. System Constants (The "Fixed" Physics)
Pack.ModuleCount = 30;           
Pack.CellsPerModule = 40;        
Pack.ModuleMass = 1.94;          % kg (40 cells * 48.5g)
Pack.Cp = 950;                   % J/kg*K
Pack.Area_surf = 0.12;           % m^2
Pack.R_module = 0.875e-3;        % Ohms (Derived from 35mOhm / 40)

% Cooling Parameters (Ram Air Model)
Pack.h_static = 5;               % W/m^2K (Fans OFF / Car Stopped)
Pack.h_fans_only = 12;           % W/m^2K (Exhaust Fans ON, Car Stopped)
Pack.Ram_Factor = 1.5;           % Cooling gain per m/s of speed

%% 2. select Scenario
%  Change this string to run different tests: 'Cruise', 'Sprint', or 'HillClimb'
Target_Scenario = 'All'; 

if strcmp(Target_Scenario, 'All')
    Scenarios = {'Cruise', 'Sprint', 'HillClimb', 'Parking'};
else
    Scenarios = {Target_Scenario};
end

%% 3. Simulation Loop
%  Use a 2x2 Grid to fit all 4 scenarios nicely
figure('Name', 'Scenario Comparison', 'Color', 'w', 'Position', [100 50 1200 900]);

for s = 1:length(Scenarios)
    Scenario_Name = Scenarios{s};
    fprintf('Running Scenario: %s...\n', Scenario_Name);
    
    % --- RESET STATE VARIABLES ---
    % Critical: Clear variables from previous loop iterations so 
    % "Parking" settings don't leak into "Cruise".
    clear T_Initial_Override; 
    
    % --- A. Generate Profiles (The "Inputs") ---
    % Default Time (can be overridden by case)
    Time = 0:1:1200; 
    
    switch Scenario_Name
        case 'Cruise'
            Velocity = 16.7 * ones(size(Time));     
            Current  = 35 * ones(size(Time));     
            Title_Text = 'Nominal Cruise (60 km/h)';
            
        case 'Sprint'
            Velocity = 27.8 * ones(size(Time));     
            Current  = 120 * ones(size(Time));    
            Title_Text = 'Sprint/Overtake (100 km/h)';
            
        case 'HillClimb'
            Velocity = 8.3 * ones(size(Time));     
            Current  = 140 * ones(size(Time));    
            Title_Text = 'WORST CASE: Hill Climb (30 km/h)';
            
        case 'Parking'
            % OVERRIDE: 1 Hour duration
            Time = 0:1:3600; 
            
            Velocity = zeros(size(Time));     
            Current  = zeros(size(Time));     
            
            % Start HOT to simulate parking after a race
            T_Initial_Override = 55; 
            Title_Text = 'Static Heat Soak (Natural Convection Only)';
            
            % Derate cooling for insulated box
            Pack.h_static = 3; 
    end
    
    % --- B. The Physics Engine ---
    % Initialize Temp History
    T_nodes = zeros(Pack.ModuleCount, length(Time));
    
    % logic to handle the "Hot Start" for parking
    if exist('T_Initial_Override', 'var')
        T_nodes(:,1) = T_Initial_Override; 
    else
        T_nodes(:,1) = 25; % Default Ambient Start
    end
    
    % Create Defect Map (#15 is the bad module)
    R_map = ones(Pack.ModuleCount, 1) * Pack.R_module;
    R_map(15) = Pack.R_module * 1.3; 
    
    for t = 1:length(Time)-1
        % 1. Dynamic Cooling (Ram Air Model)
        % Note: If velocity is 0 (Parking), this reduces to h_static
        h_current = Pack.h_static + (Pack.Ram_Factor * Velocity(t));
        
        % 2. Heat Generation
        Q_gen = (Current(t)^2) .* R_map;
        
        % 3. Heat Dissipation
        Q_cool = h_current .* Pack.Area_surf .* (T_nodes(:,t) - 25);
        
        % 4. Integration
        dT_dt = (Q_gen - Q_cool) ./ (Pack.ModuleMass * Pack.Cp);
        T_nodes(:,t+1) = T_nodes(:,t) + dT_dt;
    end
    
    % --- C. Visualization ---
    % FIX: Use dynamic subplot logic. 
    % ceil(length/2) ensures we have enough rows.
    subplot(2, 2, s); 
    
    plot(Time/60, T_nodes(1,:), 'b--', 'LineWidth', 1); hold on;
    plot(Time/60, T_nodes(15,:), 'r-', 'LineWidth', 2);
    
    % Add safety line only if the scale is relevant
    yline(60, 'k--', 'Safety Limit');
    
    % Formatting
    xlabel('Time (Minutes)'); % Changed to Minutes for better readability
    ylabel('Temp (^oC)');
    title(Title_Text);
    legend('Nominal Module', 'Defect Module', 'Location', 'best');
    grid on;
    
    % Adjust axis to fit the data nicely
    axis tight;
    ylim([20 70]); % Force consistent Y-axis for easy comparison
end