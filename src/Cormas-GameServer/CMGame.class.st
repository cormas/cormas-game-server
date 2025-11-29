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

	^ cormasModel class projectPackage definedClasses select: [ :each | each isKindOf: CMGameRole ]
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
