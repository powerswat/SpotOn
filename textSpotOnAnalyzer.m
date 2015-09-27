function textSpotOnAnalyzer(inputDir, dataXls)

%% Set up a default dumped sql path
if ~exist('inputDir', 'var') || isempty(inputDir), inputDir = ...
    'C:\Users\Young Suk Cho\Box Sync\Research_SpotOn Project\03. Source Code\'; end
if ~exist('dataXls', 'var') || isempty(dataXls), dataXls = 'dbdump_150924.xlsx'; end

%% Read the given xls file
[num,str,raw] = xlsread([inputDir, dataXls]);

%% Retrieve the review table data

% Convert the string matrix to a vector
str = reshape(str, size(str,1)*size(str,2), 1);
str = strrep(str, '&nbsp;', '');
stBrkIdccs = strfind(str,'<');
edBrkIdccs = strfind(str,'>');

for i=1:length(str)
    if ~isempty(stBrkIdccs{i})
        for j=1:length(stBrkIdccs(i))
            if length(stBrkIdccs(i)) > length(edBrkIdccs(i)) && j == stBrkIdccs(i)
                str{i}(stBrkIdccs{i}(j):end) = [];
            else
                str{i}(stBrkIdccs{i}(j):edBrkIdccs{i}(j)) = [];
            end 
        end
    end
end

% [str, stemDict] = stemmer('',

%% Stemming the collected words



% 

a = 1;