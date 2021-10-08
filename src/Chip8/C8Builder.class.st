"
incomplete program builder
"
Class {
	#name : #C8Builder,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Chip8-Testing'
}

{ #category : #building }
C8Builder class >> build: aBlock [

	| builder |
	
	builder := self new.
	aBlock value: builder.
	
	^ builder stream contents
]

{ #category : #adding }
C8Builder >> add: aNumber toRegX: xIndex [

	(aNumber between: 0 and: 16rFF) ifFalse: [ self error ].
	(xIndex between: 0 and: 15) ifFalse: [ self error ].
	
	stream uint16: (16r7000 + (xIndex << 8) + aNumber)
]

{ #category : #adding }
C8Builder >> addToMemPtr: xIndex [

	(xIndex between: 0 and: 15) ifFalse: [ self error ].
	
	stream uint16: 16rF01E + (xIndex << 8)
]

{ #category : #'as yet unclassified' }
C8Builder >> call: aNumber [ 

	| real |
	real := (aNumber * 2) + 16r200.
	real > 16rFFF ifTrue: [ self error ].
	
	stream uint16: 16r2000 + real
]

{ #category : #instructions }
C8Builder >> goto: aNumber [ 
	| real |
	real := (aNumber * 2) + 16r200.
	real > 16rFFF ifTrue: [ self error ].
	
	stream uint16: 16r1000 + real
]

{ #category : #initialization }
C8Builder >> initialize [

	super initialize.
	
	stream := #[] writeStream.
]

{ #category : #adding }
C8Builder >> regDump: xIndex [

	(xIndex between: 0 and: 15) ifFalse: [ self error ].
	
	stream uint16: 16rF055 + (xIndex << 8)
]

{ #category : #'as yet unclassified' }
C8Builder >> regX: aNumber equals: anotherNumber [

	(aNumber between: 0 and: 15) ifFalse: [ self error ].
	(anotherNumber between: 0 and: 16rFF) ifFalse: [ self error ].
	
	stream uint16: (16r3000 + (aNumber << 8) + anotherNumber)
	
	
]

{ #category : #'as yet unclassified' }
C8Builder >> regX: xIndex equalsRegY: yIndex [

	(xIndex between: 0 and: 15) ifFalse: [ self error ].
	(yIndex between: 0 and: 15) ifFalse: [ self error ].
	
	stream uint16: (16r5000 + (xIndex << 8) + (yIndex << 4))
	
	
]

{ #category : #'as yet unclassified' }
C8Builder >> regX: aNumber notEqual: anotherNumber [

	(aNumber between: 0 and: 15) ifFalse: [ self error ].
	(anotherNumber between: 0 and: 16rFF) ifFalse: [ self error ].
	
	stream uint16: (16r4000 + (aNumber << 8) + anotherNumber)
	
	
]

{ #category : #handling }
C8Builder >> return [

	stream uint16: 16r00EE
]

{ #category : #instructions }
C8Builder >> setRegX: xIndex to: aNumber [

	(xIndex between: 0 and: 15) ifFalse: [ self error ].
	(aNumber between: 0 and: 16rFF) ifFalse: [ self error ].
	
	stream uint16: (16r6000 + (xIndex << 8) + aNumber)
]

{ #category : #instructions }
C8Builder >> setRegX: xIndex toRegY: yIndex [

	(xIndex between: 0 and: 15) ifFalse: [ self error ].
	(yIndex between: 0 and: 15) ifFalse: [ self error ].
	
	stream uint16: (16r8000 + (xIndex << 8) + (yIndex << 4))
]

{ #category : #accessing }
C8Builder >> stream [

	^ stream
]

{ #category : #'as yet unclassified' }
C8Builder >> subRegY: xIndex fromRegX: yIndex [

	(xIndex between: 0 and: 15) ifFalse: [ self error ].
	(yIndex between: 0 and: 15) ifFalse: [ self error ].
	
	stream uint16: (16r8005 + (xIndex << 8) + (yIndex << 4))
	
	
]
