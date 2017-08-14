clear all
close all

%% define parameters
% index to start proccessing data at
idxToStart = 1;
% whether or not we normalize data
normalizeTime = false;
normalizeWatch = false;
% whether or not we plot with views on the Y axis
plotViewsYAxisNormal = false;
plotViewsYAxisFirstDerivative = false;
% figure and axis background color
backgroundColor = [0.95 0.95 0.95];

%if(plotViewsYAxis)
%	if(normalizeWatch)
%		normalizeWatch = false;
%		disp('We cannot normalize the data and show the views, switching off watch normalization');
%	end
%end

%% read all of the input files

pathToOutputFiles = '../JavaCodebase/OutputFiles/*';
pathToOutputFilesNoAsterisk = '../JavaCodebase/OutputFiles/';

showData = struct;

showData.ShowType = {};
showData.ShowNumber = {};
showData.TimeCoder = {};
showData.Views = {};
showData.DatePublished = {};

showData.TimePercentage = {};
showData.WatchPercentage = {};

showData.TimeFirstDeriv = {};
showData.WatchFirstDeriv = {};

files = dir(pathToOutputFiles);

for fileIdx = 1:length(files)
	
	% get the retention rate data
	fileName = [pathToOutputFilesNoAsterisk files(fileIdx).name];
	
	array = csvread(fileName);	
	
	% parse the input file name to get information to use
	
	strings = strsplit(files(fileIdx).name,'_');
	
	showData.ShowType{end+1} = strings{1};
	showData.ShowNumber{end+1} = strings{2};
	showData.TimeCoder{end+1} = strings{3};
	showData.Views{end+1} = strings{4};
	showData.DatePublished{end+1} = strings{5};
	
	% first value read in is (0,0), we should set time 0 to be 100% viewership
	time = array(1:length(array),1);
	watch = array(1:length(array),2);	
	
	watch(1) = 1;
	
	if(normalizeTime)
		time = (time - min(time)) / ( max(time) - min(time) );
	end
	if(normalizeWatch)
		watch = (watch - min(watch)) / ( max(watch) - min(watch) );
	end
	
%	if(plotViewsYAxis)
%		watch = watch(idxToStart:length(watch)) * str2num(strings{4});
%	else
%		watch = watch(idxToStart:length(watch));
%	end
%		
%	showData.TimePercentage{end+1} = time;
%	showData.WatchPercentage{end+1} = watch;
%	
%	showData.TimeFirstDeriv{end+1} = time(2:length(time));
%	showData.WatchFirstDeriv{end+1} = diff(watch);
	
	showData.TimePercentage{end+1} = time;
	showData.TimeFirstDeriv{end+1} = time(2:length(time));
	
	if(plotViewsYAxisNormal)
		showData.WatchPercentage{end+1} = watch * str2num(strings{4});
	else
		showData.WatchPercentage{end+1} = watch;
	end
	
	if(plotViewsYAxisFirstDerivative)
		showData.WatchFirstDeriv{end+1} = diff(watch) * str2num(strings{4});
	else
		showData.WatchFirstDeriv{end+1} = diff(watch);
	end
	
end

% TODO: for each show type, do proper sort of order

%% plot each timeCoder's shows
% we can assume that the different shows will be grouped together based on the reading in
plotByTimecoder (showData,normalizeTime,normalizeWatch,plotViewsYAxisNormal,plotViewsYAxisFirstDerivative,backgroundColor);
plotByShowType  (showData,normalizeTime,normalizeWatch,plotViewsYAxisNormal,plotViewsYAxisFirstDerivative,backgroundColor);

%uniqueTimeCoderNames = unique(showData.TimeCoder);
%NumberOfLinesForEachUniqueTimeCoder = zeros(1,length(uniqueTimeCoderNames));
%% get number of colors for eachTimeCoder
%
%for timeCoderIdx = 1:length(uniqueTimeCoderNames)
%	% loop over the show data
%	for showDataIdx = 1:length(showData.ShowType)		
%		if strcmp(showData.TimeCoder{showDataIdx},uniqueTimeCoderNames{timeCoderIdx})			
%			NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx) = NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx) + 1;
%		end		
%	end
%end
%
%% plot the normal percentages
%for timeCoderIdx = 1:length(uniqueTimeCoderNames)
%	figure	
%	colors = hsv(NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx));
%	lineCounter = 1;
%	legendNames = {};
%	% loop over the show data
%	for showDataIdx = 1:length(showData.ShowType)		
%		if strcmp(showData.TimeCoder{showDataIdx},uniqueTimeCoderNames{timeCoderIdx})			
%			plot(showData.TimePercentage{showDataIdx},showData.WatchPercentage{showDataIdx},'color',colors(lineCounter,:),'linewidth',1);
%			lineCounter = lineCounter + 1;
%			legendNames{end+1} = [showData.ShowType{showDataIdx} ' ' showData.ShowNumber{showDataIdx}];
%			hold on;			
%			grid on;
%		end		
%	end
%	
%	set(gca,'color',backgroundColor);
%	set(gcf,'color',backgroundColor);
%	
%	title(uniqueTimeCoderNames{timeCoderIdx});
%	
%	if(normalizeTime)
%		xlabel('PercentageTimeWatched (Normalized)');
%	else
%		xlabel('PercentageTimeWatched');
%	end
%	if(normalizeWatch)
%		ylabel('AudienceRetention (Normalized)');
%	else
%		ylabel('AudienceRetention');
%	end
%	
%	legend(legendNames,'location','EastOutside');
%end
%
%% plot the derivative
%for timeCoderIdx = 1:length(uniqueTimeCoderNames)
%	figure	
%	colors = jet(NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx));
%	lineCounter = 1;
%	legendNames = {};
%	% loop over the show data
%	for showDataIdx = 1:length(showData.ShowType)		
%		if strcmp(showData.TimeCoder{showDataIdx},uniqueTimeCoderNames{timeCoderIdx})			
%			plot(showData.TimeFirstDeriv{showDataIdx},showData.WatchFirstDeriv{showDataIdx},'color',colors(lineCounter,:),'linewidth',1);
%			lineCounter = lineCounter + 1;
%			legendNames{end+1} = [showData.ShowType{showDataIdx} ' ' showData.ShowNumber{showDataIdx}];
%			hold on;			
%			grid on;
%		end		
%	end
%	
%	set(gca,'color',backgroundColor);
%	set(gcf,'color',backgroundColor);
%	
%	title([uniqueTimeCoderNames{timeCoderIdx} ' First Derivative' ]);
%	
%	if(normalizeTime)
%		xlabel('PercentageTimeWatched (Normalized)');
%	else
%		xlabel('PercentageTimeWatched');
%	end
%	if(normalizeWatch)
%		ylabel('AudienceRetention Derivative (Normalized)');
%	else
%		ylabel('AudienceRetention Derivative');
%	end
%	
%	legend(legendNames,'location','EastOutside');
%end


