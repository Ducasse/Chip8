"
C8Programs is a storage class for programs that has been downloaded.


"
Class {
	#name : #C8Programs,
	#superclass : #Object,
	#classVars : [
		'Repository'
	],
	#category : #'Chip8-Tag'
}

{ #category : #'as yet unclassified' }
C8Programs class >> downloadGamesPackZophar [

	| link contentStream zip buffer |
	
	link := 'http://www.zophar.net/download_file/11688'.
	contentStream := (ZnEasy get: link) contents readStream.
	zip := ZipArchive new .
	zip readFrom: contentStream.
	
	buffer := (ByteArray new: 4096) readStream.
		
	zip members do: [ :member |
		member uncompressDataTo: buffer.
		self repository at: ('ZopharPack:', member fileName) put: member contents asByteArray.
		buffer reset
	].
	
]

{ #category : #accessing }
C8Programs class >> programNamed: aString [

	^ self repository at: aString
]

{ #category : #accessing }
C8Programs class >> repository [

	Repository ifNil: [ Repository := Dictionary new ].
	
	^ Repository 
	
]

{ #category : #accessing }
C8Programs class >> reset [

	Repository := nil.
]
