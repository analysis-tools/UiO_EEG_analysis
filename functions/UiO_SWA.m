function [EEG,logFile] = UiO_SWA(data_struct,subj_name,EEG,logFile)

if nargin < 1
    error('provide at least data_struct. See help UiO_preprocessing')
end


% check if EEG structure is provided. If not, load previous data
if isempty(EEG)
    if str2double(data_struct.load_data) == 0
        [EEG,logFile] = UiO_load_data(data_struct,subj_name,'ica_cleaned');   
    else
        [EEG,logFile] = UiO_load_data(data_struct,subj_name,[],'specific_data');
    end
end
 
% clean ICA structures for further computation (because EOG was removed)
EEG.icawinv = [];
EEG.icasphere = [];
EEG.icaweights = [];
EEG.icachansind = [];


% make sure data is in double
EEG.data = double(EEG.data);

epoch_length = str2double(data_struct.SW_epoch); %epoch length according to CSV
%Find latency for marker either from real marker or manually from CSV
if str2double(data_struct.SW_marker) == 0
    marker = str2double(data_struct.SW_noMarker);
else
    marker = EEG.event(strcmp({EEG.event.type},"Wake")).latency;
end

[number, timing, duration, ptp_amp, numb_pos, numb_neg] = UiO_calc_SWA(EEG, epoch_length, marker);

results = [number,timing,duration,ptp_amp,numb_pos,numb_neg];
results_header = ["number","timing","duration","ptp_amp","numb_pos","numb_neg"];

EEG.SWA_res = results;
EEG.SWA_header = results_header;

% loc file entry
logFile{end+1} = {'SWA_calculated',['SWA is calculated for an epoch of ' num2str(epoch_length) ...
    ' s.']};
end