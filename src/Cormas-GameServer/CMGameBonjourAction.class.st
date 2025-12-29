Class {
	#name : 'CMGameBonjourAction',
	#superclass : 'CMGameAction',
	#instVars : [
		'name'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'accessing' }
CMGameBonjourAction class >> fromDictionary: aDictionary [

	| clientName |
	
	clientName := aDictionary
		at: 'name'
		ifAbsent: [ self error: 'Invalid JSON! Bonjour message must contain a name' ].
		
	^ self new
		name: clientName;
		yourself
]

{ #category : 'accessing' }
CMGameBonjourAction class >> type [

	^ 'bonjour'
]

{ #category : 'accessing' }
CMGameBonjourAction >> name [

	^ name
]

{ #category : 'accessing' }
CMGameBonjourAction >> name: aString [

	name := aString
]
