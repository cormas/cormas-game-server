Extension { #name : 'CMModel' }

{ #category : '*Cormas-GameServer' }
CMModel class >> gameClass [

	^ self package classes
		detect: [ :aClass | aClass inheritsFrom: CMGame ]
		ifNone: [ CMGame ]
]

{ #category : '*Cormas-GameServer' }
CMModel >> respondToClient: aDictionary [
	"Override this method to specify the response to a player action received over the network. aDictionary represents a JSON input"
	
	aDictionary traceCr
]
