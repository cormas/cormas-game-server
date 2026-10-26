Class {
	#name : 'CMGame',
	#superclass : 'CMSimulation',
	#instVars : [
		'server',
		'portNumber'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'as yet unclassified' }
CMGame >> availableRoles [
	^ (self class package definedClasses select: [ :each | each inheritsFrom: CMGameRole ]) asArray
		sort: [ :a :b | a name <= b name ]
]

{ #category : 'testing' }
CMGame >> canStart [
	^ server clients notEmpty and: [ server clients allSatisfy: #hasRole ]
]

{ #category : 'initialization' }
CMGame >> initialize [

	super initialize.
	server := CMGameServer new.
]

{ #category : 'accessing' }
CMGame >> server [
	^ server
]

{ #category : 'initialization' }
CMGame >> startGame [

	self initializeSimulation.
	server broadcastStartGame
]
