function [words, termsData] = spotOnTxtPreProc(rawStr)

% Convert the string matrix to a vector
while true
    rawStr = reshape(rawStr, size(rawStr,1)*size(rawStr,2), 1);
    rawStr = strrep(rawStr, '&nbsp;', ' ');
    stBrkIdccs = strfind(rawStr,'<');
    edBrkIdccs = strfind(rawStr,'>');
    
    if length(find(~cellfun(@isempty, stBrkIdccs)))==0
        break;
    end

    % Remove all the tag information surrounded by < >
    for i=1:length(rawStr)
        if ~isempty(stBrkIdccs{i})
            if length(stBrkIdccs{i}) > length(edBrkIdccs{i}) && 1 == length(stBrkIdccs{i})
                rawStr{i}(stBrkIdccs{i}(1):end) = [];
            else
                rawStr{i}(stBrkIdccs{i}(1):edBrkIdccs{i}(1)) = [];
            end 
        end
    end
end

% Extract every word from the set of textual information
termsData = cell(length(rawStr),1);
for i=1:length(rawStr)
    if ~isempty(strfind(rawStr{i}, '@')) || isempty(rawStr{i})
        continue;
    end
    
    termsData{i} = lower(strread(rawStr{i}, '%s', 'delimiter', ' ''"-*,&.:/;!'));
    txtOnlyIdcs = find(~cellfun(@isempty, regexp(termsData{i}, '[A-z,a-z]')));
    termsData{i} = termsData{i}(txtOnlyIdcs, :);
end
not_empty_idcs = find(~cellfun(@isempty, termsData));
termsData = termsData(not_empty_idcs, :);


num_word = sum(cellfun(@length, termsData));
words = cell(num_word,1);
cnt = 1;
for i=1:length(termsData)
    for j=1:length(termsData{i})
        words{cnt} = char(termsData{i}(j));
        cnt = cnt + 1;
    end
end

keep_idcs = find(~cellfun(@isempty, words));
words = strtrim(unique(words(keep_idcs)));

for i=1:length(words)
    alphaOnly = regexp(words{i}, '[A-Z,a-z]');
    if length(alphaOnly)< length(words{i})
        words{i} = words{i}(alphaOnly);
    end
end

end