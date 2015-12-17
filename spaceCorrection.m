function [words, termsData] = spaceCorrection(spcDict, words, termsData)

cnt_words = length(words);
cnt_terms = length(termsData);

for i=1:length(words)
    dict_idx = find(strcmp(spcDict(:,1), words{i})); 
    if ~isempty(dict_idx)
        split_terms = split(spcDict{dict_idx,2}, ' ');
        words{cnt_words+1} = split_terms{1};
        words{cnt_words+2} = split_terms{2};
        cnt_words = cnt_words + 2;
    end
end

rmv_idcs = zeros(length(words),1);
for i=1:length(words)
    dict_idx = find(strcmp(spcDict(:,1), words{i})); 
    if ~isempty(dict_idx) || isempty(words{i})
        rmv_idcs(i) = 1;
    end
end
rmv_idcs = find(rmv_idcs);
words(rmv_idcs) = [];
words = unique(words);

for j=1:length(termsData)
    cnt_terms = length(termsData{j});
    for i=1:length(termsData{j})
        dict_idx = find(strcmp(spcDict(:,1), termsData{j}(i))); 
        if ~isempty(dict_idx)
            split_terms = split(spcDict{dict_idx,2}, ' ');
            termsData{j}{cnt_terms+1} = split_terms{1};
            termsData{j}{cnt_terms+2} = split_terms{2};
            cnt_terms = cnt_terms + 2;
        end
    end

    rmv_idcs = zeros(length(termsData{j}),1);
    for i=1:length(termsData{j})
        dict_idx = find(strcmp(spcDict(:,1), termsData{j}(i))); 
        if ~isempty(dict_idx) || isempty(termsData{j}(i))
            rmv_idcs(i) = 1;
        end
    end
    rmv_idcs = find(rmv_idcs);
    termsData{j}(rmv_idcs) = [];
    termsData{j} = unique(termsData{j});
end

a = 1;

end