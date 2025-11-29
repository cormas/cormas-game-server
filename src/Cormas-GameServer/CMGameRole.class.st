Class {
	#name : 'CMGameRole',
	#superclass : 'Object',
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'testing' }
CMGameRole class >> isRole [

	^ true
]

{ #category : 'as yet unclassified' }
CMGameRole class >> roleName [
	"Override this mehod to provide a custom human-readable name for a role"
	^ self name
]
