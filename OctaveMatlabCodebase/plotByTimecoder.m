## Copyright (C) 2017 andre
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} plotByTimecoder (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: andre <andre@DESKTOP-QMVHGNS>
## Created: 2017-08-14

function plotByTimecoder (showData,normalizeTime,normalizeWatch,plotViewsYAxisNormal,plotViewsYAxisFirstDerivative,backgroundColor)
	%% plot each timeCoder's shows
% we can assume that the different shows will be grouped together based on the reading in

uniqueTimeCoderNames = unique(showData.TimeCoder);
NumberOfLinesForEachUniqueTimeCoder = zeros(1,length(uniqueTimeCoderNames));
% get number of colors for eachTimeCoder

for timeCoderIdx = 1:length(uniqueTimeCoderNames)
	% loop over the show data
	for showDataIdx = 1:length(showData.ShowType)		
		if strcmp(showData.TimeCoder{showDataIdx},uniqueTimeCoderNames{timeCoderIdx})			
			NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx) = NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx) + 1;
		end		
	end
end

% plot the normal percentages
for timeCoderIdx = 1:length(uniqueTimeCoderNames)
	fig = figure;
	colors = hsv(NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx));
	lineCounter = 1;
	legendNames = {};
	% loop over the show data
	for showDataIdx = 1:length(showData.ShowType)		
		if strcmp(showData.TimeCoder{showDataIdx},uniqueTimeCoderNames{timeCoderIdx})			
			plot(showData.TimePercentage{showDataIdx},showData.WatchPercentage{showDataIdx},'color',colors(lineCounter,:),'linewidth',1);
			lineCounter = lineCounter + 1;
			legendNames{end+1} = [showData.ShowType{showDataIdx} ' ' showData.ShowNumber{showDataIdx}];
			hold on;			
			grid on;
		end		
	end
	
	set(gca,'color',backgroundColor);
	set(fig,'color',backgroundColor);
	
	title(uniqueTimeCoderNames{timeCoderIdx});
	
	xlabelString = 'PercentageTimeWatched';	
	xlabel(xlabelString);
	
	if(normalizeWatch)
		ylabel('AudienceRetention (Normalized)');
	else
		ylabel('AudienceRetention');
	end
	
	legend(legendNames,'location','EastOutside');
	
	directory = pwd;
	print(fig,[directory '\Figures\' uniqueTimeCoderNames{timeCoderIdx} '.png']);
	close(fig);
end

% plot the derivative
for timeCoderIdx = 1:length(uniqueTimeCoderNames)
	fig = figure;
	colors = jet(NumberOfLinesForEachUniqueTimeCoder(timeCoderIdx));
	lineCounter = 1;
	legendNames = {};
	% loop over the show data
	for showDataIdx = 1:length(showData.ShowType)		
		if strcmp(showData.TimeCoder{showDataIdx},uniqueTimeCoderNames{timeCoderIdx})			
			plot(showData.TimeFirstDeriv{showDataIdx},showData.WatchFirstDeriv{showDataIdx},'color',colors(lineCounter,:),'linewidth',1);
			lineCounter = lineCounter + 1;
			legendNames{end+1} = [showData.ShowType{showDataIdx} ' ' showData.ShowNumber{showDataIdx}];
			hold on;			
			grid on;
		end		
	end
	
	set(gca,'color',backgroundColor);
	set(fig,'color',backgroundColor);
	
	title([uniqueTimeCoderNames{timeCoderIdx} ' First Derivative' ]);
	
	xlabelString = 'PercentageTimeWatched';	
	xlabel(xlabelString);
	
	if(normalizeWatch)
		ylabel('AudienceRetention Derivative (Normalized)');
	else
		ylabel('AudienceRetention Derivative');
	end
	
	legend(legendNames,'location','EastOutside');
	directory = pwd;
	print(fig,[directory '\Figures\' uniqueTimeCoderNames{timeCoderIdx} '_FirstDerivative.png']);
	close(fig);
	
end

endfunction
