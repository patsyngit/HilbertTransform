classdef app33_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        UIAxes_2                      matlab.ui.control.UIAxes
        AmplitudeSliderLabel          matlab.ui.control.Label
        AmplitudeSlider               matlab.ui.control.Slider
        SelectwaveformLabel           matlab.ui.control.Label
        SelectwaveformDropDown        matlab.ui.control.DropDown
        AddwaveformButton             matlab.ui.control.Button
        ResetsignalButton             matlab.ui.control.Button
        FrequencyHzSpinnerLabel       matlab.ui.control.Label
        FrequencyHzSpinner            matlab.ui.control.Spinner
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes3                       matlab.ui.control.UIAxes
        SignalparametersLabel         matlab.ui.control.Label
        SamplingparametersLabel       matlab.ui.control.Label
        SamplingfrequencyHzEditFieldLabel  matlab.ui.control.Label
        SamplingfrequencyHzEditField  matlab.ui.control.NumericEditField
        EndtimesEditFieldLabel        matlab.ui.control.Label
        EndtimesEditField             matlab.ui.control.NumericEditField
    end

    
    properties (Access = private)
        time    %time vector
        amp     %signal amplitude
        freq    %signal frequency
        wf      %input signal
        ht_fd1  %variant 1 of freuqnecy-domain approach Hilbert transform 
        ht_fd2  %variant 2 of freuqnecy-domain approach Hilbert transform 
        htmatlab%Hilbert transform from built-in MATLAB function
        endd    %input signal end time
        waveselect  %waveform chosen from drop-down list - string
        ht_td1  %variant 1 of time-domain approach Hilbert transform 
        ht_td2  %variant 2 of time-domain approach Hilbert transform 
    end
    
    methods (Access = private)
        
        function hilbertFreq(app)   %function calculates frequency-domain approach Hilbert trasnform
%variant 1 - Hilbert transform is calculated as a result of
%multiplication of Fourier transform of input signal and function 1/(pi*t)
%X is Fourier transform of input signal, Hfactor is signum function
%resulting Hilbert transform H=X*-i*Hfactor (H=X*-i*sgn) in frequency domain must be converted to time
%domain using Inverse Fourier Transform
%those instructions implement equation [16] from Final report
app.htmatlab = hilbert(app.wf);
X=fft(app.wf,length(app.wf));
sigminus=1:floor(length(app.time)/2);
sigplus=ceil(length(app.time)/2)+1:length(app.time);
Hfactor=zeros(1,length(app.time));
Hfactor(sigplus)=1;
Hfactor(sigminus)=-1;
H=1i.*Hfactor.*X;
app.ht_fd1=ifft(H,length(app.time));
%variant 2 - Hilbert transform is calculatated based on fact, that
%analytic signal's frequency spectrum is equal to 0 for negative
%frequencies, and equal to input signal's frequency spectrum for positive
%frequencies, Xc is analytic signal in frequency domain, its real part is
%input signal and imaginary part is Hilbert transform of input signal
Xc=2*X;
Xc(floor(length(X)/2)+2:length(X))=0;
Xc(1)=Xc(1)/2;
Xc(floor(length(X)/2)+1)=Xc(floor(length(X)/2)+1)/2;
app.ht_fd2=ifft(Xc,length(Xc));
        end

        
        
        function hilbertTime(app)   %function calculates time-domain approach Hilbert trasnform
%variant 1 - Hilbert transform is calculatated as a result of discrete
%convolution of input signal x and h function 1/(pi*t), discrete
%convolution is equal to multiplication of signals' samples
%those instructions implement equation [14] from Final report
app.ht_td1=zeros(1,length(app.wf));
for t=1:length(app.wf)
    dtauint=zeros(1,length(app.wf));
    for tau=1:length(app.wf)
        if t==tau
            continue;
        else
            dtauint(tau)=app.wf(tau)./(t-tau);
        end
    end
    app.ht_td1(t)=sum(dtauint)./pi;
end

%variant 2 - Hilbert transform is calculatated as a result of discrete
%convolution of input signal x and h function 1/(pi*t), discrete
%convolution is equal to multiplication of signals' samples
%those instructions implement equation [15] from Final report
app.ht_td2=zeros(1,length(app.wf));
for t=1:1:length(app.wf)
        dtauint=zeros(1,length(app.wf));
        if mod(t,2)==0
            for tau=1:1:length(app.wf)
                if tau==t 
                 continue;
                elseif mod(tau,2) == 1
                dtauint(tau)=app.wf(tau)./(t-tau);
                end
            end
        else
            for tau=1:1:length(app.wf)
                if tau==t 
                 continue;
                 elseif mod(tau,2) == 0
              dtauint(tau)=app.wf(tau)./(t-tau);
                end
            end
        end
        app.ht_td2(t)=2.*sum(dtauint)./pi;
end
        end
        
        function plotAll(app)   %functions plot calculated ananlytic signal and results of created Hilbert transform algorithms
plot(app.UIAxes3,app.time,app.wf,"LineWidth",1);
hold(app.UIAxes3,'on');
plot(app.UIAxes3,app.time,real(app.ht_fd1),"LineWidth",2);
plot(app.UIAxes3,app.time,imag(app.ht_fd2),"LineWidth",1);
plot(app.UIAxes3,app.time,imag(app.htmatlab),"LineWidth",1,"LineStyle","--");
app.UIAxes3.FontSize=15;
grid(app.UIAxes3,'on');
app.UIAxes3.Title.String='Hilbert transfrom - frequency domain comparison';
app.UIAxes3.XLabel.String='Time [s]';
app.UIAxes3.YLabel.String='Amplitude [s]';
legend(app.UIAxes3,'Input','Hilbert transform v.1','Hilbert transform v.2','Hilbert transform - MATLAB');
hold(app.UIAxes3,'off');

plot(app.UIAxes2,app.time,app.wf,"LineWidth",1);
hold(app.UIAxes2,'on');
plot(app.UIAxes2,app.time,app.ht_td1,"LineWidth",1);
plot(app.UIAxes2,app.time,app.ht_td2,"LineWidth",1);
plot(app.UIAxes2,app.time,imag(app.htmatlab),"LineWidth",1,"LineStyle","--");
app.UIAxes2.FontSize=15;
grid(app.UIAxes2,'on');
app.UIAxes2.Title.String='Hilbert transfrom - time domain comparison';
app.UIAxes2.XLabel.String='Time [s]';
app.UIAxes2.YLabel.String='Amplitude [s]';
legend(app.UIAxes2,'Input','Hilbert transform v.1','Hilbert transform v.2','Hilbert transform - MATLAB');
hold(app.UIAxes2,'off');

plot3(app.UIAxes_2,app.wf,app.time,real(app.ht_fd1),"LineWidth",1);
hold(app.UIAxes_2,'on');
plot3(app.UIAxes_2,app.wf,app.time,ones(1,length(app.ht_fd1)).*app.UIAxes_2.ZLim(1),"LineWidth",1);
plot3(app.UIAxes_2,ones(1,length(app.ht_fd1)).*app.UIAxes_2.XLim(2),app.time,real(app.ht_fd1),"LineWidth",1);
app.UIAxes_2.FontSize=15;
app.UIAxes_2.Title.String='Analytic signal';
app.UIAxes_2.XLabel.String='Real part [-]';
app.UIAxes_2.YLabel.String='Time [s]';
app.UIAxes_2.ZLabel.String='Imaginary part [-]';
legend(app.UIAxes_2,'Analytic signal','Input','Hilbert transform of input');
hold(app.UIAxes_2,'off');
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %set correct sizes of matrices and set their values to 0
            app.endd = app.EndtimesEditField.Value;
            app.time = 0:app.SamplingfrequencyHzEditField.Value:app.endd;            
            app.wf = zeros(1,length(app.time));
            app.ht_td1=zeros(1,length(app.wf));
            app.ht_td2=zeros(1,length(app.wf));
            app.ht_fd1=zeros(1,length(app.wf));
            app.ht_fd2=zeros(1,length(app.wf));
        end

        % Button pushed function: AddwaveformButton
        function AddwaveformButtonPushed(app, event)
            %pressing Add waveform button adds selected signal with input
            %parameters to analysed signal after checking which waveform was
            %selected, calculates Hilbert transforms and analytic signal,
            %and plots results
            app.waveselect = app.SelectwaveformDropDown.Value;
            app.endd = app.EndtimesEditField.Value;
            app.time = 0:app.SamplingfrequencyHzEditField.Value:app.endd;
            app.amp = app.AmplitudeSlider.Value;
            app.freq =app.FrequencyHzSpinner.Value;
            switch  app.waveselect
                case 'Sine'
                    app.wf = app.wf+app.amp.*sin(2.*pi.*app.freq.*app.time);
                case 'Cosine'
                    app.wf = app.wf+app.amp.*cos(2.*pi.*app.freq.*app.time);
                case 'Squarewave'
                    app.wf = app.wf+app.amp.*square(app.freq*2*pi*app.time);
                case 'Sawtooth'
                    app.wf = app.wf+app.amp.*sawtooth(app.freq*2*pi*app.time);
                case 'Triangularwave'
                    app.wf = app.wf+app.amp.*sawtooth(app.freq*2*pi*app.time,0.5);
            end
            hilbertFreq(app);
            hilbertTime(app);
            plotAll(app);
        end

        % Button pushed function: ResetsignalButton
        function ResetsignalButtonPushed(app, event)
            %pressing Add waveform button sets generated analysed signal to
            %0 and sets correct sizes of matrices
            close all;
            app.endd = app.EndtimesEditField.Value;
            app.time = 0:app.SamplingfrequencyHzEditField.Value:app.endd;            
            app.wf = zeros(1,length(app.time));
            app.htmatlab = hilbert(app.wf);
            app.ht_td1=zeros(1,length(app.wf));
            app.ht_td1=zeros(1,length(app.wf));
            app.ht_td2=zeros(1,length(app.wf));
            app.ht_fd1=zeros(1,length(app.wf));
            app.ht_fd2=zeros(1,length(app.wf));
            plotAll(app);
        end

        % Value changed function: FrequencyHzSpinner
        function FrequencyHzSpinnerValueChanged(app, event)
            app.freq =app.FrequencyHzSpinner.Value; %change signal frequency value
        end

        % Value changed function: AmplitudeSlider
        function AmplitudeSliderValueChanged(app, event)
            app.amp = app.AmplitudeSlider.Value;    %change signal amplitude value
        end

        % Value changed function: EndtimesEditField
        function EndtimesEditFieldValueChanged(app, event)
            %change end time of signal, set correct size of generated
            %signal matrix
            close all;
            app.endd = app.EndtimesEditField.Value;
            app.time = 0:app.SamplingfrequencyHzEditField.Value:app.endd;
            app.wf = zeros(1,length(app.time));
        end

        % Value changed function: SamplingfrequencyHzEditField
        function SamplingfrequencyHzEditFieldValueChanged(app, event)
            %change sampling frequency of signal, set correct size of generated
            %signal matrix
            close all;
            app.endd = app.EndtimesEditField.Value;
            app.time = 0:app.SamplingfrequencyHzEditField.Value:app.endd;
            app.wf = zeros(1,length(app.time));
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1269 956];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, '')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.XGrid = 'on';
            app.UIAxes_2.YGrid = 'on';
            app.UIAxes_2.ZGrid = 'on';
            app.UIAxes_2.Position = [346 456 879 487];

            % Create AmplitudeSliderLabel
            app.AmplitudeSliderLabel = uilabel(app.UIFigure);
            app.AmplitudeSliderLabel.HorizontalAlignment = 'right';
            app.AmplitudeSliderLabel.FontSize = 18;
            app.AmplitudeSliderLabel.Position = [129 881 86 22];
            app.AmplitudeSliderLabel.Text = 'Amplitude';

            % Create AmplitudeSlider
            app.AmplitudeSlider = uislider(app.UIFigure);
            app.AmplitudeSlider.Limits = [-10 10];
            app.AmplitudeSlider.ValueChangedFcn = createCallbackFcn(app, @AmplitudeSliderValueChanged, true);
            app.AmplitudeSlider.FontSize = 18;
            app.AmplitudeSlider.Position = [39 862 263 3];
            app.AmplitudeSlider.Value = 1;

            % Create SelectwaveformLabel
            app.SelectwaveformLabel = uilabel(app.UIFigure);
            app.SelectwaveformLabel.HorizontalAlignment = 'right';
            app.SelectwaveformLabel.FontSize = 18;
            app.SelectwaveformLabel.Position = [34 722 144 22];
            app.SelectwaveformLabel.Text = 'Select waveform:';

            % Create SelectwaveformDropDown
            app.SelectwaveformDropDown = uidropdown(app.UIFigure);
            app.SelectwaveformDropDown.Items = {'Sine', 'Cosine', 'Squarewave', 'Sawtooth', 'Triangularwave'};
            app.SelectwaveformDropDown.FontSize = 18;
            app.SelectwaveformDropDown.Position = [193 721 110 23];
            app.SelectwaveformDropDown.Value = 'Sine';

            % Create AddwaveformButton
            app.AddwaveformButton = uibutton(app.UIFigure, 'push');
            app.AddwaveformButton.ButtonPushedFcn = createCallbackFcn(app, @AddwaveformButtonPushed, true);
            app.AddwaveformButton.FontSize = 18;
            app.AddwaveformButton.Position = [103 515 131 29];
            app.AddwaveformButton.Text = 'Add waveform';

            % Create ResetsignalButton
            app.ResetsignalButton = uibutton(app.UIFigure, 'push');
            app.ResetsignalButton.ButtonPushedFcn = createCallbackFcn(app, @ResetsignalButtonPushed, true);
            app.ResetsignalButton.FontSize = 18;
            app.ResetsignalButton.Position = [111 474 115 29];
            app.ResetsignalButton.Text = 'Reset signal';

            % Create FrequencyHzSpinnerLabel
            app.FrequencyHzSpinnerLabel = uilabel(app.UIFigure);
            app.FrequencyHzSpinnerLabel.HorizontalAlignment = 'right';
            app.FrequencyHzSpinnerLabel.FontSize = 18;
            app.FrequencyHzSpinnerLabel.Position = [105 790 128 22];
            app.FrequencyHzSpinnerLabel.Text = 'Frequency [Hz]';

            % Create FrequencyHzSpinner
            app.FrequencyHzSpinner = uispinner(app.UIFigure);
            app.FrequencyHzSpinner.Limits = [1 50];
            app.FrequencyHzSpinner.ValueChangedFcn = createCallbackFcn(app, @FrequencyHzSpinnerValueChanged, true);
            app.FrequencyHzSpinner.HorizontalAlignment = 'center';
            app.FrequencyHzSpinner.FontSize = 18;
            app.FrequencyHzSpinner.Position = [141 757 61 23];
            app.FrequencyHzSpinner.Value = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.ColorOrder = [0 0.4471 0.7412;0.851 0.3255 0.098;0.4706 0.6706 0.1882;0.302 0.7451 0.9333;0.6353 0.0784 0.1843];
            app.UIAxes2.Position = [39 10 583 425];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            title(app.UIAxes3, 'Title')
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.ColorOrder = [0 0.4471 0.7412;0.851 0.3255 0.098;0.4706 0.6706 0.1882;0.302 0.7451 0.9333;0.6353 0.0784 0.1843];
            app.UIAxes3.Position = [642 10 583 425];

            % Create SignalparametersLabel
            app.SignalparametersLabel = uilabel(app.UIFigure);
            app.SignalparametersLabel.FontSize = 19;
            app.SignalparametersLabel.FontWeight = 'bold';
            app.SignalparametersLabel.Position = [80 916 177 23];
            app.SignalparametersLabel.Text = 'Signal parameters:';

            % Create SamplingparametersLabel
            app.SamplingparametersLabel = uilabel(app.UIFigure);
            app.SamplingparametersLabel.FontSize = 19;
            app.SamplingparametersLabel.FontWeight = 'bold';
            app.SamplingparametersLabel.Position = [66 686 206 23];
            app.SamplingparametersLabel.Text = 'Sampling parameters:';

            % Create SamplingfrequencyHzEditFieldLabel
            app.SamplingfrequencyHzEditFieldLabel = uilabel(app.UIFigure);
            app.SamplingfrequencyHzEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingfrequencyHzEditFieldLabel.FontSize = 18;
            app.SamplingfrequencyHzEditFieldLabel.Position = [68 587 203 22];
            app.SamplingfrequencyHzEditFieldLabel.Text = 'Sampling frequency [Hz]';

            % Create SamplingfrequencyHzEditField
            app.SamplingfrequencyHzEditField = uieditfield(app.UIFigure, 'numeric');
            app.SamplingfrequencyHzEditField.Limits = [0.0001 1];
            app.SamplingfrequencyHzEditField.ValueChangedFcn = createCallbackFcn(app, @SamplingfrequencyHzEditFieldValueChanged, true);
            app.SamplingfrequencyHzEditField.HorizontalAlignment = 'center';
            app.SamplingfrequencyHzEditField.FontSize = 18;
            app.SamplingfrequencyHzEditField.Position = [141 556 61 23];
            app.SamplingfrequencyHzEditField.Value = 0.01;

            % Create EndtimesEditFieldLabel
            app.EndtimesEditFieldLabel = uilabel(app.UIFigure);
            app.EndtimesEditFieldLabel.HorizontalAlignment = 'right';
            app.EndtimesEditFieldLabel.FontSize = 18;
            app.EndtimesEditFieldLabel.Position = [118 652 101 22];
            app.EndtimesEditFieldLabel.Text = 'End time [s]';

            % Create EndtimesEditField
            app.EndtimesEditField = uieditfield(app.UIFigure, 'numeric');
            app.EndtimesEditField.Limits = [0 20];
            app.EndtimesEditField.ValueChangedFcn = createCallbackFcn(app, @EndtimesEditFieldValueChanged, true);
            app.EndtimesEditField.HorizontalAlignment = 'center';
            app.EndtimesEditField.FontSize = 18;
            app.EndtimesEditField.Position = [150 621 43 23];
            app.EndtimesEditField.Value = 10;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app33_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end