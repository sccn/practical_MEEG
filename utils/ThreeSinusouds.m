%%%

h = figure('units', 'normalized', 'position',[0.1547 0.2389 0.5250 0.5954]);

srate = 1000; % sampling rate of 1 kHz
time  = 0:1/srate:5; 

%
subplot(3,1,1);

freq  = 1; % in Hz
amp   = 2; % amplitude, or height of the sine wave

sine_wave = amp.*sin(2*pi*freq.*time); % Note that you need the .* for point-wise vector multiplication.

plot(time,sine_wave, 'LineWidth',2)
set(gca,'ylim',[-3 3]) % this adjusts the y-axis limits for visibility
grid on;


%
subplot(3,1,2)

freq  = 3; % in Hz
amp   = 5; % amplitude, or height of the sine wave

sine_wave = amp.*sin(2*pi*freq.*time); % Note that you need the .* for point-wise vector multiplication.

plot(time,sine_wave, 'LineWidth',2)
set(gca,'ylim',[-6 6]) % this adjusts the y-axis limits for visibility
grid on;

%
subplot(3,1,3)

freq  = 10; % in Hz
amp   = 1; % amplitude, or height of the sine wave

sine_wave = amp.*sin(2*pi*freq.*time); % Note that you need the .* for point-wise vector multiplication.

plot(time,sine_wave, 'LineWidth',2)
set(gca,'ylim',[-2 2]) % this adjusts the y-axis limits for visibility
grid on;

%

h.Children(1).YAxis.FontSize = 16;
h.Children(2).YAxis.FontSize = 16;
h.Children(3).YAxis.FontSize = 16;
h.Children(1).XAxis.FontSize = 16;

h.Children(2).XLabel.String = '';
h.Children(3).XLabel.String = '';


h.Children(2).XTickLabel = '';
h.Children(3).XTickLabel = '';

h.Children(1).XLabel.String = 'Time (s)';
h.Children(2).YLabel.String = 'Amplitude';

h.Children(1).XLabel.FontSize = 20;
h.Children(2).YLabel.FontSize = 20


%% Time and frequency domain representation
%% Figure 11.4 Cohen

time=-1:1/srate:1;

% create three sine waves
s1 = sin(2*pi*3*time);
s2 = 0.5*sin(2*pi*8*time);
s3 = s1+s2;

% plot the sine waves
h = figure('units', 'normalized', 'position',[0.1547 0.2389 0.5250 0.5954]);

for i=1:3
    subplot(2,3,i)
    
    % plot sine waves, using the eval command (evaluate the string)
    eval([ 'plot(time,s' num2str(i) ', ''LineWidth'',2)' ]);
    set(gca,'ylim',[-1.6 1.6],'ytick',-1.5:.5:1.5)
    
    ax = gca;
    if i == 2 || i == 3
        ax.YTickLabel = '';
    end
    ax.FontSize = 16
    
    if i ==2
        ax.XLabel.String = 'Time (s)';
    end
   
    
    % plot power
    subplot(2,3,i+3)
    f  = eval([ 'fft(s' num2str(i) ')/length(time)' ]);
    hz = linspace(0,srate/2,floor(length(time)/2)+1);
    bar(hz,abs(f(1:length(hz))*2))
    set(gca,'xlim',[0 11],'xtick',0:10,'ylim',[0 1.2])
   
    ax = gca;
    ax.XTick = [0:2:10]
    ax.FontSize = 16
    
    if i == 2 || i == 3
        ax.YTickLabel = '';
    end
    if i ==2
        ax.XLabel.String = 'Frequency (Hz)';
    end
    
    if i ==1
        ax.YLabel.String = 'Amplitude';
    end
    
end


