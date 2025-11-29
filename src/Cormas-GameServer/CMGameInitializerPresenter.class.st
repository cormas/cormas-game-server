Class {
	#name : 'CMGameInitializerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'server',
		'portNumberInput',
		'statusLabel',
		'connectButton',
		'inspectServerButton',
		'connectedClientsTable'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'accessing' }
CMGameInitializerPresenter class >> defaultPortNumber [

	^ 8080
]

{ #category : 'examples' }
CMGameInitializerPresenter class >> example [
	<example>
	(self on: CMGameServer new) open
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
CMGameInitializerPresenter >> connectPresenters [

	server whenClientConnectedDo: [ :client | self showConnectedClients ].
	server whenClientDisconnectedDo: [ :client | self showConnectedClients ].

	inspectServerButton action: [ server inspect ].
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
		yourself
]

{ #category : 'examples' }
CMGameInitializerPresenter >> example [
	<script: 'self example'>
]

{ #category : 'initialization' }
CMGameInitializerPresenter >> initializeFromExistingServer [

	server isRunning
		ifTrue: [
			portNumberInput number: server portNumber.
			self beInConnectedMode ]
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
		addColumn: (SpImageTableColumn new
			width: 20;
			evaluated: [ :client | self iconNamed: #testGreen ];
			beNotExpandable;
			yourself);
		addColumn: (SpStringTableColumn
			title: 'Name'
			evaluated: [ :client | client name ]);
		yourself.
	
	statusLabel := self newLabel.
	connectButton := self newButton.
		
	inspectServerButton := self newButton
		help: 'Inspect server';
		icon: (self iconNamed: #smallInspectIt);
		yourself.
		
	self initializeFromExistingServer
]

{ #category : 'accessing - model' }
CMGameInitializerPresenter >> setModelBeforeInitialization: aServer [

	server := aServer
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> showConnectedClients [

	connectedClientsTable items: server clients
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> startServer [

	server startOn: portNumberInput number.
	self beInConnectedMode
]

{ #category : 'as yet unclassified' }
CMGameInitializerPresenter >> stopServer [

	server stop.
	self beInDisconnectedMode
]
