%%%% Code not complete for further extension into Directed and Undirected
%%%% classification

clear;clc;
% load('Table_red98orng15.mat')
load('Table_pu17pu18.mat')

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
%     median(FeatureMatrix_subset_norm)
    [coeff,score,latent,tsquared,explained] = pca(FeatureMatrix_subset_norm);
    FeatureMatrix_subset_info = TotalDataTable(rows,{'FileName','SyllableLabels'});
    for kk = 1:size(FeatureMatrix_subset_info,1)
        if contains(char(FeatureMatrix_subset_info.FileName(kk)),'undir')
            FeatureMatrix_subset_info.Type(kk) = {'undir'};
        else
            FeatureMatrix_subset_info.Type(kk) = {'dir'};
        end
    end
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
                                                             
    FeatureMatrix_subset_info = sortrows(FeatureMatrix_subset_info,'Type');  
    unique_syllable_dir_rows = all(char(FeatureMatrix_subset_info.Type)=='dir  ',2);
    PCA_mean_subset_dir = mean(table2array(FeatureMatrix_subset_info(unique_syllable_dir_rows,{'PCA1','PCA2','PCA3'})));
    PCA_mean_subset_undir = mean(table2array(FeatureMatrix_subset_info(~unique_syllable_dir_rows,{'PCA1','PCA2','PCA3'})));
    
    Subset_distance_from_mean_dir = pdist2(table2array(FeatureMatrix_subset_info(unique_syllable_dir_rows,...
                                            {'PCA1','PCA2','PCA3'})),...
                                            PCA_mean_subset_dir);
    Subset_distance_from_mean_undir = pdist2(table2array(FeatureMatrix_subset_info(~unique_syllable_dir_rows,...
                                            {'PCA1','PCA2','PCA3'})),...
                                            PCA_mean_subset_undir);
    FeatureMatrix_subset_info.Mean_distance = [Subset_distance_from_mean_dir;Subset_distance_from_mean_undir];
%     FeatureMatrix_subset_info_undir.Mean_distance = Subset_distance_from_mean_undir;
    Mean_FileName_dir(i) = FeatureMatrix_subset_info.FileName(find(FeatureMatrix_subset_info.Mean_distance == min(Subset_distance_from_mean_dir)));
    Mean_FileName_undir(i) = FeatureMatrix_subset_info.FileName(find(FeatureMatrix_subset_info.Mean_distance == min(Subset_distance_from_mean_undir)));
    explained_var_total(i,:) = explained;
    Dataset_PCA = [ Dataset_PCA; FeatureMatrix_subset_info];
    
    clear FeatureMatrix_subset_info FeatureMatrix_subset_norm unique_syllable_dir_rows PCA_mean_subset_dir
    clear PCA_mean_subset_undir Subset_distance_from_mean_dir Subset_distance_from_mean_undir FeatureMatrix_subset
    clear coeff score latent tsquared explained
end

display('Mean Directed Files for individual subset');
Mean_FileName_dir


display('Mean Undirected Files for individual subset');
Mean_FileName_undir

% rng(2020) % for fair comparison
% option_settings.MaxIter = 5000;
% option_settings.TolFun = 1e-15;
% 
% [Y,loss] = tsne(FeatureMatrix_subset_norm,'Algorithm','exact','Distance','euclidean',...
%     'NumPrint',1000,'options',option_settings,'Verbose',1);
% rows = (char(TotalDataTable.SyllableLabels)==unique_syllable(1));
% 
% FeatureMatrix_subset = TotalDataTable(rows,...
%                                 {'MeanFrequency',...
%                                 'SpectralDensityEntropy',...
%                                 'SyllableDuration',...
%                                 'LoudnessEntropy',...
%                                 'SpectroTemporalEntropy',...
%                                 'MeanLoudness'});
%                             
%            FeatureMatrix_total = TotalDataTable(1:end,{'MeanFrequency',...
%                                 'SpectralDensityEntropy',...
%                                 'SyllableDuration',...
%                                 'LoudnessEntropy',...
%                                 'SpectroTemporalEntropy',...
%                                 'MeanLoudness'});
%                             
% FMT_norm = zscore(table2array(FeatureMatrix_total));
