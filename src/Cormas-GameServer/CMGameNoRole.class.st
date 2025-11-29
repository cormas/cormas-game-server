Class {
	#name : 'CMGameNoRole',
	#superclass : 'CMGameRole',
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'testing' }
CMGameNoRole class >> isRole [

	^ false
]

{ #category : 'as yet unclassified' }
CMGameNoRole class >> roleName [

	^ '(no role)'
]
