"
Extended C8Emulator class for more variable access, and utility methods for simpler testing
"
Class {
	#name : #C8EmulatorForTests,
	#superclass : #C8Emulator,
	#category : #'Chip8-Testing'
}

{ #category : #accessing }
C8EmulatorForTests >> dataRegister [ 
	^ dataRegister
]

{ #category : #accessing }
C8EmulatorForTests >> delayTimer [ 
	
	^ delayTimer
]

{ #category : #accessing }
C8EmulatorForTests >> delayTimer: aNumber [

	delayTimer := aNumber 
]

{ #category : #emulation }
C8EmulatorForTests >> doOpcode: aNumber [

	memory 
		at: pc + 1	put: ((aNumber bitShift: -8) bitAnd: 16rFF);
		at: pc + 2 	put: (aNumber bitAnd: 16rFF).
			
	self doInstruction
]

{ #category : #emulation }
C8EmulatorForTests >> handleUnknownOpcode [

	self error
]

{ #category : #initialization }
C8EmulatorForTests >> initialize [

	super initialize.
	
	random := 0.
]

{ #category : #initialization }
C8EmulatorForTests >> loadFontSet [ 
	"nop"
]

{ #category : #accessing }
C8EmulatorForTests >> memory [ 
	^ memory
]

{ #category : #accessing }
C8EmulatorForTests >> memoryPointer [ 
	^ memoryPointer
]

{ #category : #accessing }
C8EmulatorForTests >> memoryPointer: aNumber [ 

	memoryPointer := aNumber
]

{ #category : #accessing }
C8EmulatorForTests >> programCounter [

	^ pc
]

{ #category : #emulation }
C8EmulatorForTests >> rand [

	^ random
]

{ #category : #accessing }
C8EmulatorForTests >> registerF [

	^ dataRegister at: 16
]

{ #category : #initialization }
C8EmulatorForTests >> setKeyboardStateTo: aNumber [

	keyboard instVarNamed: #state put: aNumber 
]

{ #category : #initialization }
C8EmulatorForTests >> setNextRandom: aNumber [

	random := aNumber
]

{ #category : #accessing }
C8EmulatorForTests >> soundTimer [ 

	^ soundTimer
]

{ #category : #accessing }
C8EmulatorForTests >> stack [

	^ stack
]
