private
printCodeForExampleMethod: aCompiledMethod on: aStream
	"Print the code concerning the example from #aCompiledMethod method on #aStream."
	
	| lines |
	lines := aCompiledMethod sourceCode lines.

	aStream
		<< '```';
		<< Character lf.
	lines allButFirst allButFirst do: [ :line |
		aStream
			<< line;
			<< Character lf ].
	aStream
		<< '```';
		<< Character lf.