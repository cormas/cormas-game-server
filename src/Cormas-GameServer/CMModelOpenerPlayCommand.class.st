Class {
	#name : 'CMModelOpenerPlayCommand',
	#superclass : 'CMModelOpenerCommand',
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'action' }
CMModelOpenerPlayCommand >> action [

	CMGameApplication new
		cormasModel: owner cormasModelClass new;
		run.
]

{ #category : 'accessing' }
CMModelOpenerPlayCommand >> icon [ 

	^ CMIcons playIcon
]

{ #category : 'testing' }
CMModelOpenerPlayCommand >> isBigButton [

	^ true
]

{ #category : 'accessing' }
CMModelOpenerPlayCommand >> name [

	^ 'Play'
]
