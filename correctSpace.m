function [spcDict] = correctSpace(words, spcDict)

% Check and place a space for incorrectly combined words
if ~exist('url', 'var') || isempty(url), url = ...
    sprintf('https://www.google.com/search?q='); end

dictPart1 = spcDict;

% Check every word in the input stream
spcDict = cell(length(words), 2);
for i=1:length(spcDict)
    % Check if the query word is already added in the DB.
    if ~isempty(dictPart1)
        if ~isempty(find(strcmp(dictPart1(:,1), words{i}))) 
            words{i} = char(dictPart1(min(find(strcmp(dictPart1(:,1), words{i}))),2));
            continue;
        elseif ~isempty(find(strcmp(spcDict(:,1), words{i})))
            words{i} = char(spcDict(min(find(strcmp(spcDict(:,1), words{i}))),2));
            continue;
        end
    end
    
    % Check if the word doesn't need to be queried
    alphaOnly = regexp(words{i}, '[A-Z,a-z]');
    if length(alphaOnly)< length(words{i})
        spcDict{i,1} = words{i};
        spcDict{i,2} = words{i};
        continue;
    end
    
    % Read the dictionary page source for each given word
    [sourcefile, ~] = urlread(sprintf([url, 'oftopics']));  
    if (isempty(sourcefile))
        spcDict{i,1} = words{i};
        spcDict{i,2} = words{i};
        continue;
    end

    stStemIdcs = strfind(sourcefile, 'Did you mean:</span> <a class="spell" href="')';
    tmpEdStemIdcs = strfind(sourcefile, '</i></b></a> </p></div>')';
    edStemIdcs = zeros(length(stStemIdcs),1);
    tgtSrc = cell(length(stStemIdcs),1);

    % Find minimum distance </span> from each <span .. dbox-bold>, retreive
    % only relevant parts and extract only necessary words from them
    for j=1:length(stStemIdcs)
        edStemIdcs(j) = min(tmpEdStemIdcs(find(stStemIdcs(j) < tmpEdStemIdcs)));
        tgtSrc{j} = sourcefile(stStemIdcs(j):edStemIdcs(j));
        extIdc = regexp(tgtSrc{j}, '[\w\s\<\>\/]');
        tgtSrc{j} = tgtSrc{j}(extIdc);
        tgtSrc{j} = strrep(tgtSrc{j}, '<', '');
        stSubIdx = strfind(tgtSrc{j}, 'span classme');
        edSubIdx = strfind(tgtSrc{j}, '>');
        tgtSrc{j}(stSubIdx:edSubIdx) = [];
        tgtSrc{j} = strtrim(tgtSrc{j});
    end
    
    tgtSrc = unique(tgtSrc);
    if (length(tgtSrc)>1)
        [~, minIdx] = min(cellfun('length', tgtSrc));
        if length(strfind(tgtSrc{minIdx},' ')>0)
            tgtSrc = words{i};
        else
            tgtSrc = tgtSrc{minIdx};
        end
    else
        tgtSrc = char(tgtSrc);
    end
    spcDict{i,1} = words{i};
    spcDict{i,2} = lower(tgtSrc);
end

if (~isempty(dictPart1))
    spcDict = [dictPart1;spcDict];
    emptyCells = cellfun('isempty', spcDict); 
    spcDict(all(emptyCells,2),:) = [];
end

if mod(iterNo, 10)==0 && iterNo>0
    sd = spcDict;
    [~,idx]=unique(strcat(sd(:,1),sd(:,2)), 'rows');
    spcDict = sd(idx,:);
    save([baseDir, 'spcDictionary.mat'], 'spcDict');
end
a = 1;

end