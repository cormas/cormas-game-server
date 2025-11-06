Class {
	#name : 'CMGameServer',
	#superclass : 'Object',
	#instVars : [
		'server',
		'clients',
		'mutex',
		'whenDataReceivedBlock',
		'whenClientConnectedBlock',
		'whenClientDisconnectedBlock'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'as yet unclassified' }
CMGameServer >> broadcast: aDictionaryOrString [

	| message |
	message := self toJSONString: aDictionaryOrString.
	
	mutex critical: [ 
		clients keysAndValuesDo: [ :clientId :ws |
			[ ws sendMessage: message ] onErrorDo: [ :e |
				self log: ('Broadcast error to ', clientId asString, ': ', e printString) ] ] ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> clientIdFrom: ws ifAbsent: anAbsentBlock [

	"Expect a hello frame with an id, with timeout"
	| helloRaw helloMsg |
	
	helloRaw := [ ws readMessage ]
		valueWithin: 5 seconds
		onTimeout: [
			[ ws sendMessage: 'Handshake timeout: send {"type":"bonjour","id":"..."} first' ]
				onErrorDo: [ :e | self log: e ].
			ws close.
			^ self ].
		
	helloMsg := [ self parseJSON: helloRaw ] onErrorDo: [ :err |
		[ ws sendMessage: 'Bad JSON in handshape' ] onErrorDo: [ :e | self log: e ].
		ws close.
		^ self ].
	
	((helloMsg at: 'type' ifAbsent: [ nil ]) = 'bonjour') ifFalse: [ 
		[ ws sendMessage: 'First message must be {"type":"bonjour","id":"..."}' ]
			onErrorDo: [ :e | self log: e ].
		ws close.
		^ self ].
	
	^ helloMsg at: 'id' ifAbsent: [ UUID new asString ]
	
]

{ #category : 'as yet unclassified' }
CMGameServer >> closeAllClients [
	mutex critical: [ 
		clients valuesDo: [ :ws | [ ws close ] onErrorDo: [ :e | self log: e ] ].
		clients removeAll ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> connectedClientIds [

	^ mutex critical: [ clients keys asArray ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> handleWebSocket: ws [
	| clientId |
	clientId := self clientIdFrom: ws ifAbsent: [ UUID new asString ].
	
	"Register or replace existing socket for this clientId"
	mutex critical: [ 
		clients at: clientId ifPresent: [ :previousSocket |
			[ previousSocket close ] onErrorDo: [ :e |
				self log: 'Error closing previous socket for ', clientId asString, ': ', e printString ] ].
		
		clients at: clientId put: ws ].
	
	[ whenClientConnectedBlock value: clientId ] onErrorDo: [ :e | self log: e ].

	"Main read loop for this connection"
	[ 
		[ ws isConnected ] whileTrue: [ 
			| raw data |
			raw := ws readMessage. "blocks until a frame arrives or socket closes"
			data := [ self parseJSON: raw ] onErrorDo: [ :e |
				self log: ('Bad JSON from ', clientId asString, ': ', e printString).
				nil ].
			
			data ifNotNil: [ whenDataReceivedBlock value: data value: clientId ] ]
	] ensure: [ 
		"Unregister only if this ws is still the current one for clientId (avoid racing with a fast reconnection)"
		mutex critical: [ 
			(clients at: clientId ifAbsent: [ nil ]) == ws ifTrue: [ 
				clients removeKey: clientId ifAbsent: [ "do nothing" ] ] ].
		
		 [ whenClientDisconnectedBlock value: clientId ] onErrorDo: [ :e | self log: e ] ]
]

{ #category : 'initialization' }
CMGameServer >> initialize [

	super initialize.
	mutex := Mutex new.
	clients := Dictionary new.
	
	"Use setter method to replace this block with a custom callback to process the game input"
	whenDataReceivedBlock := [ :data :clientId | self log: ('[',  clientId asString, '] :', data asString) ].
	whenClientConnectedBlock := [ :clientId | self log: ('Client connected: ', clientId asString) ].
	whenClientDisconnectedBlock := [ :clientId | self log: ('Client disconnected: ', clientId asString) ].
]

{ #category : 'logging' }
CMGameServer >> log: anObject [

	anObject asString traceCr
]

{ #category : 'parsing' }
CMGameServer >> parseJSON: aString [

	^ STONJSON fromString: aString
]

{ #category : 'as yet unclassified' }
CMGameServer >> send: aDictionaryOrString toClient: aClientId [

	| message socket |
	message := self toJSONString: aDictionaryOrString.
	
	socket := clients at: aClientId ifAbsent: [ 
		^ self log: ('No such client: ', aClientId) ].
	
	[ socket sendMessage: message ] onErrorDo: [ :e |
		self log: ('Send error to ', aClientId asString, ': ', e printString) ]
]

{ #category : 'accessing' }
CMGameServer >> startOn: aPortNumber [
	"Start HTTP server with a WebSocket endpoint at /ws."
	server ifNotNil: [ self error: 'Already running!' ].
	
	server := ZnServer startOn: aPortNumber.
	self log: ('Started a server at localhost:', aPortNumber asString).

	server delegate: (ZnWebSocketDelegate
		map: '/ws'
		to: [ :ws | self handleWebSocket: ws ]).
	
	"server delegate: (ZnWebSocketDelegate
		map: '/ws'
		to: [ :ws | 
			allowed := false.
			
			mutex critical: [ 
				(socket isNil or: [ socket isConnected not ]) ifTrue: [ 
					socket := ws.
					allowed := true ] ].
			
			allowed ifFalse: [ 
				[ ws sendMessage: 'Server is busy. Only one client allowed' ] onErrorDo: [ :e | self log: e ].
				ws close.
				^ self ].
			
			self log: 'Client connected'.
			
			[ 
				[ ws isConnected ] whileTrue: [ 
					whenDataReceivedBlock value: (STONJSON fromString: ws readMessage) ]
			] ensure: [ 
				self log: 'Client disconnected'.
				mutex critical: [ socket := nil ] ] ])"
	
]

{ #category : 'accessing' }
CMGameServer >> stop [
	server ifNil: [ ^ self ].
	[ self closeAllClients ] onErrorDo: [ :e | self log: e ].
	server stop.
	server := nil.
]

{ #category : 'as yet unclassified' }
CMGameServer >> toJSONString: anObject [

	^ STONJSON toString: anObject
]

{ #category : 'enumerating' }
CMGameServer >> whenClientConnectedDo: aBlock [
	"aBlock: [ :clientId | ... ]"
	whenClientConnectedBlock := aBlock
]

{ #category : 'enumerating' }
CMGameServer >> whenClientDisconnectedDo: aBlock [
	"aBlock: [ :clientId | ... ]"
	whenClientDisconnectedBlock := aBlock
]

{ #category : 'enumerating' }
CMGameServer >> whenDataReceivedDo: aBlock [
	"aBlock: [ :data :clientId | ... ]"
	whenDataReceivedBlock := aBlock
]
