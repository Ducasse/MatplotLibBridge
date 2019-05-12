Class {
	#name : #MLBCommandListGenerator,
	#superclass : #MLBAbstractVisitor,
	#instVars : [
		'commandList'
	],
	#category : #'MatplotLibBridge-Visitors'
}

{ #category : #building }
MLBCommandListGenerator >> afterBuildingPlot: aMLBAbstractPlot [
	self commandList
		add: (MLBTitleCommand new
				s: aMLBAbstractPlot title;
				fontdict: aMLBAbstractPlot titleFontDict;
				loc: aMLBAbstractPlot titleLocation;
				yourself);
		add: (MLBAxis new
					v: aMLBAbstractPlot axis;
					yourself).
	aMLBAbstractPlot xAxis
		acceptVisitor: self.
	aMLBAbstractPlot yAxis
		acceptVisitor: self.
	aMLBAbstractPlot annotations do: [ :annotation |
		annotation acceptVisitor: self ].
	aMLBAbstractPlot gridOnAxis ifNotNil: [ 
		self commandList
			add: (MLBGridCommand new
						axis: aMLBAbstractPlot gridOnAxis;
						yourself) ]
]

{ #category : #building }
MLBCommandListGenerator >> beforeBuildingPlot: aMLBAbstractPlot [
	self commandList add: MLBClfCommand new.
	aMLBAbstractPlot style ifNotNil: [ :style | 
		style generateCommandsIn: self commandList ]
]

{ #category : #helper }
MLBCommandListGenerator >> buildPlot: plot withBeforeAfterHooks: aBlock [
	self beforeBuildingPlot: plot.
	aBlock value: plot.
	self afterBuildingPlot: plot
]

{ #category : #accessing }
MLBCommandListGenerator >> commandList [
	^ commandList
]

{ #category : #accessing }
MLBCommandListGenerator >> commandList: anObject [
	commandList := anObject
]

{ #category : #initialization }
MLBCommandListGenerator >> initialize [
	super initialize.
	self commandList: MLBCommandList new
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBAbstractAxis: aMLBAbstractAxis [
	|tempTicks|
	self commandList
		add: (aMLBAbstractAxis labelCommandClass new
					s: aMLBAbstractAxis title;
					yourself).
	tempTicks := aMLBAbstractAxis ticksCommandClass new
					rotation: aMLBAbstractAxis labelsRotation;
					yourself.
	aMLBAbstractAxis labels ifNotNil: [ 
		tempTicks
			ticks: (aMLBAbstractAxis ticks ifNil: [ (0 to: aMLBAbstractAxis labels size - 1) asArray ]);
			labels: aMLBAbstractAxis labels ].
	self commandList
		add: tempTicks.
	aMLBAbstractAxis scale ifNotNil: [ 
		self commandList
			add: (aMLBAbstractAxis scaleCommandClass new
						scale: aMLBAbstractAxis scale;
						yourself) ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBAnnotation: aMLBAnnotation [
	self visitMLBCommandsGenerator: aMLBAnnotation; flag: #TODO
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBBarPlot: aMLBBarPlot [
	self buildPlot: aMLBBarPlot withBeforeAfterHooks: [ :plot |
		self commandList
			add: (MLBBarCommand new
				left: (0 to: plot data size - 1);
				height: plot data;
				tick_label: plot labels;
				color: plot color;
				yerr: plot errorBars;
				ecolor: plot errorBarsColor;
				"Next line is due to some kind of hack in matplotlib to align labels on right edge."
				width: (plot isAlignLabelRightEdge ifTrue: [ plot barWidth negated ] ifFalse: [ plot barWidth ]);
				align: plot align;
				log: plot logAxis;
				yourself) ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBBoxPlot: aMLBBoxPlot [
	self buildPlot: aMLBBoxPlot withBeforeAfterHooks: [ :plot |
		plot isVertical
			ifTrue: [ 
				plot configXAxis: [ :x | x ticks: (1 to: x labels size) ] ]
			ifFalse: [ 
				plot configYAxis: [ :y | y ticks: (1 to: y labels size) ] ].
		self commandList
			add: (MLBBoxplotCommand new
						x: plot dataList;
						labels: plot labels;
						vert: plot vertical;
						yourself) ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBCommandsGenerator: aMLBCommandsGenerator [
	aMLBCommandsGenerator generateCommandsIn: self commandList
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBLegend: aMLBLegend [
	self visitMLBCommandsGenerator: aMLBLegend; flag: #TODO
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBLinePlot: aMLBLinePlot [
	self buildPlot: aMLBLinePlot withBeforeAfterHooks: [ :plot |
	plot lines do: [ :line |
		line acceptVisitor: self ].

	(plot lines anySatisfy: #hasLabel)
		ifTrue: [ 
			self commandList
				add: MLBLegendCommand new ].
	
	(plot legend isNotNil and: [ (plot lines anySatisfy: #hasLabel) ])
		ifTrue: [ plot legend acceptVisitor: self ] ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBPiePlot: aMLBPiePlot [
	self buildPlot: aMLBPiePlot withBeforeAfterHooks: [ :plot |
	self commandList
		add: (MLBPieCommand new
					x: plot data;
					labels: plot labels;
					shadow: plot hasShadow;
					explode: plot explode;
					startangle: plot startAngle;
					radius: plot radius;
					counterclock: plot isCounterClock;
					colors: plot colors;
					yourself) ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBPointsLine: aMLBPointsLine [
	self visitMLBCommandsGenerator: aMLBPointsLine; flag: #TODO
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBScatterPlot2: aMLBScatterPlots [
	self buildPlot: aMLBScatterPlots withBeforeAfterHooks: [ :plot |
	((plot data groupedBy: #marker) associations
		sorted: [ :a :b | 
			(plot markersOrder indexOf: a key) < (plot markersOrder indexOf: b key) ])
		do: [ :assoc |
			|marker scatterData|
			marker := assoc key.
			scatterData := assoc value.
			self commandList
			add:
				(MLBScatterCommand new
					x: (scatterData collect: #x);
					y: (scatterData collect: #y);
					s: (scatterData collect: #size);
					c: (scatterData collect: #color);
					marker: marker;
					yourself) ] ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBScatterPlot: aMLBScatterPlot [
	self buildPlot: aMLBScatterPlot withBeforeAfterHooks: [ :plot |
	self commandList
		add:
			(MLBScatterCommand new
				x: plot  x;
				y: plot  y;
				s: plot  pointSizes;
				c:
					(plot  colors isCollection
						ifTrue: [ plot  colors collect: [ :c | '#' , c asHexString ] ]
						ifFalse: [ '#' , plot  colors asHexString ]);
				yourself) ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBStackedBarPlot: aMLBStackedBarPlot [
	self buildPlot: aMLBStackedBarPlot withBeforeAfterHooks: [ :plot |
	self commandList
		add:
			(MLBBarCommand new
				left: (0 to: plot dataList size - 1);
				height: (plot dataList collect: #first);
				tick_label: plot labels;
				color: plot colorList first;
				yerr:
					(plot errorBarsList
						ifNotNil: [ :list | list collect: #first ]);
				ecolor:
					(plot errorBarsColorList
						ifNotNil: [ :list | list asOrderedCollection first ]);
				"Next line is due to some kind of hack in matplotlib to align labels on right edge."
				width: (plot isAlignLabelRightEdge ifTrue: [ plot barWidth negated ] ifFalse: [ plot barWidth ]);
				align: plot align;
				log: plot logAxis;
				yourself).
	2 to: plot dataList anyOne size do: [ :i | 
		self commandList
			add:
				(MLBBarCommand new
					left: (0 to: plot dataList size - 1);
					height: (plot dataList collect: [ :d | d at: i ]);
					bottom:
						(plot dataList
							collect: [ :d | ((1 to: i - 1) collect: [ :j | d at: j ]) sum ]);
					color: (plot colorList at: i);
					yerr:
						(plot errorBarsList
							ifNotNil: [ :list | list collect: [ :e | e at: i ] ]);
					ecolor:
						(plot errorBarsColorList
							ifNotNil: [ :list | (list asOrderedCollection at: i) asHexString ]);
					"Next line is due to some kind of hack in matplotlib to align labels on right edge."
					width: (plot isAlignLabelRightEdge ifTrue: [ plot barWidth negated ] ifFalse: [ plot barWidth ]);
					align: plot align;
					yourself) ] ]
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBStyleSheet: aMLBStyleSheet [
	self visitMLBCommandsGenerator: aMLBStyleSheet; flag: #TODO
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBXAxis: aMLBXAxis [
	self visitMLBAbstractAxis: aMLBXAxis.
	self commandList
		add: (aMLBXAxis limCommandClass new
				xmin: aMLBXAxis min;
				xmax: aMLBXAxis max;
				yourself)
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBXBlockLine: aMLBXBlockLine [
	self visitMLBCommandsGenerator: aMLBXBlockLine; flag: #TODO
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBYAxis: aMLBYAxis [
	self visitMLBAbstractAxis: aMLBYAxis.
	self commandList
		add: (aMLBYAxis limCommandClass new
				ymin: aMLBYAxis min;
				ymax: aMLBYAxis max;
				yourself)
]

{ #category : #visiting }
MLBCommandListGenerator >> visitMLBYBlockLine: aMLBYBlockLine [
	self visitMLBCommandsGenerator: aMLBYBlockLine; flag: #TODO
]