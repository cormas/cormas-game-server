Class {
	#name : 'CMGameClient',
	#superclass : 'Object',
	#instVars : [
		'name',
		'webSocket',
		'role'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'connection open/close' }
CMGameClient >> disconnect [

	webSocket close
]

{ #category : 'testing' }
CMGameClient >> hasRole [

	^ role isRole
]

{ #category : 'initialization' }
CMGameClient >> initialize [

	super initialize.
	role := CMGameNoRole
]

{ #category : 'testing' }
CMGameClient >> isConnected [

	^ webSocket isNotNil and: [ webSocket isConnected ]
]

{ #category : 'logging' }
CMGameClient >> log: anObject [

	anObject asString traceCr
]

{ #category : 'accessing' }
CMGameClient >> name [

	^ name
]

{ #category : 'accessing' }
CMGameClient >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
CMGameClient >> role [

	^ role
]

{ #category : 'accessing' }
CMGameClient >> role: aRole [ 

	role := aRole
]

{ #category : 'protocol' }
CMGameClient >> sendMessage: aDictionaryOrString [

	| message |
	message := self toJSONString: aDictionaryOrString.

	[ webSocket sendMessage: message ] onErrorDo: [ :e |
		self log: ('Send error to ', name, ': ', e printString) ]

	
]

{ #category : 'as yet unclassified' }
CMGameClient >> sendRegisteredMessage [

	self sendMessage: '{"type": "registered", "payload": {"name": "', name, '"}}'.
]

{ #category : 'as yet unclassified' }
CMGameClient >> toJSONString: anObject [

	^ STONJSON toString: anObject
]

{ #category : 'accessing' }
CMGameClient >> webSocket: anObject [

	webSocket := anObject
]
