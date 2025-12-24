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

	^ cormasModel class package definedClasses select: [ :each | each inheritsFrom: CMGameRole ]
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
