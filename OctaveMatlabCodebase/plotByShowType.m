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
## @deftypefn {Function File} {@var{retval} =} plotByShowType (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: andre <andre@DESKTOP-QMVHGNS>
## Created: 2017-08-14

function plotByShowType(showData,normalizeTime,normalizeWatch,plotViewsYAxisNormal,plotViewsYAxisFirstDerivative,backgroundColor)

uniqueShowTypes = unique(showData.ShowType);
NumberOfLinesForEachUniqueuniqueShowTypes = zeros(1,length(uniqueShowTypes));
% get number of colors for eachuniqueShowTypes

for uniqueShowTypesIdx = 1:length(uniqueShowTypes)
	% loop over the show data
	for showDataIdx = 1:length(showData.ShowType)		
		if strcmp(showData.ShowType{showDataIdx},uniqueShowTypes{uniqueShowTypesIdx})			
			NumberOfLinesForEachUniqueuniqueShowTypes(uniqueShowTypesIdx) = NumberOfLinesForEachUniqueuniqueShowTypes(uniqueShowTypesIdx) + 1;
		end		
	end
end

% plot the normal percentages
for uniqueShowTypesIdx = 1:length(uniqueShowTypes)
	fig = figure;
	colors = hsv(NumberOfLinesForEachUniqueuniqueShowTypes(uniqueShowTypesIdx));
	lineCounter = 1;
	legendNames = {};
	% loop over the show data
	for showDataIdx = 1:length(showData.ShowType)		
		if strcmp(showData.ShowType{showDataIdx},uniqueShowTypes{uniqueShowTypesIdx})			
			plot(showData.TimePercentage{showDataIdx},showData.WatchPercentage{showDataIdx},'color',colors(lineCounter,:),'linewidth',1);
			lineCounter = lineCounter + 1;
			legendNames{end+1} = [showData.ShowType{showDataIdx} ' ' showData.ShowNumber{showDataIdx}];
			hold on;			
			grid on;
		end		
	end
	
	set(gca,'color',backgroundColor);
	set(fig,'color',backgroundColor);
	
	title(uniqueShowTypes{uniqueShowTypesIdx});
	
	xlabelString = 'PercentageTimeWatched';
	
	if(plotViewsYAxisNormal)
		xlabelString = [xlabelString ' by Viewers'];
	else
		xlabelString = [xlabelString ' by Percentage'];
	end	
	if(normalizeTime)
		xlabelString = [xlabelString '(Normalized)'];
	end	
	xlabel(xlabelString);
	
	if(normalizeWatch)
		ylabel('AudienceRetention (Normalized)');
	else
		ylabel('AudienceRetention');
	end
	
	legend(legendNames,'location','EastOutside');
	directory = pwd;
	print(fig,[directory '\Figures\' uniqueShowTypes{uniqueShowTypesIdx} '.png']);
	close(fig);
end

% plot the derivative
for uniqueShowTypesIdx = 1:length(uniqueShowTypes)
	fig = figure;
	colors = jet(NumberOfLinesForEachUniqueuniqueShowTypes(uniqueShowTypesIdx));
	lineCounter = 1;
	legendNames = {};
	% loop over the show data
	for showDataIdx = 1:length(showData.ShowType)		
		if strcmp(showData.ShowType{showDataIdx},uniqueShowTypes{uniqueShowTypesIdx})			
			plot(showData.TimeFirstDeriv{showDataIdx},showData.WatchFirstDeriv{showDataIdx},'color',colors(lineCounter,:),'linewidth',1);
			lineCounter = lineCounter + 1;
			legendNames{end+1} = [showData.ShowType{showDataIdx} ' ' showData.ShowNumber{showDataIdx}];
			hold on;			
			grid on;
		end		
	end
	
	set(gca,'color',backgroundColor);
	set(fig,'color',backgroundColor);
	
	title([uniqueShowTypes{uniqueShowTypesIdx} ' First Derivative' ]);
	
	xlabelString = 'PercentageTimeWatched';	
	xlabel(xlabelString);
	
	if(normalizeWatch)
		ylabel('AudienceRetention Derivative (Normalized)');
	else
		ylabel('AudienceRetention Derivative');
	end
	
	legend(legendNames,'location','EastOutside');
	directory = pwd;
	print(fig,[directory '\Figures\' uniqueShowTypes{uniqueShowTypesIdx} '_FirstDerivative.png']);
	close(fig);
end
endfunction
