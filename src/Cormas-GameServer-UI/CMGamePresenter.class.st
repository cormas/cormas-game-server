Class {
	#name : 'CMGamePresenter',
	#superclass : 'CMSimulationPresenter',
	#category : 'Cormas-GameServer-UI',
	#package : 'Cormas-GameServer-UI'
}

{ #category : 'examples' }
CMGamePresenter class >> example [
	<example>
	
	CMGameApplication new
		cormasModel: CMMockModel new;
		run
]

{ #category : 'examples' }
CMGamePresenter >> example [
	<script: 'self example'>
]

{ #category : 'as yet unclassified' }
CMGamePresenter >> game [
	"Game can be seen as a simulation... bla bla bla
	And game is a subclass of simulation
	So we use the same variable here"
	^ self application simulation
]

{ #category : 'instance creation' }
CMGamePresenter >> initializeSimulationInit: anInitSelector control: aControlSelector [
	"TODO: For now, we duplicate this method only to change the CMSimulation class to CMGame class. But later we should refactor it to move other parts like parameter or random seed initialization into other methods and reduce duplication"
	| simulation parameters |
	
	"Save parameters from previous simulation to copy their values and start with the same values
	in the new simulation. This is important if we want to set some parameters before initialization"
	parameters := self cormasModel allParameters.

	simulation := self cormasModel class gameClass for: self cormasModel.
	self application simulation: simulation.

	simulation
		activeInitSelector: anInitSelector;
		activeControlSelector: aControlSelector.
		
	simulation stopWhen: stopConditionPresenter buildConditionBlock.
		
	randomNumbersPresenter apply.
	
	simulation initializeSimulation.
	simulationRunner updateWithSimulation.
	randomNumbersPresenter showCurrentSettings
]

{ #category : 'initialization' }
CMGamePresenter >> presenterWindowTitle [

	^ self cormasModel class modelName, ' - Game'
]

{ #category : 'as yet unclassified' }
CMGamePresenter >> settingsGameServer [
	<fancyNotebookPageOrder: 10>
	
	^ SpNotebookPage
		title: 'Game server'
		icon: (self iconNamed: #remote)
		provider: [ self instantiate: CMGameInitializerPresenter on: self game ]
]
