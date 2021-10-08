"
Morph do draw the bitmap produced by a Chip8Emulator.

"
Class {
	#name : #C8Morph,
	#superclass : #Morph,
	#instVars : [
		'chip',
		'colorMap',
		'running',
		'ips'
	],
	#category : #'Chip8-Morphic'
}

{ #category : #examples }
C8Morph class >> example [

	| program emulator |

	"C8Programs downloadGamesPackZophar."
	"program := C8Programs programNamed: 'ZopharPack:PONG'."
	program := C8Programs repository atRandom.

	emulator := C8Emulator new.
	emulator loadProgram: program.

	emulator asMorph 
		extent: 800@600;
		primaryColor: Color gray;
		secondaryColor: Color black;
		disabledColor: (Color orange alpha: 0.3);
		instructionsPerStep: 10;
		openInWindow;
		takeKeyboardFocus
]

{ #category : #initialization }
C8Morph >> chip: aChip [

	chip := aChip 
]

{ #category : #'event handling' }
C8Morph >> clearKeyboardState [ 

	chip keyboard clear
]

{ #category : #initialization }
C8Morph >> defaultColor [

	^ Color orange alpha: 0.3
]

{ #category : #accessing }
C8Morph >> disabledColor: aColor [

	self color: aColor
]

{ #category : #drawing }
C8Morph >> drawOn: aCanvas [

	| form clipRect destRect |
	
	form := chip display asForm.	
	destRect := self innerBounds translateBy: aCanvas origin.	
	clipRect := aCanvas clipRect translateBy: aCanvas origin.
	
	chip display clearRedraw.	
		
	(WarpBlt toForm: aCanvas form)	
		clipBy: clipRect;	
		sourceForm: form;
		colorMap: colorMap;
		cellSize: 1;
		combinationRule: Form over;
		copyQuad: form boundingBox innerCorners toRect: destRect.
	
	running ifFalse: [ super drawOn: aCanvas ]
]

{ #category : #initialization }
C8Morph >> grayAndBlack [

	self 
		primaryColor: Color gray;
		secondaryColor: Color black
]

{ #category : #'event handling' }
C8Morph >> handlesKeyboard: evt [ 

	^ true
]

{ #category : #'event handling' }
C8Morph >> handlesMouseDown: event [
	^ true

]

{ #category : #initialization }
C8Morph >> initialize [

	super initialize.
	colorMap := Bitmap new: 2.
	running := false. 
	ips := 1.
	self grayAndBlack
]

{ #category : #accessing }
C8Morph >> instructionsPerStep: aNumber [

	ips := aNumber 
]

{ #category : #'event handling' }
C8Morph >> keyDown: anEvent [

	chip keyboard keyDown: anEvent keyCharacter asLowercase 
]

{ #category : #'event handling' }
C8Morph >> keyUp: anEvent [
		
	chip keyboard keyUp: anEvent keyCharacter asLowercase 
]

{ #category : #'event handling' }
C8Morph >> keyboardFocusChange: gotFocus [
	
	(running := gotFocus) 
		ifTrue: [ self startStepping ]
		ifFalse: [ self clearKeyboardState; stopStepping ]
]

{ #category : #'event handling' }
C8Morph >> mouseDown: event [

	self takeKeyboardFocus
]

{ #category : #accessing }
C8Morph >> primaryColor: aColor [

	colorMap at: 1 put: (aColor pixelValueForDepth: 32).
	self changed.
]

{ #category : #accessing }
C8Morph >> secondaryColor: aColor [

	colorMap at: 2 put: (aColor pixelValueForDepth: 32).
	self changed.
]

{ #category : #'stepping and presenter' }
C8Morph >> stepAt: aTimestamp [

	ips timesRepeat: [ chip doInstruction ].
	
	chip tickTimers.
	chip display redraw ifTrue: [ self changed ].
]

{ #category : #'stepping and presenter' }
C8Morph >> stepTime [

	^ 20
]

{ #category : #'stepping and presenter' }
C8Morph >> wantsSteps [

	^ false
]
