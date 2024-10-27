clear all
close all
clc

d = daq("ni");
addinput(d,"Dev1","ai0","Voltage");
%#ok<*AGROW>
Dev1_4 = [];
n = ceil(d.Rate/10);

t = tic;
start(d,"continuous")
while true % Increase or decrease the pause duration to fit your needs.
    data = read(d,n);
    Dev1_4 = [Dev1_4; data];
    
%     Uncomment the following lines to enable live plotting.
    subplot(2,1,1)
    plot(data.Time, data.Variables)
    xlabel("Time (s)")
    ylabel("Voltage (V)")
    title("Current ECG Signal")
    subplot(2,1,2)
    plot(Dev1_4.Time, Dev1_4.Variables)
    title("Acquired Overall ECG Signal")
    xlabel("Time (s)")
    ylabel("Voltage (V)")
    legend(data.Properties.VariableNames)
end
stop(d)

% Display the read data
Dev1_4
plot(Dev1_4.Time, Dev1_4.Variables)
xlabel("Time (s)")
ylabel("Amplitude")
legend(Dev1_4.Properties.VariableNames, "Interpreter", "none")