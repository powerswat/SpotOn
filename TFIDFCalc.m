function [TFIDF_mat] = TFIDFCalc(baseDir, termsData)

% Count the number of each term appears in the set of documents

numBodies = length(termsData);
TFIDF_mat = cell(numBodies,1);
for i=1:numBodies        
    TFIDF_mat(i) = {tabulate(termsData{i})};
    TFIDF_mat(i) = {[TFIDF_mat{i}, cell(size(TFIDF_mat{i},1), 1)]};
    keep_idx = find(cell2mat(TFIDF_mat{i}(:,2)));
    TFIDF_mat{i} = TFIDF_mat{i}(keep_idx,:);
    tfMax = max(cell2mat(TFIDF_mat{i}(:,2)));
    TFIDF_mat{i}(:,4) = num2cell(0.5 + ((0.5 * cell2mat(TFIDF_mat{i}(:,2))) / tfMax));
    if (mod(i, 1000)==0)
        disp(['Generate TF mat: ', num2str(i), '/', num2str(numBodies)]);
    end
end

numTerms = 0;
for i=1:numBodies
    numTerms = numTerms + size(TFIDF_mat{i},1);
end

% Generate IDF matrix
termMap = cell(numTerms,1);
idx = 1;
for i=1:numBodies
    termMap(idx:idx+size(TFIDF_mat{i},1)-1) = TFIDF_mat{i}(:,1);
    idx = idx + size(TFIDF_mat{i},1);
    if (mod(i, 1000)==0)
        disp(['Generate termSet: ', num2str(i), '/', num2str(numBodies)]);
    end
end

IDF = tabulate(termMap);
txtOnlyIdcs = find(~cellfun(@isempty, regexp(IDF(:,1), '[A-z,a-z]')));
IDF = IDF(txtOnlyIdcs, :);
IDF = [IDF, cell(size(IDF,1), 2)];
IDF(:,4) = num2cell(log10((length(IDF)./cell2mat(IDF(:,2)))));
keep_idx = find(cell2mat(IDF(:,2))>0);
IDF = IDF(keep_idx,:);
[~,s_idx] = sort(cell2mat(IDF(:,2)));
IDF = IDF(s_idx,:);

% Calculate TF-IDF
for i=1:numBodies
    [~, iTFIDF, iIDF] = intersect(TFIDF_mat{i}(:,1), IDF(:,1));
    TFIDF_mat{i}(iTFIDF,5) = num2cell(cell2mat(TFIDF_mat{i}(iTFIDF,4)) .* cell2mat(IDF(iIDF,4)));

    keep_idx = find(~cellfun(@isempty, TFIDF_mat{i}(:,5)));
    TFIDF_mat{i} = TFIDF_mat{i}(keep_idx,:);
    keep_idx = find(cellfun(@length, TFIDF_mat{i,1}(:,1)));
    TFIDF_mat{i} = TFIDF_mat{i}(keep_idx,:);
    [~,s_idx] = sort(cell2mat(TFIDF_mat{i}(:,5)), 'descend');
    TFIDF_mat{i} = TFIDF_mat{i}(s_idx,:);
          
    if (mod(i, 1000)==0)
        disp(['Generate TFIDF mat: ', num2str(i), '/', num2str(numBodies)]);
    end
end
                
save([baseDir, 'TFIDF_fin.mat'], 'TFIDF_mat'); %, 'TFnewIdx');

end