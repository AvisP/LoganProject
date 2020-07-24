clear;clc;

%%% Input variable names
parent_dir = 'F:\data_for_avishek\HCTSAsyllable\redorng15\';
output_folder = 'F:\data_for_avishek\Batch Processing\output\';

dataset_name = 'redorng15';
shift_time = 20*10^-3;  % Amount of set 


dirf(strcat(parent_dir,'motif*.wav'),'motifbatch.txt');

fileID = fopen('motifbatch.txt','r');
list = textscan(fileID,'%s \n');
fclose(fileID);

temp_list = list{1,1};

counter = 1;
error_counter = 1;
for i=1:length(temp_list)
        i
    [data,rate] = audioread(strcat(parent_dir,(char(temp_list(i)))));
    load(strcat(parent_dir,char(temp_list(i)),char('.not.mat')))
    time = linspace(0,length(data)/rate,length(data));

     if sum(isletter(labels))>0   % if there is no alphabetic label then skip

        for kk = 1:length(labels)
            if isletter(labels(kk))
                
                onset_secs = onsets(kk)/1000 - shift_time;
                if onset_secs<0
                    onset_secs = 1e-5;
                end
                offset_secs = offsets(kk)/1000 + shift_time;
                if offset_secs>time(end)
                    offset_secs = time(end);
                end
                tindx_onset = find(time>onset_secs);
                tindx_offset = find(time>=offset_secs);

                timeSeriesData(counter) = {data(tindx_onset(1):tindx_offset(1))};    


                data_labels(counter) = strcat(temp_list(i),'_',char(labels(kk)));
                syllable_labels(counter) = {char(labels(kk))};
                FeatureMatrix(counter,:) = feature_vect_test_logan(timeSeriesData{counter},rate);
                SamplingRate(counter) = rate;
                counter = counter+1;
            end
        end    
     else
       Error_data_files(error_counter) = {temp_list(i)} ;
       error_counter = error_counter + 1;
    end
end

T = cell2table(data_labels','VariableNames',{'FileName'});
T2 = cell2table(syllable_labels','VariableNames',{'SyllableLabels'});
T1 = cell2table(timeSeriesData','VariableNames',{'Audio'});
T3 = array2table(SamplingRate','VariableNames',{'SamplingRate'});
FM = array2table(FeatureMatrix,'VariableNames',...
    {'MeanFrequency','SpectralDensityEntropy','SyllableDuration','LoudnessEntropy','SpectroTemporalEntropy', 'MeanLoudness'});
TotalDataTable = [T T2 T3 T1 FM];

% s = size(TotalDataTable);
for i = 1:size(TotalDataTable,1)
    display('Processing ',char(TotalDataTable.FileName(i)))
    sptemp = spec_plot_save(cell2mat(TotalDataTable.Audio(i)),TotalDataTable.SamplingRate(i),...
        output_folder,char(TotalDataTable.FileName(i)));
    SpectralMatrix(i) = {sptemp};
    audiowrite(strcat(output_folder,char(TotalDataTable.FileName(i)),char(TotalDataTable.FileName(i)),'.wav'),...
        cell2mat(TotalDataTable.Audio(i)),TotalDataTable.SamplingRate(i));
    clear sptemp
end

SpectralMatrixTable = cell2table(SpectralMatrix','VariableNames',{'Spectrograms'});
TotalDataTable = [ TotalDataTable SpectralMatrixTable];

save(strcat('Table_',dataset_name,'.mat'),'TotalDataTable')

