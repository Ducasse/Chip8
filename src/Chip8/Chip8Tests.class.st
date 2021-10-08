Class {
	#name : #Chip8Tests,
	#superclass : #TestCase,
	#instVars : [
		'chip'
	],
	#category : #'Chip8-Testing'
}

{ #category : #asserting }
Chip8Tests >> assertDataRegisterAt: anIndex equals: aNumber [

	self assert: (chip dataRegister at: anIndex + 1) equals: aNumber
]

{ #category : #asserting }
Chip8Tests >> assertErrorOnOpcode: aNumber [

	| pc |
	
	pc := chip programCounter.

	self 
		should: [ chip doOpcode: aNumber ] raise: Error;
		assert: pc equals: chip programCounter
]

{ #category : #'tests - math' }
Chip8Tests >> assertHighData: dataByte xor: xorByte pixelStart: aNumber equals: aByte [

	| shift result |
	
	shift := (aNumber \\ 8).
	
	result := dataByte bitXor: (xorByte bitShift: shift negated).
	
	self assert: result equals: aByte
]

{ #category : #'tests - math' }
Chip8Tests >> assertLowData: dataByte xor: xorByte pixelStart: aNumber equals: aByte [

	| shift result |
	
	shift := (aNumber \\ 8).
	
	result := dataByte bitXor: ((xorByte bitShift: 8 - shift) bitAnd: 16rFF).
	
	self assert: result equals: aByte
]

{ #category : #asserting }
Chip8Tests >> assertMemoryAt: anIndex equals: aNumber [

	self assert: (chip memory at: anIndex + 1) equals: aNumber
]

{ #category : #asserting }
Chip8Tests >> assertProgramCounterEquals: aNumber [

	self assert: chip programCounter equals: aNumber 
]

{ #category : #utilities }
Chip8Tests >> chipMemoryAt: aNumber put: aValue [

	chip memory at: aNumber + 1 put: aValue 
]

{ #category : #programs }
Chip8Tests >> program10to0Loop [

	^ C8Builder build: [ :program |
		program  
		"0"	setRegX: 2 to: 1; 
		"1"	call: 3;
		"2"	goto: 1; 
		"3"	setRegX: 1 to: 10; 
		"4"	regX: 1 equals: 0; 
		"5"	goto: 7; "false"
		"6"	return; "true"
		"7"	subRegY: 2 fromRegX: 1;
		"8"	goto: 4;
		"9"return "stack underflow"
	] 
]

{ #category : #initialization }
Chip8Tests >> setUp [

	chip := C8EmulatorForTests new.
]

{ #category : #'tests - program' }
Chip8Tests >> test10to0Loop [

	chip loadProgram: self program10to0Loop.
	
	100 timesRepeat: [ chip doInstruction ]

]

{ #category : #'tests - keyboard' }
Chip8Tests >> testAllKeysOnOff [

	| keyboard |
	keyboard := chip keyboard.
	keyboard quertyMapping do: [ :char |
		keyboard keyDown: char	
	].

	0 to: 15 do: [ :ix |
		self assert: (keyboard isKeyDownAt: ix)	
	].

	keyboard quertyMapping do: [ :char |
		keyboard keyUp: char	
	].

	0 to: 15 do: [ :ix |
		self deny: (keyboard isKeyDownAt: ix)	
	].
]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testAssignRegYtoRegX [
		
	chip 
		doOpcode: 16r6101;
		doOpcode: 16r620A;
		doOpcode: 16r8120.
		
	self assert: chip registerX equals: 10.
]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpAdd [

	chip 
		doOpcode: 16r6106;
		doOpcode: 16r8014.
		
	self 
		assert: chip registerX equals: 6;
		assert: chip registerF equals: 0.
	
	chip 
		doOpcode: 16r6A07; "set reg[A] to 7"
		doOpcode: 16r6B08; "set reg[B] to 8"
		doOpcode: 16r8AB4. "reg[A] + reg [B]"

	self 
		assert: chip registerX equals: 15;
		assert: chip registerF equals: 0.
		
	chip 
		doOpcode: 16r62AA;
		doOpcode: 16r8224.
		
	self 
		assert: chip registerX equals: (16rAA + 16rAA) & 16rFF;
		assert: chip registerF equals: 1.
		
]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpAnd [

	chip doOpcode: 16r6F0F.
	self assertDataRegisterAt: 16rF equals: 16r0F.
	chip doOpcode: 16r80F2.
	self 
		assert: chip opcodeX equals: 0;
		assert: chip opcodeY equals: 15;
		assert: chip registerX equals: 2r0000.	
	chip 
		doOpcode: 16r6A07; "set reg[A] to 7"
		doOpcode: 16r6B0B; "set reg[B] to 11"
		doOpcode: 16r8AB2. "reg[A] & reg [B]"

	self assert: chip registerX equals: 2r0011.
]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpOr [

	chip doOpcode: 16r6F0F.
	self assertDataRegisterAt: 16rF equals: 16r0F.
	chip doOpcode: 16r80F1.
	self 
		assert: chip opcodeX equals: 0;
		assert: chip opcodeY equals: 15;
		assert: chip registerX equals: 2r1111.
	chip 
		doOpcode: 16r6A03; "set reg[A] to 3"
		doOpcode: 16r6B08; "set reg[B] to 8"
		doOpcode: 16r8AB1. "reg[A] | reg [B]"
	self assert: chip registerX equals: 2r1011.
]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpShiftOneLeft [

	chip 
		doOpcode: 16r6101;
		doOpcode: 16r810E.
		
	self 
		assert: chip registerX equals: 2;
		assert: chip registerF equals: 0.

	chip 
		doOpcode: 16r6107; 
		doOpcode: 16r810E. 

	self 
		assert: chip registerX equals: 2r1110;
		assert: chip registerF equals: 0.
		
	chip 
		doOpcode: 16r6180; 
		doOpcode: 16r810E. 

	self 
		assert: chip registerX equals: 0;
		assert: chip registerF equals: 1.
	
	chip 
		doOpcode: 16r61FF; 
		doOpcode: 16r810E. 

	self 
		assert: chip registerX equals: 16rFE;
		assert: chip registerF equals: 1.


]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpShiftOneRight [

	chip 
		doOpcode: 16r6101;
		doOpcode: 16r8106.
		
	self 
		assert: chip registerX equals: 0;
		assert: chip registerF equals: 1.

	chip 
		doOpcode: 16r6A0E; 
		doOpcode: 16r8A06. 

	self 
		assert: chip registerX equals: 7;
		assert: chip registerF equals: 0.
		


]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpSub [

	chip 
		doOpcode: 16r6100;
		doOpcode: 16r8105.
		
	self 
		assert: chip registerX equals: 0;
		assert: chip registerF equals: 1.
	
	chip 
		doOpcode: 16r6A08; 
		doOpcode: 16r6B07; 
		doOpcode: 16r8AB5. 

	self 
		assert: chip registerX equals: 1;
		assert: chip registerF equals: 1.
		
	chip 
		doOpcode: 16r6200;
		doOpcode: 16r6301;
		doOpcode: 16r8235.
		
	self 
		assert: chip registerX equals: 255;
		assert: chip registerF equals: 0.

	chip 
		doOpcode: 16r62AA;
		doOpcode: 16r63CC;
		doOpcode: 16r8235.
		
	self 
		assert: chip registerX equals: 222;
		assert: chip registerF equals: 0.

]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpSubXfromY [

	chip 
		doOpcode: 16r6100;
		doOpcode: 16r8017.
		
	self 
		assert: chip registerX equals: 0;
		assert: chip registerF equals: 1.
	
	chip 
		doOpcode: 16r6A08; 
		doOpcode: 16r6B07; 
		doOpcode: 16r8BA7. 

	self 
		assert: chip registerX equals: 1;
		assert: chip registerF equals: 1.
		
	chip 
		doOpcode: 16r6200;
		doOpcode: 16r6301;
		doOpcode: 16r8327.
		
	self 
		assert: chip registerX equals: 255;
		assert: chip registerF equals: 0.

	chip 
		doOpcode: 16r62AA;
		doOpcode: 16r63CC;
		doOpcode: 16r8327.
		
	self 
		assert: chip registerX equals: 222;
		assert: chip registerF equals: 0.

		


]

{ #category : #'tests - 8nnn' }
Chip8Tests >> testBitOpXor [

	chip 
		doOpcode: 16r6F0F;
		doOpcode: 16r80F3.
		
	self assert: chip registerX equals: 2r1111.
		
	chip 
		doOpcode: 16r6A0E; "set reg[A] to 14"
		doOpcode: 16r6B07; "set reg[B] to 7"
		doOpcode: 16r8AB3. "reg[A] ^ reg [B]"

	self assert: chip registerX equals: 2r1001.
]

{ #category : #tests }
Chip8Tests >> testInstruction1nnn [

	chip doOpcode: 16r1FEF.
	self assert: chip programCounter equals: 16r0FEF.
	
	chip doOpcode: 16r1F00.	
	self assert: chip programCounter equals: 16r0F00 
]

{ #category : #tests }
Chip8Tests >> testInstruction2nnn [

	self assert: chip stack isEmpty.

	chip doOpcode: 16r2FEF.
	
	self 
		assert: chip programCounter equals: 16r0FEF;
		assert: chip stack size equals: 1. 
	
	chip doOpcode: 16r2F00.
		
	self 
		assert: chip programCounter equals: 16r0F00; 
		assert: chip stack size equals: 2. 
]

{ #category : #tests }
Chip8Tests >> testInstruction3nnn [

	| pc |
	pc := chip programCounter.

	chip 
		doOpcode: 16r6101;
		doOpcode: 16r3101.
	self assertProgramCounterEquals: pc + 2 + 4.
	
	chip doOpcode: 16r3100.	
	self assertProgramCounterEquals: pc + 6 + 2
]

{ #category : #tests }
Chip8Tests >> testInstruction4nnn [

	| pc |
	pc := chip programCounter.

	chip 
		doOpcode: 16r6101;
		doOpcode: 16r4101.	
	self assertProgramCounterEquals: pc + 2 + 2.
	
	chip doOpcode: 16r4100.
	self assertProgramCounterEquals: pc + 4 + 4
]

{ #category : #tests }
Chip8Tests >> testInstruction5nnn [

	| pc |
	pc := chip programCounter.

	chip 
		doOpcode: 16r6101;
		doOpcode: 16r6202;
		doOpcode: 16r5120.	
	self assertProgramCounterEquals: pc + 4 + 2.
	
	chip 
		doOpcode: 16r6101;
		doOpcode: 16r5120.
	self assertProgramCounterEquals: pc + 6 + 4
]

{ #category : #tests }
Chip8Tests >> testInstruction6nnn [

	0 to: 15 do: [ :ix |
		self assertDataRegisterAt: ix equals: 0.
		chip doOpcode: 16r6001 + ix + (ix bitShift: 8).
		self assertDataRegisterAt: ix equals: ix + 1
	].
]

{ #category : #tests }
Chip8Tests >> testInstruction7nnn [

	0 to: 15 do: [ :ix |
		chip dataRegister at: ix + 1 put: ix + 1.
		chip doOpcode: 16r7000 + ix + (ix bitShift: 8).
		self assertDataRegisterAt: ix equals: ix + ix + 1.
	].
]

{ #category : #tests }
Chip8Tests >> testInstruction9xy0 [

	| pc |
	chip doOpcode: 16r6101.
	pc := chip programCounter.
	chip doOpcode: 16r9100.
	self assert: pc + 4 equals: chip programCounter.
	
	chip doOpcode: 16r9110.
	self assert: pc + 4 + 2 equals: chip programCounter.
]

{ #category : #tests }
Chip8Tests >> testInstructionAnnn [

	chip doOpcode: 16rA123.
	self assert: chip memoryPointer equals: 16r0123.

	chip doOpcode: 16rA321.
	self assert: chip memoryPointer equals: 16r0321.
		

]

{ #category : #tests }
Chip8Tests >> testInstructionBnnn [

	self assertDataRegisterAt: 1 equals: 0.
	chip doOpcode: 16rB123.
	self assert: chip programCounter equals: 16r0123.
	
	chip dataRegister at: 1 put: 12.
	self assert: (chip dataRegister at: 1) equals: 12.
	
	chip doOpcode: 16rB123.
	self assert: chip programCounter equals: 16r0123 + 12.
		

]

{ #category : #tests }
Chip8Tests >> testInstructionCxnn [

	chip 
		setNextRandom: 16r99;
		doOpcode: 16rC177.
	
	self assertDataRegisterAt: 1 equals: 17
	
		

]

{ #category : #tests }
Chip8Tests >> testInstructionEx9E [

	| pc |
	pc := chip programCounter.
	chip doOpcode: 16rE09E.
	self assert: pc + 2 equals: chip programCounter.
	
	chip setKeyboardStateTo: 16rFF.
	pc := chip programCounter.
	chip doOpcode: 16rE09E.
	
	self assert: pc + 4 equals: chip programCounter.
	chip 
		doOpcode: 16r6201;
		setKeyboardStateTo: 16r01.
	
	pc := chip programCounter.
	chip doOpcode: 16rE29E.
	self assert: pc + 2 equals: chip programCounter.
]

{ #category : #tests }
Chip8Tests >> testInstructionExA1 [

	| pc |
	pc := chip programCounter.
	chip doOpcode: 16rE0A1.
	self assert: pc + 4 equals: chip programCounter.
	
	chip setKeyboardStateTo: 16rFF.
	
	pc := chip programCounter.
	chip doOpcode: 16rE0A1.
	self assert: pc + 2 equals: chip programCounter.
	
	chip 
		doOpcode: 16r6201;
		setKeyboardStateTo: 16r01.
	
	pc := chip programCounter.
	chip doOpcode: 16rE2A1.
	self assert: pc + 4 equals: chip programCounter.
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx07 [
	
	chip
		delayTimer: 60; 
		doOpcode: 16rF107.
		
	self assert: chip registerX equals: 60
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx15 [
	
	self assert: chip delayTimer equals: 0.
	chip 
		doOpcode: 16r610A;
		doOpcode: 16rF115.
	self assert: chip delayTimer equals: (16rA)
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx18 [
	
	self assert: chip soundTimer equals: 0.
	chip 
		doOpcode: 16r610A;
		doOpcode: 16rF118.
	self assert: chip soundTimer equals: (16rA)
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx1E [

	chip
		memoryPointer: 0;
		doOpcode: 16r61AC; 
		doOpcode: 16rF11E.
	
	self 
		assert: chip memoryPointer equals: 16rAC;
		assert: chip registerF equals: 0.
		
	chip 
		memoryPointer: 16r0F01;
		doOpcode: 16r61FF;
		doOpcode: 16rF11E.
	
	self 
		assert: chip memoryPointer equals: 16r00FF + 16r0F01;
		assert: chip registerF equals: 1.
	 
	
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx29 [

	chip
		doOpcode: 16r610A; 
		doOpcode: 16rF129.
	
	self assert: chip memoryPointer equals: 16rA * 16r5.
		
	chip 
		doOpcode: 16r6101;
		doOpcode: 16rF129.
	
	self assert: chip memoryPointer equals: 16r5

	 
	
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx33 [

	chip
		memoryPointer: 16r330;
		doOpcode: 16r617B; 
		doOpcode: 16rF133.
	
	self 
		assertMemoryAt: 16r330 equals: 1;
		assertMemoryAt: 16r331 equals: 2;
		assertMemoryAt: 16r332 equals: 3.
	
	chip
		doOpcode: 16r61CF; 
		doOpcode: 16rF133.
	
	self 
		assertMemoryAt: 16r330 equals: 2;
		assertMemoryAt: 16r331 equals: 0;
		assertMemoryAt: 16r332 equals: 7.
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx55 [

	1 to: 16 do: [ :ix |
		chip dataRegister at: ix put: ix
	].

	chip
		memoryPointer: 16r330; 
		doOpcode: 16rFF55.
	
	1 to: 16 do: [ :ix |
		self assertMemoryAt: 16r32F + ix equals: ix
	].

	self assert: chip memoryPointer equals: 16r330 + 16.
	
	chip dataRegister 
		at: 1 put: 5;
		at: 2 put: 10.
	
	chip
		memoryPointer: 16r330;
		doOpcode: 16rF055.
	
	self 
		assertMemoryAt: 16r330 equals: 5;
		assertMemoryAt: 16r331 equals: 2;
		assert: chip memoryPointer equals: 16r331
]

{ #category : #'tests - Fxyn' }
Chip8Tests >> testInstructionFx65 [

	0 to: 15 do: [ :ix |
		self chipMemoryAt: 16r330 + ix put: ix + 2
	].
		
	self assertDataRegisterAt: 7 equals: 0.
			
	chip
		memoryPointer: 16r330; 
		doOpcode: 16rFF65.
	
	0 to: 15 do: [ :ix |
		self assertDataRegisterAt: ix equals: ix + 2
	].

	self assert: chip memoryPointer equals: 16r330 + 16.
	
	self
		chipMemoryAt: 16r330 put: 5;
		chipMemoryAt: 16r331 put: 7.
	
	chip
		memoryPointer: 16r330;
		doOpcode: 16rF065.
	
	self 
		assertDataRegisterAt: 0 equals: 5;
		assertDataRegisterAt: 1 equals: 3;
		assert: chip memoryPointer equals: 16r331
]

{ #category : #'tests - keyboard' }
Chip8Tests >> testKeyboard [

	| keyboard |
	
	keyboard := chip keyboard.
	
	0 to: 15 do: [ :ix |
		self deny: (keyboard isKeyDownAt: ix)	
	].

	keyboard keyDown: $1.
	
	0 to: 15 do: [ :ix |
		self assert: (keyboard isKeyDownAt: ix)	equals: ix = 1
	].

	keyboard keyUp: $1.
	
	0 to: 15 do: [ :ix |
		self deny: (keyboard isKeyDownAt: ix)	
	].


]

{ #category : #'tests - math' }
Chip8Tests >> testSplitDraw [
	
	self 
		assertHighData: 2r10101010 xor: 2r10110011 pixelStart: 1 equals: 2r11110011;
		assertHighData: 2r10101010 xor: 2r10110011 pixelStart: 7 equals: 2r10101011;
			
		assertLowData: 	2r10101010 xor: 2r10110011 pixelStart: 1 equals: 2r00101010;		
		assertLowData: 	2r10101010 xor: 2r10110011 pixelStart: 7 equals: 2r11001100
]

{ #category : #'tests - errors' }
Chip8Tests >> testUnknownOpcode [

	#(16r0001 16r8008 16r800F 16rE000 16rE0FF 16rF000 16rF0FF) do: [ :op |
		self assertErrorOnOpcode: op
	].
]

{ #category : #'tests - math' }
Chip8Tests >> testXandYAccess [
	
	self 
	
		assert: 0 	\\ 8 equals: 0;
		assert: 8 	\\ 8 equals: 0;
		assert: 9 	\\ 8 equals: 1;
		assert: 56 	\\ 8 equals: 0;
		assert: 63 	\\ 8 equals: 7;
		
		assert: 0  	// 8 equals: 0;
		assert: 7  	// 8 equals: 0;
		assert: 8  	// 8 equals: 1;
		assert: 56 	// 8 equals: 7;
		assert: 63 	// 8 equals: 7.
		
		
]
