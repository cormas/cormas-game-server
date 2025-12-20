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

{ #category : 'instance creation' }
CMGameClient class >> fromWebSocket: aSocket [

	^ self new
		webSocket: aSocket;
		yourself
]

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

{ #category : 'parsing' }
CMGameClient >> parseJSON: aString [

	^ STONJSON fromString: aString
]

{ #category : 'protocol' }
CMGameClient >> readMessage [
	
	| raw data |
	
	raw := webSocket readMessage. "blocks until a frame arrives or socket closes"
	
	data := [ self parseJSON: raw ] onErrorDo: [ :e |
		self log: ('Bad JSON from ', name, ': ', e printString).
		nil ].
	
	^ data
]

{ #category : 'as yet unclassified' }
CMGameClient >> readNameFromHandshake [
	"Expect a hello frame with a name, with timeout"
	
	| helloRaw helloMsg |
	
	helloRaw := [ webSocket readMessage ]
		valueWithin: 5 seconds
		onTimeout: [
			[ webSocket sendMessage: 'Handshake timeout: send {"type":"bonjour","name":"..."} first' ]
				onErrorDo: [ :e | self log: e ].
			webSocket close.
			^ self ].
		
	helloMsg := [ self parseJSON: helloRaw ] onErrorDo: [ :err |
		[ webSocket sendMessage: 'Bad JSON in handshake' ] onErrorDo: [ :e | self log: e ].
		webSocket close.
		^ self ].
	
	((helloMsg at: 'type' ifAbsent: [ nil ]) = 'bonjour') ifFalse: [ 
		[ webSocket sendMessage: 'First message must be {"type":"bonjour","name":"..."}' ]
			onErrorDo: [ :e | self log: e ].
		webSocket close.
		^ self ].
	
	name := helloMsg at: 'name' ifAbsent: [
		[ webSocket sendMessage: 'First message must be {"type":"bonjour","name":"..."}' ]
			onErrorDo: [ :e | self log: e ].
		webSocket close.
		^ self ]
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
