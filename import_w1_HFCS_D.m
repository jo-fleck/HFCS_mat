%% Saves the HFCS Derived datasets (Imputations 1-5) as mat files

% Fun will now commence
close all; clear; clc;

% Set paths
inpath = '/Users/main/OneDrive - Istituto Universitario Europeo/data/HFCS/files/HFCS_UDB_1_3_ASCII';
outpath = '/Users/main/OneDrive - Istituto Universitario Europeo/data/HFCS/files/wave1_mat';

%% Import country data for the different implicates

% Loop over imputations

for j = 1:5

% Import country info

filename = [inpath '/D' num2str(j) '.csv'];
delimiter = ',';
formatSpec = '%*s%*s%*s%C%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
ctry_list = dataArray{:, 1};
ctry_list = cellstr(ctry_list);
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

formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, ctry_no_row, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,ctry_start_row-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41]
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


%% Split data into numeric and string columns.
rawNumericColumns = raw(:, [1,2,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41]);
rawStringColumns = string(raw(:, 4));


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
idx = (rawStringColumns(:, 1) == "<undefined>");
rawStringColumns(idx, 1) = "";

%% Allocate imported array to column variable names
ID = cell2mat(rawNumericColumns(:, 1));
Survey = cell2mat(rawNumericColumns(:, 2));
SA0010 = cell2mat(rawNumericColumns(:, 3));
SA0100 = categorical(rawStringColumns(:, 1));
IM0100 = cell2mat(rawNumericColumns(:, 4));
DN3001 = cell2mat(rawNumericColumns(:, 5));
DH0001 = cell2mat(rawNumericColumns(:, 6));
DH0006 = cell2mat(rawNumericColumns(:, 7));
DH0004 = cell2mat(rawNumericColumns(:, 8));
DA1110 = cell2mat(rawNumericColumns(:, 9));
DA1120 = cell2mat(rawNumericColumns(:, 10));
DA1130 = cell2mat(rawNumericColumns(:, 11));
DA1131 = cell2mat(rawNumericColumns(:, 12));
DA1140 = cell2mat(rawNumericColumns(:, 13));
DA2101 = cell2mat(rawNumericColumns(:, 14));
DA2102 = cell2mat(rawNumericColumns(:, 15));
DA2103 = cell2mat(rawNumericColumns(:, 16));
DA2104 = cell2mat(rawNumericColumns(:, 17));
DA2105 = cell2mat(rawNumericColumns(:, 18));
DA2106 = cell2mat(rawNumericColumns(:, 19));
DA2107 = cell2mat(rawNumericColumns(:, 20));
DA2108 = cell2mat(rawNumericColumns(:, 21));
DA2109 = cell2mat(rawNumericColumns(:, 22));
DL1110 = cell2mat(rawNumericColumns(:, 23));
DL1120 = cell2mat(rawNumericColumns(:, 24));
DL1200 = cell2mat(rawNumericColumns(:, 25));
DL1100 = cell2mat(rawNumericColumns(:, 26));
DL2100 = cell2mat(rawNumericColumns(:, 27));
DL2110 = cell2mat(rawNumericColumns(:, 28));
DL2200 = cell2mat(rawNumericColumns(:, 29));
DL2000 = cell2mat(rawNumericColumns(:, 30));
DI1100 = cell2mat(rawNumericColumns(:, 31));
DI1200 = cell2mat(rawNumericColumns(:, 32));
DI1500 = cell2mat(rawNumericColumns(:, 33));
DI1600 = cell2mat(rawNumericColumns(:, 34));
DA1000 = cell2mat(rawNumericColumns(:, 35));
DA2100 = cell2mat(rawNumericColumns(:, 36));
DA3001 = cell2mat(rawNumericColumns(:, 37));
DL1000 = cell2mat(rawNumericColumns(:, 38));
DI2000 = cell2mat(rawNumericColumns(:, 39));
DHIDH1 = cell2mat(rawNumericColumns(:, 40));

% Clear temporary variables
clearvars formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns R catIdx idx;

% Save as mat file
save([outpath '/' ctry_name '_D' num2str(j) '.mat'])

fprintf('Finished implicate %d for %s\n',j,ctry_name); 

tEnd = toc(tStart);
fprintf('Needed %d minute(s) and %.2f seconds\n', floor(tEnd/60), rem(tEnd,60));

fprintf('\n')

end

end
