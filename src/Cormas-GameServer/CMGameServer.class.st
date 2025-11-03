Class {
	#name : 'CMGameServer',
	#superclass : 'Object',
	#instVars : [
		'server',
		'socket',
		'mutex'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'initialization' }
CMGameServer >> initialize [

	super initialize.
	mutex := Mutex new
]

{ #category : 'logging' }
CMGameServer >> log: anObject [

	anObject asString traceCr
]
