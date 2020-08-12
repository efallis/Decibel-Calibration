clc;
close all;

% Navigate to location of all files
cd ''


% Defines
PLOT_NUM = 3;

% Configuration
mics = {'rec_inv', 'rec_pui', 'rec_st_analog', 'rec_st_embedded', 'rec_st_external'};
%mics = {'rec_st_embedded'};
names = {'InvenSense (Analog)', 'PUI (Analog)', 'ST (Analog)', 'ST (Digital Embedded)', 'ST (Digital External)'};
start = [3.16 3.20 2.68 2.92 2.70];
%start = [2.92];
startPhy = 3;

% Variables
phy = csvread('phyphox.csv',2,0);


% Trim the array to 
i = 1;
while phy(i,1) < startPhy
    i = i + 1;
end

phy = phy(i:end,:);

i = length(phy)-1;
while phy(i,1) > startPhy + 160
    i = i - 1;
end

phy = phy(1:i,:);

phy(:,1) = phy(:,1) - startPhy;

x_phy = phy(:,1);
%x_phy = x_phy - startPhy;   % Normalize start time

y_phy = phy(:,2);

x_mic_normal = x_phy;
y_mic_normal = zeros(length(x_mic_normal), 1);


% Loop through mics
for i = 1:length(mics)
    figure('Name', char(names(i)))
    title(mics(i))
    
    [y_mic, Fs_mic] = audioread(char(strcat('combined/recording/', mics(i), '.wav')));
    y_mic = abs(y_mic(:,1)); % Only take real magnitude values
    
    y_mic = y_mic(round(start(i)*Fs_mic):round((start(i) + 160)*Fs_mic));  % Only take the relevant 160 seconds
        
    % Average every 0.2 seconds, 160s * 5S = 800
    for j = 3:length(x_mic_normal)-2
            % Get time frame in terms of seconds
            timeStart = x_phy(j - 1);
            timeEnd = x_phy(j);
            
            %disp(timeStart)
            %disp(timeEnd)
            
            % Get time frame in terms of samples
            sampleStart = round(timeStart*Fs_mic + 1);
            sampleEnd = round(timeEnd*Fs_mic);
            
            %disp(sampleStart)
            %disp(sampleEnd)
            
            % Average points for the decimation
            y_mic_normal(j) = mean(y_mic(sampleStart:sampleEnd));
            %disp(y_mic(sampleStart:sampleEnd));
    end
    
    %disp(y_mic_normal);
    
    %plot_raw(y_mic, Fs_mic);
    %hold on
    %plot(x_mic_normal, y_mic_normal,'r');
    %hold off
    %set(gca, 'YLim',[0 0.25]);
    
    %figure('Name', char(names(i)))
    %plot(x_mic_normal, y_mic_normal*1200 + 30,'r');
   % hold on
    %plot(x_phy, y_phy);
   % hold off
    
    %figure('Name', char(names(i)))
    f = fit(y_mic_normal, y_phy, 'exp2');
    plot(f, y_mic_normal, y_phy);
    hold on
    %fit = polyfit(y_mic_normal, y_phy, 6);
    %f = fit(y_mic_normal, y_phy, 'exp1');
    disp(names(i));
    disp(f);
    disp('');
    %x2 = linspace(min(y_mic_normal), max(y_mic_normal), 1000);
    %y1 = polyval(f, x2);
    %plot(x2,y1);
    hold off
    
    %disp(strcat(char(length(y_phy)), length(y_mic_normal)));
    %disp(length(y_phy));
    %disp(length(y_mic_normal));
    
    %y_mic_96000 = resample(y_mic_normal,size(,Fs_mic);  % Decimate
    
    
    %set(gcf, 'Position', [0, 50, 1275, 1300])
    
    %correlation(end) = sum(correlation(1:end-1));    % Last row is the sum
    %disp(char(strcat(names(i), ': ', mat2str(correlation))));
end

function plot_raw(y, Fs)
    t = (1:size(y))/Fs;
    plot(t, y);
    grid on
    set(gca, 'fontsize', 12);
    set(findall(gca, 'Type', 'Line'), 'LineWidth', 1.5);
    xlabel('Time (s)')
    ylabel('Amplitude')
    set(gca, 'XLim',[0 40]);
    set(gca, 'YLim',[-1 1]);
end
