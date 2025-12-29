"
CMGameAction is the root of all actions for a specific game.
Concrete actions should be subclasses of a game-specific root, for example:
CMFisheryAction << #CMHarvestAction ...
"
Class {
	#name : 'CMGameAction',
	#superclass : 'Object',
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'accessing' }
CMGameAction class >> fromDictionary: aDictionary [
	"Build and return an instance from a decoded JSON dictionary.
This method should validate required keys and signal an error if missing/invalid."
	self subclassResponsibility
]

{ #category : 'accessing' }
CMGameAction class >> type [
	"Return the message type string used on the wire, for example 'bonjour' or 'harvest'."
	self subclassResponsibility
]
