"
Abstract graphics class for the chip8 emulator implementing the neccesary api.

checking for collision also resets it, as it is meant to only be checked within a draw instruction.


"
Class {
	#name : #C8Graphics,
	#superclass : #Object,
	#instVars : [
		'redraw',
		'collision'
	],
	#category : #'Chip8-Core'
}

{ #category : #converting }
C8Graphics >> asForm [

	self subclassResponsibility 
]

{ #category : #operations }
C8Graphics >> clearRedraw [

	redraw := false
]

{ #category : #operations }
C8Graphics >> clearScreen [

	self setDrawFlag
]

{ #category : #accessing }
C8Graphics >> collision [

	| tmp |
	
	tmp := collision asBit.
	collision := false.
	
	^ tmp 
]

{ #category : #drawing }
C8Graphics >> drawByte: aByte at: aPosition [

	self subclassResponsibility 
]

{ #category : #initialization }
C8Graphics >> initialize [

	super initialize.
	
	redraw := true.
	collision := false.
]

{ #category : #accessing }
C8Graphics >> redraw [

	^ redraw  
]

{ #category : #operations }
C8Graphics >> setDrawFlag [

	redraw := true
]
