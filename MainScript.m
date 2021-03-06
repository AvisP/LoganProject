clear;clc;

%%% Input variable names
parent_dir = 'F:\data_for_avishek\LoganProject\dataset\cgby\';
output_folder = 'F:\data_for_avishek\LoganProject\output\cgby\';
dataset_name = 'cgby';

% parent_dir = 'F:\data_for_avishek\LoganProject\dataset\cxyc\';
% output_folder = 'F:\data_for_avishek\LoganProject\output\cxyc\';
% dataset_name = 'cxyc';

% parent_dir = 'F:\data_for_avishek\LoganProject\dataset\cyea\';
% output_folder = 'F:\data_for_avishek\LoganProject\output\cyea\';
% dataset_name = 'cyea';

% parent_dir = 'F:\data_for_avishek\LoganProject\dataset\inji\';
% output_folder = 'F:\data_for_avishek\LoganProject\output\inji\';
% dataset_name = 'inji';

% parent_dir = 'F:\data_for_avishek\LoganProject\dataset\isab\';
% output_folder = 'F:\data_for_avishek\LoganProject\output\isab\';
% dataset_name = 'isab';

% parent_dir = 'F:\data_for_avishek\LoganProject\dataset\nzen\';
% output_folder = 'F:\data_for_avishek\LoganProject\output\nzen\';
% dataset_name = 'nzen';

shift_time = 20*10^-3;  % Amount of set 

plot_save_all_files = 0; % Set to 1 if want to save all files else set to 0
plot_axes_label = 0; % Set to 1 if axes label wanted on save dfigure else 0

if ~exist(parent_dir, 'dir')
    error('%s not found',parent_dir)
end

if ~exist(output_folder, 'dir')
    mkdir(output_folder)
end

dirf(strcat(parent_dir,'*.wav'),'motifbatch.txt');

fileID = fopen('motifbatch.txt','r');
list = textscan(fileID,'%s \n');
fclose(fileID);

temp_list = list{1,1};

if isempty(temp_list)
    error('Dirf function did not work properly');
end

counter = 1;
error_counter = 1;
for i=1:length(temp_list)
     display(['Loading segmentation of file ',(char(temp_list(i)))])
    [data,rate] = audioread(strcat(parent_dir,(char(temp_list(i)))));
    
    if isfile(strcat(parent_dir,char(temp_list(i)),char('.not.mat')))
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
                    %%% Loop to check if there is a capital label
                    if isstrprop(char(labels(kk)),'upper')
                        data_labels(counter) = strcat(temp_list(i),'_',char(labels(kk)),'cap');
                    else
                        data_labels(counter) = strcat(temp_list(i),'_',char(labels(kk)));
                    end
                    syllable_labels(counter) = {(char(labels(kk)))};
                    FeatureMatrix(counter,:) = feature_vect_test_logan(timeSeriesData{counter},rate);
                    SamplingRate(counter) = rate;
                    counter = counter+1;
                end
            end    
         else
           Error_data_files(error_counter) = {temp_list(i)} ;
           error_counter = error_counter + 1;
         end
     else
        warning('%s file does not exist',strcat(char(temp_list(i)),char('.not.mat')))
    end
end

ise = evalin( 'base', 'exist(''data_labels'',''var'') == 1' );
if ~ise
   error('No proper labelling found or files are unlabelled')
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
    display(['Processing ',char(TotalDataTable.FileName(i))])
    sptemp = spec_plot_save(cell2mat(TotalDataTable.Audio(i)),TotalDataTable.SamplingRate(i),...
        output_folder,char(TotalDataTable.FileName(i)),plot_save_all_files,plot_axes_label);
    SpectralMatrix(i) = {sptemp};
    if plot_save_all_files
        print('In Loop')
        audiowrite(strcat(output_folder,char(TotalDataTable.FileName(i)),char(TotalDataTable.FileName(i)),'.wav'),...
            cell2mat(TotalDataTable.Audio(i)),TotalDataTable.SamplingRate(i));
    end
    clear sptemp
end

SpectralMatrixTable = cell2table(SpectralMatrix','VariableNames',{'Spectrograms'});
TotalDataTable = [ TotalDataTable SpectralMatrixTable];

[unique_syllable,ia,ic] = unique(char(TotalDataTable.SyllableLabels),'stable');

num_occurences = accumarray(ic,1);

disp('Individual syllable --  Occurences')
for i =1:length(unique_syllable)
   display(['        ' unique_syllable(i) '           --   ' num2str(num_occurences(i))])    
end

save(strcat('Table_',dataset_name,'.mat'),'TotalDataTable')

