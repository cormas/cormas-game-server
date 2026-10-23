Class {
	#name : 'CMFakeWebSocket',
	#superclass : 'Object',
	#instVars : [
		'incoming',
		'sent',
		'connected',
		'delay'
	],
	#category : 'Cormas-GameServer-Tests',
	#package : 'Cormas-GameServer-Tests'
}

{ #category : 'as yet unclassified' }
CMFakeWebSocket class >> sayingBonjour: aName [
	"Un téléphone qui se présente avec ce nom"
	^ self new
		receive: (Dictionary new at: 'type' put: 'bonjour'; at: 'name' put: aName; yourself);
		yourself
]

{ #category : 'initialization' }
CMFakeWebSocket >> beSlow [
	delay := 3 seconds
]

{ #category : 'initialize-release' }
CMFakeWebSocket >> close [
	(Delay forSeconds: delay) wait.
	connected := false
]

{ #category : 'initialization' }
CMFakeWebSocket >> initialize [
	super initialize.
	incoming := OrderedCollection new.
	sent := OrderedCollection new.
	connected := true.
	delay := 0
]

{ #category : 'initialization' }
CMFakeWebSocket >> isConnected [
	^ connected
]

{ #category : 'initialization' }
CMFakeWebSocket >> messageOfType: aString [
	^ self messages detect: [ :each | (each at: 'type' ifAbsent: [ '' ]) = aString ]
]

{ #category : 'initialization' }
CMFakeWebSocket >> messages [
	^ sent collect: [ :each |
		[ | value |
		value := STONJSON fromString: each.
		value isString ifTrue: [ value := STONJSON fromString: value ].
		value ]
			on: Error
			do: [ :e | Dictionary new ] ]
]

{ #category : 'initialization' }
CMFakeWebSocket >> readMessage [
	incoming ifEmpty: [
		connected := false.
		^ '{}' ].
	^ incoming removeFirst
]

{ #category : 'initialization' }
CMFakeWebSocket >> receive: aDictionary [
	incoming add: (STONJSON toString: aDictionary)
]

{ #category : 'initialization' }
CMFakeWebSocket >> sendMessage: aString [
	(Delay forSeconds: delay) wait.
	sent add: aString
]

{ #category : 'initialization' }
CMFakeWebSocket >> stream [
	^ self
]

{ #category : 'initialization' }
CMFakeWebSocket >> types [
	^ (self messages collect: [ :each | each at: 'type' ifAbsent: [ '' ] ]) asArray
]
