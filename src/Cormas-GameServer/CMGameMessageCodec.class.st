"
CMGameMessageCodec translates between JSON messages on the wire and domain objects (CMGameAction and CMGameOutput). It discovers message types from action/output subclasses and performs validation at the protocol boundary.
"
Class {
	#name : 'CMGameMessageCodec',
	#superclass : 'Object',
	#instVars : [
		'actionClassesByType',
		'outputClassesByType'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'as yet unclassified' }
CMGameMessageCodec class >> actionRootClass [

	^ CMGameAction
]

{ #category : 'as yet unclassified' }
CMGameMessageCodec class >> outputRootClass [

	^ CMGameOutput
]

{ #category : 'as yet unclassified' }
CMGameMessageCodec >> buildTypeIndexForRoot: aClass [

	| index type |
	index := Dictionary new.
	
	aClass allSubclassesDo: [ :each |
		type := [ each type ] on: SubclassResponsibility do: [ 
			self error: 'Class ', each name, ' does not implement type' ].
		
		(type isString and: [ type isNotEmpty ]) ifFalse: [ 
			self error: 'Invalid type for ', each name, '! It must be a non-empty string.' ].
		
		(index includesKey: type) ifTrue: [ 
			self error: 'Duplicate type ', type, ' for classes ', each name, ' and ', (index at: type) name ].
		
		index at: type put: each ].
	
	^ index
]

{ #category : 'as yet unclassified' }
CMGameMessageCodec >> decodeActionFromDictionary: aDictionary [

	| type actionClass payload |
	
	type := aDictionary
		at: 'type'
		ifAbsent: [ self error: 'Missing field: "type"!' ].
		
	actionClass := actionClassesByType
		at: type
		ifAbsent: [ self error: 'Unknown action type: ', type ].
		
	payload := aDictionary
		at: 'payload'
		ifAbsent: [ self error: 'Missing field: "payload"!' ].
		
	payload isDictionary
		ifFalse: [ self error: 'Payload must be a dictionary!' ].
	
	^ actionClass fromDictionary: payload
]

{ #category : 'as yet unclassified' }
CMGameMessageCodec >> decodeActionFromRawJson: aString [

	^ self decodeActionFromDictionary: (self parseJson: aString)
]

{ #category : 'as yet unclassified' }
CMGameMessageCodec >> encodeOutputToRawJson: aGameOutput [

	^ self toJsonString: aGameOutput asDictionary
]

{ #category : 'initialization' }
CMGameMessageCodec >> initialize [

	super initialize.
	
	actionClassesByType := self buildTypeIndexForRoot: self class actionRootClass.
	outputClassesByType := self buildTypeIndexForRoot: self class outputRootClass.
]

{ #category : 'parsing' }
CMGameMessageCodec >> parseJson: aString [

	^ STONJSON fromString: aString
]

{ #category : 'parsing' }
CMGameMessageCodec >> toJsonString: aDictionary [

	^ STONJSON toString: aDictionary
]
