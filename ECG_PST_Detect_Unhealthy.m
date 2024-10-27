clear all
close all
clc

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [24, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["LabVIEWMeasurement", "VarName2", "Var3"];
opts.SelectedVariableNames = ["LabVIEWMeasurement", "VarName2"];
opts.VariableTypes = ["double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Var3", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var3", "EmptyFieldRule", "auto");

% Import the data
data_table = readtable("C:\Users\zhipe\Downloads\signal_Raw_35.lvm", opts);

data=table2array(data_table);

time=data(:,1);
signal=data(:,2);

%% Time reduce
time_difference=(time-37.2).^2;

index_37_2=find(time_difference==min(time_difference));

time_difference=(time-58.8).^2;

index_58_8=find(time_difference==min(time_difference));

signal=signal(index_37_2:index_58_8);
signal=signal-mean(signal)+0.05;
time=time(index_37_2:index_58_8)-37.2;

%% Clear temporary variables
clear opts
%% Playing the signal reference
P_peaks=[37.41 38.40 39.32 40.27 41.17 42.13 43.10 44.04 44.95 45.95 46.86 47.77 48.80 49.70 50.64 51.55 52.51 53.37 54.36 55.23 56.15 57.06 57.99]-37.2;
Q_peaks=[37.6 38.59 39.51 40.46 41.40 42.31 43.26 44.2 45.18 46.1 47.05 48.02 48.98 49.92 50.83 51.74 52.7 53.59 54.53 55.41 56.34 57.21 58.11]-37.2;
S_peaks=[37.77 38.76 39.7 40.65 41.59 42.53 43.46 44.41 45.34 46.32 47.27 48.23 49.17 50.13 51.04 51.98 52.90 53.83 54.73 55.65 56.54 57.44 58.34]-37.2;
T_peaks=[38.03 39.01 39.93 40.87 41.81 42.76 43.68 44.63 45.6 46.54 47.5 48.46 49.45 50.37 51.27 52.18 53.11 54.01 54.95 55.85 56.78 57.65 58.57]-37.2;
size(P_peaks)
size(Q_peaks)
size(S_peaks)
size(T_peaks)

for ii=1:length(P_peaks);
    t_P_diff=(time-P_peaks(ii)).^2;
    P_index(ii)=find(t_P_diff==min(t_P_diff));

    t_Q_diff=(time-Q_peaks(ii)).^2;
    Q_index(ii)=find(t_Q_diff==min(t_Q_diff));

    t_S_diff=(time-S_peaks(ii)).^2;
    S_index(ii)=find(t_S_diff==min(t_S_diff));

    t_T_diff=(time-T_peaks(ii)).^2;
    T_index(ii)=find(t_T_diff==min(t_T_diff));
end

P_thresholds=P_index;
Q_thresholds=Q_index;
S_thresholds=S_index;
T_thresholds=T_index;

%% setup tcp communication
tcpipClient = tcpip('127.0.0.1',55001,'NetworkRole','Client');
fopen(30);
set(tcpipClient,'Timeout',30);
% setup

%% Downsample and plotting in real time
sampling_frequency=1/(time(2)-time(1));
window_length=2;

% downsampling
ds_factor=2048;
signal_cut=downsample(signal,ds_factor);
time_cut=downsample(time,ds_factor);
P_thresholds_cut=floor(P_thresholds./ds_factor);
Q_thresholds_cut=floor(Q_thresholds./ds_factor);
S_thresholds_cut=floor(S_thresholds./ds_factor);
T_thresholds_cut=floor(T_thresholds./ds_factor);

phase="R";

% figure
% plotting in real time
for si=1:length(signal_cut);
    if time_cut(si)>window_length && time_cut(si)<time_cut(end)-window_length
        tic
        % pause(0.0000001)
        time_diff_ini=((time_cut-(time_cut(si)-window_length)).^2);
        time_play_ini=find(time_diff_ini==min(time_diff_ini));
        plot(time_cut(time_play_ini:si),signal_cut(time_play_ini:si))
        xlim([time_cut(si)-window_length time_cut(si)])
        drawnow
        
        for pi=1:(length(P_thresholds_cut)-1)
            if si>P_thresholds_cut(pi) && si<P_thresholds_cut(pi+1)
                status=pi;

                if si>=P_thresholds_cut(status)&& si<Q_thresholds_cut(status);
                    phase="P"

                elseif si>=Q_thresholds_cut(status)&& si<S_thresholds_cut(status);
                    phase="S"

                elseif si>=S_thresholds_cut(status)&& si<T_thresholds_cut(status);
                    phase="T"
                else
                    phase="R"
                end

            end
            % phase;
            s1=phase;
            s2=num2str(signal_cut(si));
            formatSpec = ' %1$s %2$s %3$s %4$s %5$s';
            a = sprintf(formatSpec,s1,s2);
            
            % fclose(tcpipClient);
            fclose(tcpipClient);
            fopen(tcpipClient);
            fwrite(tcpipClient,a);
            fclose(tcpipClient);
        end
        time_pass=toc;
    end
end

% for peaks_index=1:length(P_thresholds);
%     if index > P_thresholds(index);
%     end
% end
%% Outputing downsample data
% data_ds=downsample(data,8);
% figure;
%plot(data_ds)

%csvwrite('EKG_test_125Hz.csv',data_ds)

%% Playing the signal reference
% P_peaks=[37.41 38.40 39.32 40.27 41.17 42.13 43.10 44.04 44.95 45.95 46.86 47.77 48.80 49.70 50.64 51.55 52.51 53.37 54.36 55.23 56.15 57.06 57.99];
% Q_peaks=[37.6 38.59 39.51 40.46 41.40 42.31 43.26 44.2 45.18 46.1 47.05 48.02 48.98 49.92 50.83 51.74 52.7 53.59 54.53 55.41 56.34 57.21 58.11];
% S_peaks=[37.77 38.76 39.7 40.65 41.59 42.53 43.46 44.41 45.34 46.32 47.27 48.23 49.17 50.13 51.04 51.98 52.90 53.83 54.73 55.65 56.54 57.44 58.34];
% T_peaks=[38.03 39.01 39.93 40.87 41.81 42.76 43.68 44.63 45.6 46.54 47.5 48.46 49.45 50.37 51.27 52.18 53.11 54.01 54.95 55.85 56.78 57.65 58.57];