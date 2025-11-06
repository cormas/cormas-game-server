Class {
	#name : 'CMGameServer',
	#superclass : 'Object',
	#instVars : [
		'server',
		'socket',
		'mutex',
		'whenDataReceivedBlock'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'initialization' }
CMGameServer >> initialize [

	super initialize.
	mutex := Mutex new.
	
	"Use setter method to replace this block with a custom callback to process the game input"
	whenDataReceivedBlock := [ :data | self log: data ]
]

{ #category : 'logging' }
CMGameServer >> log: anObject [

	anObject asString traceCr
]

{ #category : 'accessing' }
CMGameServer >> start [
	"Start the server on localhost:8080 with a WebSocket at /ws.
	Only one client is allowed at a time."
	| allowed |
	
	server ifNotNil: [ self error: 'Already running!' ].
	
	server := ZnServer startOn: 8080.
	self log: 'Started a server at localhost:8080'.
	
	server delegate: (ZnWebSocketDelegate
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
				mutex critical: [ socket := nil ] ] ])
	
]

{ #category : 'accessing' }
CMGameServer >> startOn: aPortNumber [
	"Start the server on localhost:<aPortNumber> with a WebSocket at /ws.
	Only one client is allowed at a time."
	| allowed |
	
	server ifNotNil: [ self error: 'Already running!' ].
	
	server := ZnServer startOn: aPortNumber.
	self log: ('Started a server at localhost:', aPortNumber asString).
	
	server delegate: (ZnWebSocketDelegate
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
				mutex critical: [ socket := nil ] ] ])
	
]

{ #category : 'accessing' }
CMGameServer >> stop [

	server ifNil: [ ^ self ].
	[ socket ifNotNil: [ socket close ] ] onErrorDo: [ :e | self log: e ].
	server stop.
	server := nil.
	socket := nil
]

{ #category : 'callbacks' }
CMGameServer >> whenDataReceivedDo: aBlock [
	"A block defining what to do when data is received. Takes one argument - data represented as a Dictionary (JSON input).
	
	Example: server whenDataReceived: [ :data | agent moveTo: (model cellAt: (data at: 'cellId')) ]"
	whenDataReceivedBlock := aBlock
]
