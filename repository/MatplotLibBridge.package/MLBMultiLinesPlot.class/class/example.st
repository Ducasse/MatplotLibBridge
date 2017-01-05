example
example
	| x y |
	x := (1 to: 10) collect: [ :i | { i . i . i } ].
	y := x collect: [ :i | {i first . i second ** 2 . i third log} ].
	MLBBridge importPyplot.
	MLBMultiLinesPlot new
		x: x;
		y: y;
		lineStyles: {'-' . '--' . 'dotted'};
		colors: {Color green . Color blue . Color red};
		show