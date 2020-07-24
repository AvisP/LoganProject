

unique_syllable = unique(char(TotalDataTable.SyllableLabels));


for i =1:length(unique_syllable)
    rows = (char(TotalDataTable.SyllableLabels)==unique_syllable(i));
    FeatureMatrix_subset = TotalDataTable(rows,...
                                {'MeanFrequency',...
                                'SpectralDensityEntropy',...
                                'SyllableDuration',...
                                'LoudnessEntropy',...
                                'SpectroTemporalEntropy',...
                                'MeanLoudness'});
    FeatureMatrix_subset_norm = zscore(table2array(FeatureMatrix_total));
    median(FeatureMatrix_subset_norm)
    [coeff,score,latent,tsquared,explained] = pca(FMT_norm);
end

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

[coeff,score,latent,tsquared,explained] = pca(FMT_norm);