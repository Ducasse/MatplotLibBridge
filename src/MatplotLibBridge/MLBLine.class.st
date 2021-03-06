"
I represent an abstract 2-dimensions line. I am used by certain kind of plots (e.g. MLBLinePlot).
"
Class {
	#name : #MLBLine,
	#superclass : #MLBVisitableObject,
	#instVars : [
		'style',
		'marker',
		'color',
		'label',
		'width'
	],
	#category : #'MatplotLibBridge-Model'
}

{ #category : #'instance creation' }
MLBLine class >> points: aListOfPoints [
	^ self new
		points: aListOfPoints;
		yourself
]

{ #category : #visiting }
MLBLine >> acceptVisitor: visitor [
	^ visitor visitMLBLine: self
]

{ #category : #private }
MLBLine >> alpha [
	^ self color alpha
]

{ #category : #accessing }
MLBLine >> color [
	^ color
]

{ #category : #accessing }
MLBLine >> color: anObject [
	color := anObject
]

{ #category : #private }
MLBLine >> colorHexString [
	^ '#' , self color asHexString
]

{ #category : #testing }
MLBLine >> hasLabel [
	^ self label isNotNil
]

{ #category : #initialization }
MLBLine >> initialize [
	super initialize.
	self
		color: Color black;
		width: 1.0
]

{ #category : #testing }
MLBLine >> isValidLineStyle: aString [
	^ self class isValidLineStyle: aString
]

{ #category : #testing }
MLBLine >> isValidMarker: aString [
	^ self class isValidMarker: aString
]

{ #category : #accessing }
MLBLine >> label [
	^ label
]

{ #category : #accessing }
MLBLine >> label: anObject [
	label := anObject
]

{ #category : #accessing }
MLBLine >> marker [
	^ marker
]

{ #category : #accessing }
MLBLine >> marker: anObject [
	marker := anObject asMLBMarkerStyle
]

{ #category : #accessing }
MLBLine >> style [
	^ style
]

{ #category : #accessing }
MLBLine >> style: anObject [
	style := anObject asMLBLineStyle
]

{ #category : #accessing }
MLBLine >> width [
	^ width
]

{ #category : #accessing }
MLBLine >> width: anObject [
	width := anObject
]

{ #category : #private }
MLBLine >> x [
	^ self subclassResponsibility
]

{ #category : #private }
MLBLine >> y [
	^ self subclassResponsibility
]
