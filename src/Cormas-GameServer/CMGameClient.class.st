Class {
	#name : 'CMGameClient',
	#superclass : 'Object',
	#instVars : [
		'name',
		'webSocket',
		'role'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'connection open/close' }
CMGameClient >> disconnect [

	webSocket close
]

{ #category : 'testing' }
CMGameClient >> hasRole [

	^ role isRole
]

{ #category : 'initialization' }
CMGameClient >> initialize [

	super initialize.
	role := CMGameNoRole
]

{ #category : 'testing' }
CMGameClient >> isConnected [

	^ webSocket isNotNil and: [ webSocket isConnected ]
]

{ #category : 'accessing' }
CMGameClient >> name [

	^ name
]

{ #category : 'accessing' }
CMGameClient >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
CMGameClient >> role [

	^ role
]

{ #category : 'protocol' }
CMGameClient >> sendMessage: aString [

	webSocket sendMessage: aString

	
]

{ #category : 'accessing' }
CMGameClient >> webSocket: anObject [

	webSocket := anObject
]
