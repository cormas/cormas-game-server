"
CMGameOutput is the root of all outputs produced by the game engine.
Outputs describe what should be sent to clients, broadcast, logged, etc.
"
Class {
	#name : 'CMGameOutput',
	#superclass : 'Object',
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'accessing' }
CMGameOutput class >> type [
	"Return the message type string used on the wire, for example 'registered' or 'state'."
	self subclassResponsibility
]

{ #category : 'converting' }
CMGameOutput >> asDictionary [
	"Return a Dictionary that will be encoded to JSON. Must include at least: { 'type' -> self class type }"
	| dict payload |
	
	dict := Dictionary newFrom: { 'type' -> self class type }.
	payload := self payload.
	
	payload isDictionary
		ifFalse: [ '#payload must always return a Dictionary!' ].
	
	payload ifNotEmpty: [ 
		dict at: 'payload' put: payload ].
	
	^ dict
]

{ #category : 'as yet unclassified' }
CMGameOutput >> payload [
	"Override this method to include a custom payload. For example: { name -> Bob, cells: [1, 2, 3]}.
	Must always return a Dictionary. Empty dictionary means there's no payload"
	
	^ Dictionary new
]
