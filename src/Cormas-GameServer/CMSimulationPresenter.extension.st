Extension { #name : 'CMSimulationPresenter' }

{ #category : '*Cormas-GameServer' }
CMSimulationPresenter >> settingsGameServer [
	<fancyNotebookPage>
	
	"TODO: Right now we are creating a new server every time the tab is opened. This should not happen"
	| server |
	server := CMGameServer new.
	
	^ SpNotebookPage
		title: 'Game server'
		icon: (self iconNamed: #remote)
		provider: [ self instantiate: CMGameInitializerPresenter on: server ]
]
