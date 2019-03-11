%% Saves the HFCS Derived datasets (Imputations 1-5) as mat files

% Fun will now commence
close all; clear; clc;

% Set paths
inpath = '/Users/main/OneDrive - Istituto Universitario Europeo/data/HFCS/files/HFCS_UDB_2_1_ASCII';
outpath = '/Users/main/OneDrive - Istituto Universitario Europeo/data/HFCS/files/wave2_mat';

%% Import country data for the different implicates

% Loop over imputations

for j = 1:5

% Import country info

filename = [inpath '/D' num2str(j) '.csv'];
delimiter = ',';
formatSpec = '%*s%*s%*s%C%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
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

formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, ctry_no_row, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,ctry_start_row-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);

% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127]
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

% Split data into numeric and string columns.
rawNumericColumns = raw(:, [1,2,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127]);
rawStringColumns = string(raw(:, 4));

% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
idx = (rawStringColumns(:, 1) == "<undefined>");
rawStringColumns(idx, 1) = "";

% Allocate imported array to column variable names
ID = cell2mat(rawNumericColumns(:, 1));
survey = cell2mat(rawNumericColumns(:, 2));
SA0010 = cell2mat(rawNumericColumns(:, 3));
SA0100 = categorical(rawStringColumns(:, 1));
IM0100 = cell2mat(rawNumericColumns(:, 4));
HW0010 = cell2mat(rawNumericColumns(:, 5));
DWHOHO = cell2mat(rawNumericColumns(:, 6));
DHAGEH1B = cell2mat(rawNumericColumns(:, 7));
DH0001 = cell2mat(rawNumericColumns(:, 8));
DH0006 = cell2mat(rawNumericColumns(:, 9));
DH0004 = cell2mat(rawNumericColumns(:, 10));
DHHTYPE = cell2mat(rawNumericColumns(:, 11));
DH0002 = cell2mat(rawNumericColumns(:, 12));
DA1110 = cell2mat(rawNumericColumns(:, 13));
DA1120 = cell2mat(rawNumericColumns(:, 14));
DA1121 = cell2mat(rawNumericColumns(:, 15));
DA1130 = cell2mat(rawNumericColumns(:, 16));
DA1131 = cell2mat(rawNumericColumns(:, 17));
DA1140 = cell2mat(rawNumericColumns(:, 18));
DA2101 = cell2mat(rawNumericColumns(:, 19));
DA2102 = cell2mat(rawNumericColumns(:, 20));
DA2103 = cell2mat(rawNumericColumns(:, 21));
DA2104 = cell2mat(rawNumericColumns(:, 22));
DA2105 = cell2mat(rawNumericColumns(:, 23));
DA2106 = cell2mat(rawNumericColumns(:, 24));
DA2107 = cell2mat(rawNumericColumns(:, 25));
DA2108 = cell2mat(rawNumericColumns(:, 26));
DA2109 = cell2mat(rawNumericColumns(:, 27));
DL1110 = cell2mat(rawNumericColumns(:, 28));
DL1120 = cell2mat(rawNumericColumns(:, 29));
DL1200 = cell2mat(rawNumericColumns(:, 30));
DL1100 = cell2mat(rawNumericColumns(:, 31));
DL2100 = cell2mat(rawNumericColumns(:, 32));
DL2110 = cell2mat(rawNumericColumns(:, 33));
DL2200 = cell2mat(rawNumericColumns(:, 34));
DL2000 = cell2mat(rawNumericColumns(:, 35));
DI1412 = cell2mat(rawNumericColumns(:, 36));
DI1100 = cell2mat(rawNumericColumns(:, 37));
DI1200 = cell2mat(rawNumericColumns(:, 38));
DI1300 = cell2mat(rawNumericColumns(:, 39));
DI1400 = cell2mat(rawNumericColumns(:, 40));
DI1500 = cell2mat(rawNumericColumns(:, 41));
DI1600 = cell2mat(rawNumericColumns(:, 42));
DI1700 = cell2mat(rawNumericColumns(:, 43));
DA1000 = cell2mat(rawNumericColumns(:, 44));
DA1200 = cell2mat(rawNumericColumns(:, 45));
DA1400 = cell2mat(rawNumericColumns(:, 46));
DA2100 = cell2mat(rawNumericColumns(:, 47));
DA3001 = cell2mat(rawNumericColumns(:, 48));
DL1000 = cell2mat(rawNumericColumns(:, 49));
DI2000 = cell2mat(rawNumericColumns(:, 50));
DN3001 = cell2mat(rawNumericColumns(:, 51));
DA1000i = cell2mat(rawNumericColumns(:, 52));
DA2100i = cell2mat(rawNumericColumns(:, 53));
DA1110i = cell2mat(rawNumericColumns(:, 54));
DA1120i = cell2mat(rawNumericColumns(:, 55));
DA1121i = cell2mat(rawNumericColumns(:, 56));
DA1130i = cell2mat(rawNumericColumns(:, 57));
DA1131i = cell2mat(rawNumericColumns(:, 58));
DA1140i = cell2mat(rawNumericColumns(:, 59));
DA1400i = cell2mat(rawNumericColumns(:, 60));
DA1200i = cell2mat(rawNumericColumns(:, 61));
DA2101i = cell2mat(rawNumericColumns(:, 62));
DA2102i = cell2mat(rawNumericColumns(:, 63));
DA2103i = cell2mat(rawNumericColumns(:, 64));
DA2104i = cell2mat(rawNumericColumns(:, 65));
DA2105i = cell2mat(rawNumericColumns(:, 66));
DA2106i = cell2mat(rawNumericColumns(:, 67));
DA2107i = cell2mat(rawNumericColumns(:, 68));
DA2108i = cell2mat(rawNumericColumns(:, 69));
DA2109i = cell2mat(rawNumericColumns(:, 70));
DL1000i = cell2mat(rawNumericColumns(:, 71));
DL1100i = cell2mat(rawNumericColumns(:, 72));
DL1110i = cell2mat(rawNumericColumns(:, 73));
DL1120i = cell2mat(rawNumericColumns(:, 74));
DL1200i = cell2mat(rawNumericColumns(:, 75));
DODARATIO = cell2mat(rawNumericColumns(:, 76));
DODIRATIO = cell2mat(rawNumericColumns(:, 77));
DODSTOTAL = cell2mat(rawNumericColumns(:, 78));
DODSTOTAL40P = cell2mat(rawNumericColumns(:, 79));
DODSMORTG = cell2mat(rawNumericColumns(:, 80));
DHAQ01 = cell2mat(rawNumericColumns(:, 81));
DHNQ01 = cell2mat(rawNumericColumns(:, 82));
DHIQ01 = cell2mat(rawNumericColumns(:, 83));
DI1300i = cell2mat(rawNumericColumns(:, 84));
DA1122 = cell2mat(rawNumericColumns(:, 85));
DA1122i = cell2mat(rawNumericColumns(:, 86));
DATOP10 = cell2mat(rawNumericColumns(:, 87));
DHHST = cell2mat(rawNumericColumns(:, 88));
DI1100i = cell2mat(rawNumericColumns(:, 89));
DI1200i = cell2mat(rawNumericColumns(:, 90));
DI1400i = cell2mat(rawNumericColumns(:, 91));
DI1500i = cell2mat(rawNumericColumns(:, 92));
DI1600i = cell2mat(rawNumericColumns(:, 93));
DI1700i = cell2mat(rawNumericColumns(:, 94));
DI1800 = cell2mat(rawNumericColumns(:, 95));
DI1800i = cell2mat(rawNumericColumns(:, 96));
DITOP10 = cell2mat(rawNumericColumns(:, 97));
DL1231 = cell2mat(rawNumericColumns(:, 98));
DL1231i = cell2mat(rawNumericColumns(:, 99));
DODIRATIOM = cell2mat(rawNumericColumns(:, 100));
DATOP10EA = cell2mat(rawNumericColumns(:, 101));
DITOP10EA = cell2mat(rawNumericColumns(:, 102));
DL1210 = cell2mat(rawNumericColumns(:, 103));
DL1210i = cell2mat(rawNumericColumns(:, 104));
DL1220 = cell2mat(rawNumericColumns(:, 105));
DL1220i = cell2mat(rawNumericColumns(:, 106));
DL1230 = cell2mat(rawNumericColumns(:, 107));
DL1230i = cell2mat(rawNumericColumns(:, 108));
DL2000i = cell2mat(rawNumericColumns(:, 109));
DL2100i = cell2mat(rawNumericColumns(:, 110));
DL2110i = cell2mat(rawNumericColumns(:, 111));
DL2120 = cell2mat(rawNumericColumns(:, 112));
DL2120i = cell2mat(rawNumericColumns(:, 113));
DL2200i = cell2mat(rawNumericColumns(:, 114));
DL2210 = cell2mat(rawNumericColumns(:, 115));
DL2210i = cell2mat(rawNumericColumns(:, 116));
DNTOP10EA = cell2mat(rawNumericColumns(:, 117));
DODSTOTALp = cell2mat(rawNumericColumns(:, 118));
DODSTOTAL40Pp = cell2mat(rawNumericColumns(:, 119));
DL1232 = cell2mat(rawNumericColumns(:, 120));
DL1232i = cell2mat(rawNumericColumns(:, 121));
DHAGEH1 = cell2mat(rawNumericColumns(:, 122));
DHEDUH1 = cell2mat(rawNumericColumns(:, 123));
DHEMPH1 = cell2mat(rawNumericColumns(:, 124));
DHGENDERH1 = cell2mat(rawNumericColumns(:, 125));
DHIDH1 = cell2mat(rawNumericColumns(:, 126));

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
