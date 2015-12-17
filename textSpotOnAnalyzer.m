function textSpotOnAnalyzer(inputDir, dataXls)

%% Set up a default dumped sql path
if ~exist('inputDir', 'var') || isempty(inputDir), inputDir = ...
    'C:\Users\Young Suk Cho\Box Sync\Research_SpotOn Project\03. Source Code\'; end
if ~exist('dataXls', 'var') || isempty(dataXls), dataXls = 'dbdump_150924.xlsx'; end

baseDir = 'C:\Temp\SpotOn\';
isDictComplete = 0;
if exist([baseDir, 'stemDictionary.mat'], 'file')
    disp('Load existing Dictionary');
    load([baseDir, 'stemDictionary.mat']);
    isDictComplete = 1;
end
is_word_corret = 0;
if exist([baseDir, 'words_proc.txt'], 'file')
    disp('Load existing pre-processed word result');
    file_id = fopen([baseDir, 'words_proc.txt'], 'r');
    tmp_spcDict = textscan(file_id, '%s', 'Delimit  er', '\t');
    for i=1:length(tmp_spcDict{1})
        tmp_spcDict{1}(i) = strtrim(tmp_spcDict{1}(i));
    end
    len_spcDict = floor(length(tmp_spcDict{1})/2);
    orig_idcs = [1:2:len_spcDict*2]';
    crrct_idcs = [2:2:len_spcDict*2]';
    spcDict = cell(len_spcDict, 2);
    spcDict(:,1) = tmp_spcDict{1}(orig_idcs);
    spcDict(:,2) = tmp_spcDict{1}(crrct_idcs);
    [~,uniq_row] = unique(spcDict(:,1));
    spcDict = spcDict(uniq_row,:);
    fclose(file_id);
    
    disp('Load the term data that will be corrected');
    load([baseDir, 'word_terms.mat']);
    
    is_word_correct = 1;
else
    
end

%% Read the given xls file
[num,rawStr,raw] = xlsread([inputDir, dataXls]);

%% Retrieve the review table data (Text preprocessing)
if is_word_correct == 0
    [words, termsData] = spotOnTxtPreProc(rawStr);
    file_id = fopen([baseDir, 'words.txt'], 'w');
    for i=1:size(words,1)
        fprintf(file_id, '%s\r\n', words{i});
    end
    fclose(file_id);
    save([baseDir 'word_terms.mat'], 'words', 'termsData');
else
    [words, termsData] = spaceCorrection(spcDict, words, termsData);
end

%% Stemming the collected words
if isDictComplete == 0
    [~, stemDict] = stemSpotOn(baseDir, '', words, 10);
end

% Convert all the terms to be stemmed
for i=1:length(termsData)
    for j=1:length(termsData{i})
       dict_idx = find(strcmp(stemDict(:,1), termsData{i}(j)));
        if ~isempty(dict_idx)
           termsData{i}(j) = stemDict(dict_idx,2);
        end
    end
end

%% Calculate TFIDF values for all the terms
[TFIDF_mat] = TFIDFCalc(baseDir, termsData);
% save([baseDir 'TFIDF_mat.mat'], 'TFIDF_mat');

a = 1;