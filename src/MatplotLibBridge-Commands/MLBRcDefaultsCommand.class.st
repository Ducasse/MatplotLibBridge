"
I am a wrapper for the matplotlib.rcdefaults.

Restore the standard matplotlib default settings.
"
Class {
	#name : #MLBRcDefaultsCommand,
	#superclass : #MLBMatplotlibCommand,
	#category : #'MatplotLibBridge-Commands-Core'
}

{ #category : #accessing }
MLBRcDefaultsCommand >> functionName [
	^ 'rcdefaults'
]
