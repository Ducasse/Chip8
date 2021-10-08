"
Chip8Graphics implemented as a bitmap where each word is accessed by a byte index.


"
Class {
	#name : #C8BitmapByteGraphics,
	#superclass : #C8Graphics,
	#instVars : [
		'bitmap'
	],
	#category : #'Chip8-Tag'
}

{ #category : #converting }
C8BitmapByteGraphics >> asForm [

	^ Form extent: 64 @ 32 depth: 1 bits: bitmap
]

{ #category : #drawing }
C8BitmapByteGraphics >> byteAt: byteIndex xorDraw: aByte [

	| currentByte xorByte |
	
	byteIndex > 256 ifTrue: [ ^ self ].
	currentByte := bitmap byteAt: byteIndex.
	xorByte := currentByte bitXor: aByte.
	
	bitmap byteAt: byteIndex put: xorByte.
	
	collision ifTrue: [ ^ self ].	
	collision := (currentByte bitAnd: xorByte) > 0.
]

{ #category : #'private - accessing' }
C8BitmapByteGraphics >> byteIndexFor: aPoint [

	^ ((aPoint x // 8) + ((aPoint y % 32) * 8 )) + 1
]

{ #category : #operations }
C8BitmapByteGraphics >> clearScreen [ 

	super clearScreen.
	
	bitmap atAllPut: 0
]

{ #category : #drawing }
C8BitmapByteGraphics >> drawByte: aByte at: aPosition [
	
	(aPosition x % 8) isZero 
		ifTrue: [ self byteAt: (self byteIndexFor: aPosition) xorDraw: aByte ]
		ifFalse: [ self drawSplitByte: aByte at: aPosition ]
]

{ #category : #drawing }
C8BitmapByteGraphics >> drawSplitByte: aByte at: aPosition [

	| byteIndex shift |
	
	byteIndex := self byteIndexFor: aPosition.
	shift := (aPosition x % 8).
	
	self 	
		byteAt: byteIndex 
		xorDraw: (aByte bitShift: shift negated);		
		byteAt: byteIndex + 1 
		xorDraw: ((aByte bitShift: 8 - shift) bitAnd: 16rFF)
]

{ #category : #initialization }
C8BitmapByteGraphics >> initialize [

	super initialize.
	
	bitmap := Bitmap new: 64 withAll: 0.

]
