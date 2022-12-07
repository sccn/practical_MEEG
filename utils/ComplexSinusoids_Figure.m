h = figure('units', 'normalized', 'position',[0.1547 0.3852 0.6656 0.4491] );

cla;
freq = 3;
fs = 1000;
ts = 0:1/fs:5;

y = exp(1i*(2*pi*freq*ts));

subplot(2, 1, 1);

plot3(ts,real(y), imag(y),'r','LineWidth',2);
hold on;

plot3(10.1*ones(size(ts)),real(y), imag(y),'y','LineWidth',2);
plot3(ts,1.1*ones(size(ts)),imag(y),'k','LineWidth',1);
plot3(ts,real(y),-1.1*ones(size(ts)),'k','LineWidth',1);

xlim([0 5]);
ylim([-1 1.1]);
zlim([-1.1 1]);


grid on;
xlabel('Time (s)');
zlabel('Imaginary Part');
ylabel('Real Part');
% axis('square');
view(-5,32);

 h.Children(1).XAxis.FontSize = 16;
 h.Children(1).YAxis.FontSize = 16;
 h.Children(1).ZAxis.FontSize = 16;
 
 subplot(2,1,2)
 plot(ts,real(y),'k','LineWidth',1)
 
 grid on;
 xlabel('Time (s)');
 ylabel('Real Part');
 
 h.Children(1).XAxis.FontSize = 16;
 h.Children(1).YAxis.FontSize = 16;

