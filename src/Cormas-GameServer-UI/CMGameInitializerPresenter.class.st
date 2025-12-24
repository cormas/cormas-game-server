Class {
	#name : 'CMGameInitializerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'game',
		'portNumberInput',
		'statusLabel',
		'connectButton',
		'inspectServerButton',
		'connectedClientsTable',
		'startGameButton'
	],
	#category : 'Cormas-GameServer-UI',
	#package : 'Cormas-GameServer-UI'
}

{ #category : 'accessing' }
CMGameInitializerPresenter class >> defaultPortNumber [

	^ 8080
]

{ #category : 'examples' }
CMGameInitializerPresenter class >> example [
	<example>
	| game |
	game := (CMGame for: CMMockModel)
		activeInitSelector: #initFixed;
		startGame.
		
	(self on: game) open
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> beInConnectedMode [

	portNumberInput disable.

	statusLabel
		displayColor: [ Color green ];
		label: 'Connected'.
		
	connectButton
		icon: (self iconNamed: #cancel);
		label: 'Disconnect';
		action: [ self stopServer ].
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> beInDisconnectedMode [

	portNumberInput enable.

	statusLabel
		displayColor: [ Color red ];
		label: 'Diconnected'.
		
	connectButton
		icon: CMIcons runIcon;
		label: 'Connect';
		action: [ self startServer ].
]

{ #category : 'initialization' }
CMGameInitializerPresenter >> buildRolesMenu [

	| rolesMenu |
	
	rolesMenu := SpMenuPresenter new.
	
	game availableRoles do: [ :role |
		rolesMenu addItem: [ :item | item
			name: role roleName;
			action: [
				connectedClientsTable selectedItem role: role.
				self showConnectedClients ] ] ].

	^ rolesMenu
]

{ #category : 'initialization' }
CMGameInitializerPresenter >> buildTableMenu [

	connectedClientsTable contextMenu: (SpMenuPresenter new 
		addItem: [ :item | item 
			name: 'Role'; 
			subMenu: self buildRolesMenu ];
		addItem: [ :item | item
			name: 'Disconnect';
			action: [ connectedClientsTable selectedItem disconnect ] ]
		yourself).
]

{ #category : 'initialization' }
CMGameInitializerPresenter >> connectPresenters [

	game server whenClientConnectedDo: [ :client | self showConnectedClients ].
	game server whenClientDisconnectedDo: [ :client | self showConnectedClients ].

	inspectServerButton action: [ game server inspect ].
	startGameButton action: [ game startGame ]
]

{ #category : 'layout' }
CMGameInitializerPresenter >> defaultLayout [
	
	^ SpBoxLayout newTopToBottom
		borderWidth: 5;
		spacing: 10;
		add: (SpGridLayout new
			borderWidth: 0;
			beColumnNotHomogeneous;
			column: 2 expand: true;
			build: [ :builder | builder
				add: 'Port number:';
				add: portNumberInput;
				nextRow;
				add: 'Status:';
				add: statusLabel;
				nextRow ]) height: 70;
		add: (SpBoxLayout newLeftToRight
			spacing: 2;
			add: connectButton;
			add: inspectServerButton width: 40;
			yourself) expand: false;
		add: (SpBoxLayout newTopToBottom
			add: 'Connected clients' expand: false;
			add: connectedClientsTable;
			yourself);
		add: startGameButton expand: false;
		yourself
]

{ #category : 'examples' }
CMGameInitializerPresenter >> example [
	<script: 'self example'>
]

{ #category : 'initialization' }
CMGameInitializerPresenter >> initializeFromExistingServer [

	game server isRunning
		ifTrue: [
			portNumberInput number: game server portNumber.
			self beInConnectedMode.
			self showConnectedClients ]
		ifFalse: [
			portNumberInput number: self class defaultPortNumber.
			self beInDisconnectedMode ]
]

{ #category : 'initialization' }
CMGameInitializerPresenter >> initializePresenters [
	
	portNumberInput := self newNumberInput
		number: self class defaultPortNumber;
		yourself.
		
	connectedClientsTable := self newTable
		hideColumnHeaders;
		addColumn: (SpImageTableColumn new
			width: 20;
			evaluated: [ :client | self iconNamed: (client isConnected
				ifTrue: [ #testGreen ]
				ifFalse: [ #testRed ]) ];
			beNotExpandable;
			yourself);
		addColumn: (SpStringTableColumn
			title: 'Name'
			evaluated: [ :client | client name ]);
		addColumn: (SpStringTableColumn
			title: 'Role'
			evaluated: [ :client | client role roleName ]);
		yourself.
		
	self buildTableMenu.
	
	statusLabel := self newLabel.
	connectButton := self newButton.
		
	inspectServerButton := self newButton
		help: 'Inspect server';
		icon: (self iconNamed: #smallInspectIt);
		yourself.
		
	startGameButton := self newButton
		label: 'Start Game';
		icon: CMIcons playIcon;
		yourself.
		
	self initializeFromExistingServer
]

{ #category : 'accessing - model' }
CMGameInitializerPresenter >> setModelBeforeInitialization: aGame [

	game := aGame
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> showConnectedClients [

	connectedClientsTable items: game server clients.
	
	(game server clients allSatisfy: #hasRole)
		ifTrue: [ startGameButton enable ]
		ifFalse: [ startGameButton disable ]
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> startServer [

	game server startOn: portNumberInput number.
	self beInConnectedMode
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> stopServer [

	game server stop.
	self beInDisconnectedMode
]
