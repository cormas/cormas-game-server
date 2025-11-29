Class {
	#name : 'CMGameClient',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'webSocket'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'accessing' }
CMGameClient >> id [

	^ id
]

{ #category : 'accessing' }
CMGameClient >> id: anObject [

	id := anObject
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
CMGameClient >> webSocket [

	^ webSocket
]

{ #category : 'accessing' }
CMGameClient >> webSocket: anObject [

	webSocket := anObject
]
