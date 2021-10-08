"
C8Emulator is an emulator for the interpreted language CHIP-8.
https://en.wikipedia.org/wiki/CHIP-8

"
Class {
	#name : #C8Emulator,
	#superclass : #Object,
	#instVars : [
		'display',
		'pc',
		'opcode',
		'stack',
		'memory',
		'delayTimer',
		'soundTimer',
		'random',
		'memoryPointer',
		'dataRegister',
		'keyboard'
	],
	#category : #'Chip8-Tag'
}

{ #category : #morphic }
C8Emulator >> asMorph [

	^ C8Morph new 
		chip: self;
		yourself
]

{ #category : #accessing }
C8Emulator >> display [

	^ display 
]

{ #category : #accessing }
C8Emulator >> display: aDisplay [

	display := aDisplay 
]

{ #category : #emulation }
C8Emulator >> doInstruction [
	
	| mop |

	opcode := ((memory at: pc + 1) bitShift: 8) + (memory at: pc + 2).
	"opcode printStringHex crLog."
	mop := opcode bitShift: -12.	
		
	mop < 8
		ifTrue: [ self lowInstruction: mop ]
		ifFalse: [ self highInstruction: mop ].
		
]

{ #category : #initialization }
C8Emulator >> fontSet [

	^ #[	
		  16rF0 16r90 16r90 16r90 16rF0 
        16r20 16r60 16r20 16r20 16r70 
        16rF0 16r10 16rF0 16r80 16rF0 
        16rF0 16r10 16rF0 16r10 16rF0 
        16r90 16r90 16rF0 16r10 16r10 
        16rF0 16r80 16rF0 16r10 16rF0 
        16rF0 16r80 16rF0 16r90 16rF0 
        16rF0 16r10 16r20 16r40 16r40 
        16rF0 16r90 16rF0 16r90 16rF0 
        16rF0 16r90 16rF0 16r10 16rF0 
        16rF0 16r90 16rF0 16r90 16r90 
        16rE0 16r90 16rE0 16r90 16rE0 
        16rF0 16r80 16r80 16r80 16rF0 
        16rE0 16r90 16r90 16r90 16rE0 
        16rF0 16r80 16rF0 16r80 16rF0 
        16rF0 16r80 16rF0 16r80 16r80
	]
]

{ #category : #emulation }
C8Emulator >> handleUnknownOpcode [

	self error
]

{ #category : #emulation }
C8Emulator >> highInstruction: aNumber [

	aNumber == 8  ifTrue: [ ^ self instruction8xyn ].
	aNumber == 9  ifTrue: [ ^ self instruction9xy0 ].
	aNumber == 10 ifTrue: [ ^ self instructionAnnn ].
	aNumber == 11 ifTrue: [ ^ self instructionBnnn ].
	aNumber == 12 ifTrue: [ ^ self instructionCxnn ].
	aNumber == 13 ifTrue: [ ^ self instructionDxyn ].
	aNumber == 14 ifTrue: [ ^ self instructionExnn ].
	aNumber == 15 ifTrue: [ ^ self instructionFxnn ].
	
	self error: 'Should not happen'
]

{ #category : #emulation }
C8Emulator >> incrementPC [

	pc := pc + 2
]

{ #category : #initialization }
C8Emulator >> initialize [

	super initialize.
	
	memory := ByteArray new: 4096 withAll: 0.	
	dataRegister := ByteArray new: 16 withAll: 0.	
	stack := OrderedCollection new: 16.
	
	display := C8BitmapByteGraphics new.
	keyboard := C8Keyboard new.
	
	pc := 16r200.
	opcode := 0.
	memoryPointer := 0.
	
	delayTimer := 0.
	soundTimer := 0.
	
	random := Random new.	
		
	self loadFontSet.

]

{ #category : #instructions }
C8Emulator >> instruction0nnn [ 

	| mop |
	
	mop := opcode bitAnd: 16rF.
	
	(mop == 16r0000) ifTrue: [ " 00E0 | Display | Clear the screen "
		display clearScreen.
		^ self incrementPC.

	].

	mop = 16r000E ifTrue: [ " 000E | Flow | Return from subroutine "
		pc := stack removeLast + 2.		
		^ self		
	].

	self handleUnknownOpcode.	
	


]

{ #category : #instructions }
C8Emulator >> instruction1nnn [

	" 1NNN | Flow | Jump to address NNN "

	pc := self opcodeNNN.
	
	pc < 16r200 ifTrue: [ self error ].
]

{ #category : #instructions }
C8Emulator >> instruction2nnn [
	
	" 2NNN | Flow | Call subroutine at NNN "

	stack addLast: pc.	
	pc := self opcodeNNN.
	
	pc < 16r200 ifTrue: [ self error ].
]

{ #category : #instructions }
C8Emulator >> instruction3xnn [

	self incrementPC. 		
	self registerX = self opcode00FF ifTrue: [ self incrementPC ].
]

{ #category : #instructions }
C8Emulator >> instruction4xnn [

	self incrementPC.
	self registerX = self opcode00FF ifFalse: [ self incrementPC ]
]

{ #category : #instructions }
C8Emulator >> instruction5xy0 [
	
	self incrementPC.
	self registerX = self registerY ifTrue: [ self incrementPC ]
]

{ #category : #instructions }
C8Emulator >> instruction6xnn [

	self 
		registerX: self opcode00FF;
		incrementPC.

]

{ #category : #instructions }
C8Emulator >> instruction7xnn [
	
	self 
		registerX: self registerX + self opcode00FF;
		incrementPC

]

{ #category : #instructions }
C8Emulator >> instruction8xyn [

	| subcode |
	
	subcode := opcode bitAnd: 16r000F.
	
	subcode == 16rE ifTrue: [ 
		^ self 
			registerF: (self registerX >= 16r80) asBit;
			registerX: (self registerX bitShift: 1) ;
			incrementPC
	].

	subcode < 8 
		ifTrue: [ self incrementPC ]
		ifFalse: [ ^ self handleUnknownOpcode ].
	
	subcode == 0 ifTrue: [ ^ self registerX:  self registerY 									].
	subcode == 1 ifTrue: [ ^ self registerX: (self registerX bitOr:  self registerY)	].
	subcode == 2 ifTrue: [ ^ self registerX: (self registerX bitAnd: self registerY) 	].
	subcode == 3 ifTrue: [ ^ self registerX: (self registerX bitXor: self registerY) 	].
	
	subcode == 4 ifTrue: [ | result |
		result := self registerX + self registerY.
		^ self 
			registerF: (result > 16rFF) asBit;
			registerX: result.
	].
	subcode == 5 ifTrue: [ | result |
		result := self registerX - self registerY.
		^ self 
			registerF: result negative not asBit;
			registerX: result.
	].
	subcode == 6 ifTrue: [ 
		^ self 
			registerF: (self registerX bitAnd: 16r1);
			registerX: (self registerX bitShift: -1)
	].	
	subcode == 7 ifTrue: [ 
		self 
			registerF: (self registerX <= self registerY) asBit;
			registerX: (self registerY - self registerX)
	].
		


]

{ #category : #instructions }
C8Emulator >> instruction9xy0 [

	self registerX = self registerY ifFalse: [ self incrementPC ].
	self incrementPC.
	
	 
	

]

{ #category : #instructions }
C8Emulator >> instructionAnnn [

	memoryPointer := self opcodeNNN.
	self incrementPC.
	
	 
	

]

{ #category : #instructions }
C8Emulator >> instructionBnnn [

	pc := self opcodeNNN + (dataRegister at: 1)
	
	 
	

]

{ #category : #instructions }
C8Emulator >> instructionCxnn [
		
	self 
		registerX: (self rand bitAnd: opcode);
		incrementPC 

	
	
	
	 
	

]

{ #category : #instructions }
C8Emulator >> instructionDxyn [

	| x y height |	
	
	x := self registerX.
	y := self registerY.
	height := (opcode bitAnd: 16r000F).
		
	0 to: height - 1 do: [ :ix |
		display drawByte: (self memoryAt: ix) at: x @ (y + ix).
	].

	display setDrawFlag.
	
	self 
		incrementPC;
		registerF: display collision
		


	
	
	
	 
	

]

{ #category : #instructions }
C8Emulator >> instructionExnn [

	| masked |
	
	masked := self opcode00FF.
	
	masked == 16r9E ifTrue: [ 		
		(keyboard isKeyDownAt: self registerX) ifTrue: [ self incrementPC ].
		^ self incrementPC
	].
	
	masked == 16rA1 ifTrue: [ 
		(keyboard isKeyDownAt: self registerX) ifFalse: [ self incrementPC ].
		^ self incrementPC
	].
	
	self handleUnknownOpcode.

	
]

{ #category : #instructions }
C8Emulator >> instructionFxnn [

	| masked |
	
	masked := opcode bitAnd: 16rFF.
	
	masked == 16r7 ifTrue: [ " Get Timer | register[x] = delayTimer "
		^ self registerX: delayTimer; incrementPC
	].
	
	masked == 16rA ifTrue: [	" Wait for keypress "
		0 to: 15 do: [ :ix |
			(keyboard isKeyDownAt: ix) ifTrue: [ 
				^ self registerX: ix; incrementPC
			]
		].
		^ self  
	].
		
	masked == 16r15 ifTrue: [ 
		delayTimer := self registerX.
		^ self incrementPC	
	].

	masked == 16r18 ifTrue: [ 
		soundTimer := self registerX.
		^ self incrementPC	
	].

	masked == 16r1E ifTrue: [ 
		self registerF: ((memoryPointer + self registerX) > 16rFFF) asBit.
		memoryPointer := memoryPointer + self registerX.
		^ self incrementPC
	].	
	
	masked == 16r29 ifTrue: [ 
		memoryPointer := self registerX * 16r5.
		^ self incrementPC
	].
	
	masked == 16r33 ifTrue: [ | x |
		x := self registerX. 
		^ self 
			memoryAt: 0 put:  x // 100;
			memoryAt: 1 put: (x // 10) % 10;
			memoryAt: 2 put: (x % 100) % 10;
			incrementPC
	].
	
	masked == 16r55 ifTrue: [ 
		0 to: self opcodeX do: [ :ix | 
			self memoryAt: ix put: (dataRegister at: ix + 1) 
		].
		memoryPointer := memoryPointer + self opcodeX + 1.
		^ self incrementPC
	].
				 
	masked == 16r65 ifTrue: [ 
		0 to: self opcodeX do: [ :ix | 
			dataRegister at: ix + 1 put: (self memoryAt: ix) 
		].
		memoryPointer := memoryPointer + self opcodeX + 1.
		^ self incrementPC
	].
	
	self handleUnknownOpcode.

	
]

{ #category : #accessing }
C8Emulator >> keyboard [

	^ keyboard
]

{ #category : #loading }
C8Emulator >> loadFontSet [

	memory replaceFrom: 1 to: 80 with: self fontSet. 
]

{ #category : #loading }
C8Emulator >> loadProgram: aByteArray [

	memory replaceFrom: 513 to: 513 + aByteArray size - 1 with: aByteArray.
	
]

{ #category : #emulation }
C8Emulator >> lowInstruction: aNumber [

	aNumber == 0 ifTrue: [ ^ self instruction0nnn ].
	aNumber == 1 ifTrue: [ ^ self instruction1nnn ].
	aNumber == 2 ifTrue: [ ^ self instruction2nnn ].
	aNumber == 3 ifTrue: [ ^ self instruction3xnn ].
	aNumber == 4 ifTrue: [ ^ self instruction4xnn ].
	aNumber == 5 ifTrue: [ ^ self instruction5xy0 ].
	aNumber == 6 ifTrue: [ ^ self instruction6xnn ].
	aNumber == 7 ifTrue: [ ^ self instruction7xnn ].
	
	self error: 'Should not happen'
]

{ #category : #'private -accessing' }
C8Emulator >> memoryAt: anIndex [

	^ memory at: memoryPointer + anIndex + 1
]

{ #category : #'private -accessing' }
C8Emulator >> memoryAt: anIndex put: aNumber [

	memory at: memoryPointer + anIndex + 1 put: aNumber
]

{ #category : #opcode }
C8Emulator >> opcode00FF [

	^ opcode bitAnd: 16r00FF
]

{ #category : #opcode }
C8Emulator >> opcodeNNN [

	^ opcode bitAnd: 16r0FFF
]

{ #category : #opcode }
C8Emulator >> opcodeX [

	^ (opcode bitAnd: 16r0F00) bitShift: -8
]

{ #category : #opcode }
C8Emulator >> opcodeY [

	^ (opcode bitAnd: 16r00F0) bitShift: -4
]

{ #category : #emulation }
C8Emulator >> playSound [

	"Beeper primitiveBeep "
]

{ #category : #emulation }
C8Emulator >> rand [

	^ random nextInt: 16rFF
]

{ #category : #register }
C8Emulator >> registerF: aNumber [

	^ dataRegister at: 16 put: (aNumber bitAnd: 16rFF)
]

{ #category : #register }
C8Emulator >> registerX [

	^ dataRegister at: self opcodeX + 1
]

{ #category : #register }
C8Emulator >> registerX: aNumber [

	^ dataRegister at: self opcodeX + 1 put: (aNumber bitAnd: 16rFF)
]

{ #category : #register }
C8Emulator >> registerY [

	^ dataRegister at: self opcodeY + 1
]

{ #category : #register }
C8Emulator >> registerY: aNumber [

	^ dataRegister at: self opcodeY + 1 put: (aNumber bitAnd: 16rFF)
]

{ #category : #emulation }
C8Emulator >> tickTimers [

	delayTimer > 0 ifTrue: [ 
		delayTimer := delayTimer - 1	
	].

	soundTimer > 0 ifTrue: [ 
		soundTimer := soundTimer - 1.
		soundTimer = 0 ifTrue: [ self playSound ]
	]
]
