"
Chip8Keyboard holds the current keyboard state. 
The keyboard uses a character map  with 16 characters that can be configured by changing the key mapping.
"
Class {
	#name : #C8Keyboard,
	#superclass : #Object,
	#instVars : [
		'state',
		'keymap'
	],
	#category : #'Chip8-Core'
}

{ #category : #'event handling' }
C8Keyboard >> clear [

	state := 0
]

{ #category : #initialization }
C8Keyboard >> defaultKeyMapping [

	^ self quertyMapping
]

{ #category : #initialization }
C8Keyboard >> initialize [

	super initialize.
	state := 0.
	keymap := self defaultKeyMapping
]

{ #category : #testing }
C8Keyboard >> isKeyDownAt: anIndex [

	^ (state bitAt: anIndex + 1) = 1
	
]

{ #category : #'event handling' }
C8Keyboard >> keyDown: aCharacter [
	
	| keyIndex |
	keyIndex := keymap indexOf: aCharacter ifAbsent: [ ^ self ].
	state := state bitAt: keyIndex put: 1
]

{ #category : #'event handling' }
C8Keyboard >> keyUp: aCharacter [
	
	| keyIndex |
	keyIndex := keymap indexOf: aCharacter ifAbsent: [ ^ self ].
	state := state bitAt: keyIndex put: 0
]

{ #category : #initialization }
C8Keyboard >> quertyMapping [
	
	^ #( $x $1 $2 $3 $q $w $e $a $s $d $z $c $4 $r $f $v )
]
