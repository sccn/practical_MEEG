h = figure('units', 'normalized', 'position', [0.3370 0.4148 0.3641 0.3481]);

srate = 1000; % sampling rate of 1 kHz
time  = 0:1/srate:1; 
freq  = 1; % in Hz
amp   = 2; % amplitude, or height of the sine wave

sine_wave = amp.*sin(2*pi*freq.*time); % Note that you need the .* for point-wise vector multiplication.

plot(time,sine_wave, 'LineWidth',2)
set(gca,'ylim',[-3 3]) % this adjusts the y-axis limits for visibility
grid on;

h.Children.XAxis.FontSize = 16;
h.Children.YAxis.FontSize = 16;

h.Children.XLabel.String = 'Time (s)';
h.Children.YLabel.String = 'Amplitude';

h.Children.XLabel.FontSize = 20;
h.Children.YLabel.FontSize = 20