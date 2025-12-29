Class {
	#name : 'CMGameStartedOutput',
	#superclass : 'CMGameOutput',
	#instVars : [
		'role'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'accessing' }
CMGameStartedOutput class >> type [

	^ 'gameStarted'
]

{ #category : 'as yet unclassified' }
CMGameStartedOutput >> payload [

	role ifNil: [ self error: 'Role must be assigned!' ].
	^ Dictionary newFrom: { 'role' -> role asString }
]

{ #category : 'accessing' }
CMGameStartedOutput >> role: aSymbol [

	role := aSymbol 
]
