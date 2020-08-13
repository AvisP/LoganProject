clear;clc;
% load('Table_red98orng15.mat')
load('Table_pu17pu18.mat')

output_folder = 'F:\data_for_avishek\LoganProject\output\';
plot_axes_label = 0; % Set to 1 if axes label wanted on save dfigure else 0

[unique_syllable,ia,ic] = unique(char(TotalDataTable.SyllableLabels),'stable');
num_occurences = accumarray(ic,1);

Dataset_PCA = [];
for i =1:length(unique_syllable)
    rows = (char(TotalDataTable.SyllableLabels)==unique_syllable(i));
    FeatureMatrix_subset = TotalDataTable(rows,...
                                {'MeanFrequency',...
                                'SpectralDensityEntropy',...
                                'SyllableDuration',...
                                'LoudnessEntropy',...
                                'SpectroTemporalEntropy',...
                                'MeanLoudness'});
%     FeatureMatrix_subset_info = TotalDataTable(rows,{'FileName'});
    FeatureMatrix_subset_norm = zscore(table2array(FeatureMatrix_subset));
    if size(FeatureMatrix_subset_norm,1)<5
        disp(['Skiping syllable ',char(unique_syllable(i)),' as it has less than 5 samples'])
    else
%     median(FeatureMatrix_subset_norm)
    [coeff,score,latent,tsquared,explained] = pca(FeatureMatrix_subset_norm);
    FeatureMatrix_subset_info = TotalDataTable(rows,{'FileName','SyllableLabels'});
%     for kk = 1:size(FeatureMatrix_subset_info,1)
%         if contains(char(FeatureMatrix_subset_info.FileName(kk)),'undir')
%             FeatureMatrix_subset_info.Type(kk) = {'undir'};
%         else
%             FeatureMatrix_subset_info.Type(kk) = {'dir'};
%         end
%     end
    FeatureMatrix_subset_info.PCA1 = score(:,1);
    FeatureMatrix_subset_info.PCA2 = score(:,2);
    FeatureMatrix_subset_info.PCA3 = score(:,3);
    
%     unique_syllable_dir_rows = all(char(FeatureMatrix_subset_info.Type)=='dir  ',2);
%     unique_syllable_undir_rows = all(char(FeatureMatrix_subset_info.Type)=='undir',2);
%     FeatureMatrix_subset_info_dir = FeatureMatrix_subset_info(unique_syllable_dir_rows,...
%                                                                 {'FileName',...
%                                                                  'PCA1',...
%                                                                  'PCA2',...
%                                                                  'PCA3'});
%     FeatureMatrix_subset_info_undir = FeatureMatrix_subset_info(~unique_syllable_dir_rows,...
%                                                                 {'FileName',...
%                                                                  'PCA1',...
%                                                                  'PCA2',...
%                                                                  'PCA3'});
                                                             
%     FeatureMatrix_subset_info = sortrows(FeatureMatrix_subset_info,'Type');  
%     unique_syllable_dir_rows = all(char(FeatureMatrix_subset_info.Type)=='dir  ',2);
%     PCA_mean_subset_dir = mean(table2array(FeatureMatrix_subset_info(unique_syllable_dir_rows,{'PCA1','PCA2','PCA3'})));
%     PCA_mean_subset_undir = mean(table2array(FeatureMatrix_subset_info(~unique_syllable_dir_rows,{'PCA1','PCA2','PCA3'})));
%     
    PCA_mean_subset = mean(table2array(FeatureMatrix_subset_info(:,{'PCA1','PCA2','PCA3'})));
    Subset_distance_from_mean = pdist2(table2array(FeatureMatrix_subset_info(:,...
                                            {'PCA1','PCA2','PCA3'})),...
                                            PCA_mean_subset);
%     Subset_distance_from_mean_dir = pdist2(table2array(FeatureMatrix_subset_info(unique_syllable_dir_rows,...
%                                             {'PCA1','PCA2','PCA3'})),...
%                                             PCA_mean_subset_dir);
%     Subset_distance_from_mean_undir = pdist2(table2array(FeatureMatrix_subset_info(~unique_syllable_dir_rows,...
%                                             {'PCA1','PCA2','PCA3'})),...
%                                             PCA_mean_subset_undir);
    FeatureMatrix_subset_info.Mean_distance = Subset_distance_from_mean;
%     FeatureMatrix_subset_info_undir.Mean_distance = Subset_distance_from_mean_undir;
%     Mean_FileName_dir(i) = FeatureMatrix_subset_info.FileName(find(FeatureMatrix_subset_info.Mean_distance == min(Subset_distance_from_mean_dir)));
%     Mean_FileName_undir(i) = FeatureMatrix_subset_info.FileName(find(FeatureMatrix_subset_info.Mean_distance == min(Subset_distance_from_mean_undir)));
    Mean_FileName(i) = FeatureMatrix_subset_info.FileName(find(FeatureMatrix_subset_info.Mean_distance == min(Subset_distance_from_mean)));
    if size(explained,1) == 1
        explained =  cat(1,explained,[0;0;0;0;0]);
    elseif size(explained,1) == 2
        explained =  cat(1,explained,[0;0;0;0]);
    elseif size(explained,1) == 3
        explained = cat(1,explained,[0;0;0]);
    elseif size(explained,1) == 4
        explained = cat(1,explained,[0;0]);
    elseif size(explained,1) == 5
        explained = cat(1,explained,0);     
    end
%     if size(explained,1) == 5
%         explained = cat(1,explained,0);     
%     end
    explained_var_total(i,:) = explained;
    Dataset_PCA = [ Dataset_PCA; FeatureMatrix_subset_info];
    
    clear FeatureMatrix_subset_info FeatureMatrix_subset_norm unique_syllable_dir_rows PCA_mean_subset_dir
    clear PCA_mean_subset_undir Subset_distance_from_mean_dir Subset_distance_from_mean_undir FeatureMatrix_subset
    clear coeff score latent tsquared explained
    end
end

Mean_FileName(cellfun('isempty',Mean_FileName)) = [];

disp('Mean Files for individual syallables');
for i = 1:size(Mean_FileName,2)
   disp([char(Mean_FileName(i))]) 
end

% indx = find((contains(TotalDataTable.FileName,Mean_FileName(1))));

%%% Plots and saves the median files only
for i = 1:size(Mean_FileName,2)
    indx = find((contains(TotalDataTable.FileName,Mean_FileName(i))));
    disp(['Saving ',char(TotalDataTable.FileName(indx(1)))])
    sptemp = spec_plot_save(cell2mat(TotalDataTable.Audio(indx(1))),TotalDataTable.SamplingRate(indx(1)),...
        output_folder,char(TotalDataTable.FileName(indx(1))),1,plot_axes_label);
    SpectralMatrix(indx(1)) = {sptemp};
    audiowrite(strcat(output_folder,char(TotalDataTable.FileName(indx(1))),'.wav'),...
            cell2mat(TotalDataTable.Audio(indx(1))),TotalDataTable.SamplingRate(indx(1)));
   
    clear sptemp
end

