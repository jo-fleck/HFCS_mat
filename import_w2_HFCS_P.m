%% Saves the HFCS Person datasets (Imputations 1-5) as mat files

% Fun will now commence
close all; clear; clc;

% Set paths
inpath = '/Users/main/OneDrive - Istituto Universitario Europeo/data/HFCS/files/HFCS_UDB_2_1_ASCII';
outpath = '/Users/main/OneDrive - Istituto Universitario Europeo/data/HFCS/files/wave2_mat';

%% Import country data for the different implicates

% Loop over imputations

for j = 1:5

% Import country info

filename = [inpath '/P' num2str(j) '.csv'];
delimiter = ',';
formatSpec = '%*s%*s%*s%*s%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
ctry_list = dataArray{:, 1};
% Clear temporary variables
clearvars formatSpec fileID dataArray ans;

% Drop first entry
ctry_list(1) = [];
ctry_list_tbl = tabulate(ctry_list);

ctry_cutoffs = cell2mat(ctry_list_tbl(:,2));
ctry_cutoffs_cums = cumsum(ctry_cutoffs);
ctry_cutoffs_cums = [0; ctry_cutoffs_cums]; % For loop unrolling

% Loop over countries

for i = 1:numel(ctry_cutoffs)
tStart = tic;   
    if i == 1
        ctry_start_row = 2;
    else
        ctry_start_row = ctry_cutoffs_cums(i)+2;
    end
    
    ctry_no_row = ctry_cutoffs(i);
    ctry_name = char(ctry_list_tbl(i,1));

formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, ctry_no_row, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', ctry_start_row-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,125,126,127,128,129]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end

rawNumericColumns = raw(:, [1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,125,126,127,128,129]);
rawStringColumns = string(raw(:, [5,34,124]));

R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

for catIdx = [1,2,3]
    idx = (rawStringColumns(:, catIdx) == "<undefined>");
    rawStringColumns(idx, catIdx) = "";
end

id = cell2mat(rawNumericColumns(:, 1));
hid = cell2mat(rawNumericColumns(:, 2));
survey = cell2mat(rawNumericColumns(:, 3));
SA0010 = cell2mat(rawNumericColumns(:, 4));
SA0100 = categorical(rawStringColumns(:, 1));
IM0100 = cell2mat(rawNumericColumns(:, 5));
RA0010 = cell2mat(rawNumericColumns(:, 6));
PA0100 = cell2mat(rawNumericColumns(:, 7));
fPA0100 = cell2mat(rawNumericColumns(:, 8));
PA0200 = cell2mat(rawNumericColumns(:, 9));
fPA0200 = cell2mat(rawNumericColumns(:, 10));
PE0100a = cell2mat(rawNumericColumns(:, 11));
fPE0100a = cell2mat(rawNumericColumns(:, 12));
PE0100b = cell2mat(rawNumericColumns(:, 13));
fPE0100b = cell2mat(rawNumericColumns(:, 14));
PE0100c = cell2mat(rawNumericColumns(:, 15));
fPE0100c = cell2mat(rawNumericColumns(:, 16));
PE0100d = cell2mat(rawNumericColumns(:, 17));
fPE0100d = cell2mat(rawNumericColumns(:, 18));
PE0100e = cell2mat(rawNumericColumns(:, 19));
fPE0100e = cell2mat(rawNumericColumns(:, 20));
PE0100f = cell2mat(rawNumericColumns(:, 21));
fPE0100f = cell2mat(rawNumericColumns(:, 22));
PE0100g = cell2mat(rawNumericColumns(:, 23));
fPE0100g = cell2mat(rawNumericColumns(:, 24));
PE0100h = cell2mat(rawNumericColumns(:, 25));
fPE0100h = cell2mat(rawNumericColumns(:, 26));
PE0100i = cell2mat(rawNumericColumns(:, 27));
fPE0100i = cell2mat(rawNumericColumns(:, 28));
PE0200 = cell2mat(rawNumericColumns(:, 29));
fPE0200 = cell2mat(rawNumericColumns(:, 30));
PE0300 = cell2mat(rawNumericColumns(:, 31));
fPE0300 = cell2mat(rawNumericColumns(:, 32));
PE0400 = categorical(rawStringColumns(:, 2));
fPE0400 = cell2mat(rawNumericColumns(:, 33));
PE0500 = cell2mat(rawNumericColumns(:, 34));
fPE0500 = cell2mat(rawNumericColumns(:, 35));
PE0600 = cell2mat(rawNumericColumns(:, 36));
fPE0600 = cell2mat(rawNumericColumns(:, 37));
PE0700 = cell2mat(rawNumericColumns(:, 38));
fPE0700 = cell2mat(rawNumericColumns(:, 39));
PE0800 = cell2mat(rawNumericColumns(:, 40));
fPE0800 = cell2mat(rawNumericColumns(:, 41));
PE0810 = cell2mat(rawNumericColumns(:, 42));
fPE0810 = cell2mat(rawNumericColumns(:, 43));
PE0900 = cell2mat(rawNumericColumns(:, 44));
fPE0900 = cell2mat(rawNumericColumns(:, 45));
PE1000 = cell2mat(rawNumericColumns(:, 46));
fPE1000 = cell2mat(rawNumericColumns(:, 47));
PE1100 = cell2mat(rawNumericColumns(:, 48));
fPE1100 = cell2mat(rawNumericColumns(:, 49));
PE9020 = cell2mat(rawNumericColumns(:, 50));
fPE9020 = cell2mat(rawNumericColumns(:, 51));
PF0100 = cell2mat(rawNumericColumns(:, 52));
fPF0100 = cell2mat(rawNumericColumns(:, 53));
PF0110 = cell2mat(rawNumericColumns(:, 54));
fPF0110 = cell2mat(rawNumericColumns(:, 55));
PF0200 = cell2mat(rawNumericColumns(:, 56));
fPF0200 = cell2mat(rawNumericColumns(:, 57));
PF0300 = cell2mat(rawNumericColumns(:, 58));
fPF0300 = cell2mat(rawNumericColumns(:, 59));
PF0400 = cell2mat(rawNumericColumns(:, 60));
fPF0400 = cell2mat(rawNumericColumns(:, 61));
PF0500 = cell2mat(rawNumericColumns(:, 62));
fPF0500 = cell2mat(rawNumericColumns(:, 63));
PF0510 = cell2mat(rawNumericColumns(:, 64));
fPF0510 = cell2mat(rawNumericColumns(:, 65));
PF0600 = cell2mat(rawNumericColumns(:, 66));
fPF0600 = cell2mat(rawNumericColumns(:, 67));
PF0610 = cell2mat(rawNumericColumns(:, 68));
fPF0610 = cell2mat(rawNumericColumns(:, 69));
PF0700 = cell2mat(rawNumericColumns(:, 70));
fPF0700 = cell2mat(rawNumericColumns(:, 71));
PF0710 = cell2mat(rawNumericColumns(:, 72));
fPF0710 = cell2mat(rawNumericColumns(:, 73));
PF0800 = cell2mat(rawNumericColumns(:, 74));
fPF0800 = cell2mat(rawNumericColumns(:, 75));
PF0900 = cell2mat(rawNumericColumns(:, 76));
fPF0900 = cell2mat(rawNumericColumns(:, 77));
PF0910a = cell2mat(rawNumericColumns(:, 78));
fPF0910a = cell2mat(rawNumericColumns(:, 79));
PF0910b = cell2mat(rawNumericColumns(:, 80));
fPF0910b = cell2mat(rawNumericColumns(:, 81));
PF0920 = cell2mat(rawNumericColumns(:, 82));
fPF0920 = cell2mat(rawNumericColumns(:, 83));
PF0930 = cell2mat(rawNumericColumns(:, 84));
fPF0930 = cell2mat(rawNumericColumns(:, 85));
PF9020 = cell2mat(rawNumericColumns(:, 86));
fPF9020 = cell2mat(rawNumericColumns(:, 87));
PG0100 = cell2mat(rawNumericColumns(:, 88));
fPG0100 = cell2mat(rawNumericColumns(:, 89));
PG0110 = cell2mat(rawNumericColumns(:, 90));
fPG0110 = cell2mat(rawNumericColumns(:, 91));
PG0200 = cell2mat(rawNumericColumns(:, 92));
fPG0200 = cell2mat(rawNumericColumns(:, 93));
PG0210 = cell2mat(rawNumericColumns(:, 94));
fPG0210 = cell2mat(rawNumericColumns(:, 95));
PG0300 = cell2mat(rawNumericColumns(:, 96));
fPG0300 = cell2mat(rawNumericColumns(:, 97));
PG0310 = cell2mat(rawNumericColumns(:, 98));
fPG0310 = cell2mat(rawNumericColumns(:, 99));
PG0400 = cell2mat(rawNumericColumns(:, 100));
fPG0400 = cell2mat(rawNumericColumns(:, 101));
PG0410 = cell2mat(rawNumericColumns(:, 102));
fPG0410 = cell2mat(rawNumericColumns(:, 103));
PG0500 = cell2mat(rawNumericColumns(:, 104));
fPG0500 = cell2mat(rawNumericColumns(:, 105));
PG0510 = cell2mat(rawNumericColumns(:, 106));
fPG0510 = cell2mat(rawNumericColumns(:, 107));
PG9020 = cell2mat(rawNumericColumns(:, 108));
fPG9020 = cell2mat(rawNumericColumns(:, 109));
RA0020 = cell2mat(rawNumericColumns(:, 110));
fRA0020 = cell2mat(rawNumericColumns(:, 111));
RA0030 = cell2mat(rawNumericColumns(:, 112));
fRA0030 = cell2mat(rawNumericColumns(:, 113));
RA0040 = cell2mat(rawNumericColumns(:, 114));
fRA0040 = cell2mat(rawNumericColumns(:, 115));
RA0100 = cell2mat(rawNumericColumns(:, 116));
fRA0100 = cell2mat(rawNumericColumns(:, 117));
RA0200 = cell2mat(rawNumericColumns(:, 118));
fRA0200 = cell2mat(rawNumericColumns(:, 119));
RA0300 = cell2mat(rawNumericColumns(:, 120));
fRA0300 = cell2mat(rawNumericColumns(:, 121));
RA0400 = categorical(rawStringColumns(:, 3));
fRA0400 = cell2mat(rawNumericColumns(:, 122));
RA0500 = cell2mat(rawNumericColumns(:, 123));
fRA0500 = cell2mat(rawNumericColumns(:, 124));
ra0300_B = cell2mat(rawNumericColumns(:, 125));
fra0300_b = cell2mat(rawNumericColumns(:, 126));

% Clear temporary variables
clearvars endRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns R catIdx idx;

% Save as mat file
save([outpath '/' ctry_name '_P' num2str(j) '.mat'])

fprintf('Finished implicate %d for %s\n',j,ctry_name); 

tEnd = toc(tStart);
fprintf('Needed %d minute(s) and %.2f seconds\n', floor(tEnd/60), rem(tEnd,60));

fprintf('\n')

end

end
