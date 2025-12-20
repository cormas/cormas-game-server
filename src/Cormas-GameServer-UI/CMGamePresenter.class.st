Class {
	#name : 'CMGamePresenter',
	#superclass : 'CMSimulationPresenter',
	#category : 'Cormas-GameServer-UI',
	#package : 'Cormas-GameServer-UI'
}

{ #category : 'examples' }
CMGamePresenter >> example [
	<script: 'self example'>
]

{ #category : 'as yet unclassified' }
CMGamePresenter >> game [
	"Game can be seen as a simulation... bla bla bla
	And game is a subclass of simulation
	So we use the same variable here"
	^ simulation
]

{ #category : 'instance creation' }
CMGamePresenter >> initializeSimulationInit: anInitSelector control: aControlSelector [
	"TODO: For now, we duplicate this method only to change the CMSimulation class to CMGame class. But later we should refactor it to move other parts like parameter or random seed initialization into other methods and reduce duplication"
	simulation := CMGame for: modelClass.

	modelClass parameters do: [ :parameter |
		simulation initialParameterValues at: parameter put: parameter value ].

	simulation
		activeInitSelector: anInitSelector;
		activeControlSelector: aControlSelector.
		
	simulation stopWhen: stopConditionPresenter condition.
		
	self flag: 'TODO'.
	
	"modelInitializationSettings isFixRandomSeed ifTrue: [ 
		simulation randomSeed: modelInitializationSettings randomSeed.
		simulation shouldReleaseRandomSeedAfterInitialization:
			modelInitializationSettings isReleaseRandomSeedAfterInitialization ]."
		
	simulation initializeSimulation.
	simulationRunner simulation: simulation
]

{ #category : 'initialization' }
CMGamePresenter >> presenterWindowTitle [

	^ modelClass modelName, ' - Game'
]

{ #category : 'as yet unclassified' }
CMGamePresenter >> settingsGameServer [
	<fancyNotebookPageOrder: 10>
	
	^ SpNotebookPage
		title: 'Game server'
		icon: (self iconNamed: #remote)
		provider: [ self instantiate: CMGameInitializerPresenter on: self game ]
]
