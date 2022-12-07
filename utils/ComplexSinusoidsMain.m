% Complex Sinusoids Interactive Demo
% Written by Dr Rodney Tan,
% Version 1.00 (Oct 2015)
function ComplexSinusoidsMain
    % Setup Figure UI  
    hFig = figure('Resize','off','NumberTitle','off','Toolbar','none',...
           'Name','Complex Sinusoids Interactive Demo');
    myhandles = guihandles(hFig);
    % UI control
    uicontrol('Style', 'pushbutton','string','Reset',...
        'Position', [475 345 80 25],'Callback',@Reset);
    uicontrol('Style', 'pushbutton','string','Help',...
        'Position', [475 370 80 25],'Callback',@Help);
    hView = uicontrol('Style', 'popup','string',...
            {'3D View','Real','Imaginary','Complex'},...
            'Position', [475 320 80 25],'Callback',@SetView);
    Reset;
    
    myhandles.hView = hView;
    guidata(hFig,myhandles);
end 
function Reset(hObj,event) %#ok<INUSD>
    cla;
    fs = 1000;
    ts = -10:1/fs:10;
    for f=1:length(ts)
        t = ts(1:f);
        y = exp(1i*t);
        plot3(t,real(y), imag(y),'b','LineWidth',2);
        hold on;
        plot3(10.1*ones(size(t)),real(y), imag(y),'y','LineWidth',2);
        plot3(t,1.1*ones(size(t)),imag(y),'g','LineWidth',2);
        plot3(t,real(y),-1.1*ones(size(t)),'r','LineWidth',2);
        xlim([-10 10.1]);
        ylim([-1 1.1]);
        zlim([-1.1 1]);
        grid on;
        xlabel('Time');
        zlabel('Imaginary Axis');
        ylabel('Real Axis');
        axis('square');
        view(-38,20);
        pause(0.01);
    end
    title('Complex:Blue   Real:Red   Imaginary:Green');
end
function SetView(hObj,event) %#ok<INUSD>
    myhandles = guidata(gcbo);
    hView = get(myhandles.hView,'Value');
    
    switch hView
        case 1  % 3D View
            set_az = -38;
            set_el = 20;
            title('Complex:Blue   Real:Red   Imaginary:Green');
        case 2  % Real Plane
            set_az = 0;
            set_el = 90;
            title('Real Axis:Blue   Imaginary:Green   Complex:Yellow');
        case 3  % Imaginary Plane
            set_az = 0;
            set_el = 0;
            title('Imaginary Axis:Blue   Real:Red   Complex:Yellow');
        case 4  % Complex Plane
            set_az = -90;
            set_el = 0;
            title('Complex Plane:Blue   Real:Red   Imaginary:Green');
    end
    
    [az, el] = view;
    if sign(az-set_az)==1
        az_step = -1;
    else
        az_step = 1;
    end
    
    if sign(el-set_el)==1
        el_step = -1;
    else
        el_step = 1;
    end
    
    for loop=1:max(abs([az,el]-[set_az,set_el]))
        if az==set_az
            az = set_az;
        else            
            az = az+az_step;
        end
        
        if el==set_el
            el = set_el;
        else            
            el = el+el_step;
        end
        view(az,el)
        pause(0.1);
    end
end
function Help(hObj,event) %#ok<INUSD>
    helpinfo = {'Complex Sinusoids Interactive Demo for Teaching & Learning';...
                'Written By Dr Rodney Tan, Version 1.00 (Oct 2015)';...
                '';...
                'This interactive demo illustrates complex sinusoids e^jwt=cos(wt)+jsin(wt)';...
                'in 3D animation plot showing the relationship between complex plane,';...
                'real axis and imaginary axis';...
                '';...
                'The reset button replay the animation';...
                'The popup menu allows the user to switch the view between';...
                '3D view, Real axis, Imaginary axis and Complex plane';
                '';...
                'If you find this interactive demo useful to you';...
                'Please kindly rate it, Thank you'};...
    helpdlg(helpinfo,'Help');
end