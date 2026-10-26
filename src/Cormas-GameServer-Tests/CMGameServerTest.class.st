Class {
	#name : 'CMGameServerTest',
	#superclass : 'TestCase',
	#instVars : [
		'server'
	],
	#category : 'Cormas-GameServer-Tests',
	#package : 'Cormas-GameServer-Tests'
}

{ #category : 'as yet unclassified' }
CMGameServerTest >> clientNamed: aName [
	^ server clients detect: [ :each | each name = aName ]
]

{ #category : 'running' }
CMGameServerTest >> connect: aFakeWebSocket [
	server handleWebSocket: aFakeWebSocket.
	^ aFakeWebSocket
]

{ #category : 'running' }
CMGameServerTest >> register: aName on: aFakeWebSocket [
	(server instVarNamed: 'clients')
		at: aName
		put: ((CMGameClient fromWebSocket: aFakeWebSocket) name: aName; yourself)
]

{ #category : 'running' }
CMGameServerTest >> setUp [
	super setUp.
	server := CMGameServer new
]

{ #category : 'tests' }
CMGameServerTest >> testBonjourWithoutNameIsNotRegistered [
	| ws |
	ws := CMFakeWebSocket new.
	ws receive: (Dictionary new at: 'type' put: 'bonjour'; yourself).
	self connect: ws.
	self assert: server clients isEmpty
]

{ #category : 'tests' }
CMGameServerTest >> testDisconnectedPlayerStaysOffline [
	self connect: (CMFakeWebSocket sayingBonjour: 'alice').
	self assert: server clients size equals: 1.
	self deny: (self clientNamed: 'alice') isConnected
]

{ #category : 'tests' }
CMGameServerTest >> testEmptyNameIsNotRegistered [
	self connect: (CMFakeWebSocket sayingBonjour: '').
	self assert: server clients isEmpty
]

{ #category : 'tests' }
CMGameServerTest >> testReconnectClosesOldConnection [
	| old |
	old := CMFakeWebSocket new.
	self register: 'alice' on: old.
	self connect: (CMFakeWebSocket sayingBonjour: 'alice').
	(Delay forMilliseconds: 100) wait.
	self deny: old isConnected
]

{ #category : 'tests' }
CMGameServerTest >> testReconnectDoesNotTouchOtherPlayers [
	self connect: (CMFakeWebSocket sayingBonjour: 'alice').
	self connect: (CMFakeWebSocket sayingBonjour: 'bob').
	(self clientNamed: 'bob') role: CMGameRole.
	self connect: (CMFakeWebSocket sayingBonjour: 'alice').
	self assert: server clients size equals: 2.
	self assert: (self clientNamed: 'bob') role equals: CMGameRole.
	self deny: (self clientNamed: 'alice') hasRole
]

{ #category : 'tests' }
CMGameServerTest >> testReconnectKeepsRole [
	self connect: (CMFakeWebSocket sayingBonjour: 'alice').
	(self clientNamed: 'alice') role: CMGameRole.
	self connect: (CMFakeWebSocket sayingBonjour: 'alice').
	self assert: server clients size equals: 1.
	self assert: (self clientNamed: 'alice') role equals: CMGameRole
]

{ #category : 'tests' }
CMGameServerTest >> testSilentPhoneIsNotRegistered [
	self connect: CMFakeWebSocket new.
	self assert: server clients isEmpty
]

{ #category : 'tests' }
CMGameServerTest >> testStartingStopsOldServerOnSamePort [
	| old new |
	old := CMGameServer new.
	new := CMGameServer new.
	old startOn: 18082.
	[ new startOn: 18082.
	self deny: old isRunning.
	self assert: new isRunning ]
		ensure: [
			old stop.
			new stop ]
]

{ #category : 'tests' }
CMGameServerTest >> testWrongFirstMessageIsNotRegistered [
	| ws |
	ws := CMFakeWebSocket new.
	ws receive: (Dictionary new at: 'type' put: 'hello'; yourself).
	self connect: ws.
	self assert: server clients isEmpty
]
