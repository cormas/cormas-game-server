Class {
	#name : 'CMGameServer',
	#superclass : 'Object',
	#instVars : [
		'server',
		'clients',
		'mutex',
		'htmlDirectory',
		'whenDataReceivedBlock',
		'whenClientConnectedBlock',
		'whenClientDisconnectedBlock'
	],
	#category : 'Cormas-GameServer',
	#package : 'Cormas-GameServer'
}

{ #category : 'as yet unclassified' }
CMGameServer class >> loginPageHtml [

	^ '<!doctype html>
<html lang="en">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Game Login</title>
<style>
  body { font-family: system-ui, sans-serif; max-width: 560px; margin: 6rem auto; padding: 0 1rem }
  form { display: flex; gap: .5rem }
  input[type=text]{ flex:1; padding:.6rem .8rem; font-size:1rem }
  button{ padding:.6rem 1rem; font-size:1rem; cursor:pointer }
  .error{ color:#b00020; margin-top:.75rem }
  .ok{ color:#006400; margin-top:.75rem }
  pre{ background:#f6f6f6; padding:.75rem; overflow:auto }
</style>
<h1>Choose your name to join</h1>

<form id="login">
  <input id="name" type="text" placeholder="e.g. alice" required minlength="2" maxlength="24" />
  <button type="submit">Join</button>
</form>

<div id="msg"></div>
<pre id="log" hidden></pre>

<script>
const byId = id => document.getElementById(id);
const nameInput = byId(''name'');
const msg = byId(''msg'');
const log = byId(''log'');

nameInput.value = localStorage.getItem(''cm.name'') || '''';

function show(kind, text){
  msg.className = kind;
  msg.textContent = text;
}

function addLog(x){
  log.hidden = false;
  log.textContent += x + "\n";
}

let ws = null;

byId(''login'').addEventListener(''submit'', (e) => {
  e.preventDefault();
  const name = nameInput.value.trim();
  if(!name){ show(''error'', ''Please enter a name''); return; }

  const proto = location.protocol === ''https:'' ? ''wss'' : ''ws'';
  const url = `${proto}://${location.host}/ws`;
  ws = new WebSocket(url);

  ws.addEventListener(''open'', () => {
    ws.send(JSON.stringify({ type: ''hello'', id: name }));
  });

  ws.addEventListener(''message'', (ev) => {
    try {
      const msgObj = JSON.parse(ev.data);
      if(msgObj.type === ''welcome''){
        localStorage.setItem(''cm.name'', msgObj.id);
        show(''ok'', `Welcome, ${msgObj.id}! Connected.`);
        addLog(''CONNECTED as '' + msgObj.id);
      } else if(msgObj.type === ''rejected'' && msgObj.reason === ''name-taken''){
        show(''error'', ''This name is already taken. Choose another.'');
        ws.close();
      } else if(msgObj.type === ''error''){
        show(''error'', ''Error: '' + (msgObj.reason || ''unknown''));
      } else {
        addLog(''<< '' + ev.data);
      }
    } catch(err) {
      addLog(''<< '' + ev.data);
    }
  });

  ws.addEventListener(''close'', () => {
    addLog(''DISCONNECTED'');
  });

  ws.addEventListener(''error'', () => {
    show(''error'', ''Connection error'');
  });
});
</script>
</html>'
]

{ #category : 'as yet unclassified' }
CMGameServer >> broadcast: aDictionaryOrString [
	
	mutex critical: [ 
		self clients do: [ :client | 
			client sendMessage: aDictionaryOrString ] ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> broadcastStartGame [

	mutex critical: [ 
		self clients do: #sendGameStartedMessage ]
]

{ #category : 'accessing' }
CMGameServer >> clients [

	^ clients values
]

{ #category : 'as yet unclassified' }
CMGameServer >> closeAllClients [
	mutex critical: [ 
		self clients do: [ :client | [ client disconnect ] onErrorDo: [ :e | self log: e ] ].
		clients removeAll ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> handleData: aDictionary forClient: aClient [
	
	| type |
	
	type := aDictionary at: 'type' ifAbsent: [ 
		self flag: 'TODO'. "send error message to client becuase type is not optional"
		^ self ].
	
	type = 'ping' ifTrue: [ 
		aClient sendPongMessage.
		"^ self" ].

	"other message types here"
	whenDataReceivedBlock value: aDictionary value: aClient
]

{ #category : 'as yet unclassified' }
CMGameServer >> handleWebSocket: ws [
	| client |
	
	client := CMGameClient fromWebSocket: ws.
	client readNameFromHandshake.

	"Register or replace existing socket for this clientId"
	mutex critical: [ 
		clients at: client name ifPresent: [ :previousClient |
			[ previousClient disconnect ] onErrorDo: [ :e |
				self log: 'Error closing previous socket for ', client name, ': ', e printString ] ].
			
		clients at: client name put: client ].
	
	[ whenClientConnectedBlock value: client ] onErrorDo: [ :e | self log: e ].
	
	client sendRegisteredMessage.
	self readLoopForClient: client
]

{ #category : 'accessing' }
CMGameServer >> htmlDirectory: aString [

	htmlDirectory := aString
]

{ #category : 'as yet unclassified' }
CMGameServer >> htmlFrom: aFileName [

	^ (htmlDirectory asFileReference / aFileName) contents
]

{ #category : 'initialization' }
CMGameServer >> initialize [

	super initialize.
	mutex := Mutex new.
	clients := Dictionary new.
	htmlDirectory := 'html/'.
	
	"Use setter method to replace this block with a custom callback to process the game input"
	whenDataReceivedBlock := [ :data :client | self log: ('[',  client name, ' @ ', Time now asString, '] :', data asString) ].
	whenClientConnectedBlock := [ :client | self log: ('Client connected: ', client name) ].
	whenClientDisconnectedBlock := [ :client | self log: ('Client disconnected: ', client name) ].
]

{ #category : 'testing' }
CMGameServer >> isRunning [

	^ server isNotNil
]

{ #category : 'logging' }
CMGameServer >> log: anObject [

	anObject asString traceCr
]

{ #category : 'accessing' }
CMGameServer >> portNumber [

	^ server port
]

{ #category : 'as yet unclassified' }
CMGameServer >> readLoopForClient: aClient [

	| data |

	"Main read loop for this connection"
	[ 
		[ aClient isConnected ] whileTrue: [
			[
				data :=aClient readMessage. "blocks until a frame arrives or socket closes"
				data ifNotNil: [ self handleData: data forClient: aClient ]
			] on: ConnectionTimedOut do: [
				"This happens when client is inactive for a long time. In this case, we disconnect the client
				and exit the loop"
				aClient disconnect ] ]
	] ensure: [ 
		"Unregister only if this ws is still the current one for clientId (avoid racing with a fast reconnection)"
		mutex critical: [ 
			clients at: aClient name ifPresent: [ :c |
				"clients removeKey: c name."
				[ whenClientDisconnectedBlock value: c ] onErrorDo: [ :e | self log: e ] ] ] ]
]

{ #category : 'accessing' }
CMGameServer >> startOn: aPortNumber [
	"Start HTTP server with a WebSocket endpoint at /ws."
	| wsDelegate dispatcher |
	server ifNotNil: [ self error: 'Already running!' ].
	
	dispatcher := ZnDispatcherDelegate new.
	
	wsDelegate := ZnWebSocketDelegate map: '/' to: [ :ws | self handleWebSocket: ws ].
	
	dispatcher map: '/ws' to: [ :request :response |
		wsDelegate handleRequest: request ].
	
	dispatcher map: '/' to: [ :request :response |
		response entity: (ZnEntity html: (self htmlFrom: 'login.html')) ].
	
	server := ZnServer startOn: aPortNumber.
	self log: ('Started a server at localhost:', aPortNumber asString).
	
	server delegate: dispatcher.
]

{ #category : 'accessing' }
CMGameServer >> stop [
	server ifNil: [ ^ self ].
	[ self closeAllClients ] onErrorDo: [ :e | self log: e ].
	server stop.
	server := nil.
]

{ #category : 'enumerating' }
CMGameServer >> whenClientConnectedDo: aBlock [
	"aBlock: [ :client | ... ]"
	whenClientConnectedBlock := aBlock
]

{ #category : 'enumerating' }
CMGameServer >> whenClientDisconnectedDo: aBlock [
	"aBlock: [ :client | ... ]"
	whenClientDisconnectedBlock := aBlock
]

{ #category : 'enumerating' }
CMGameServer >> whenDataReceivedDo: aBlock [
	"aBlock: [ :data :client | ... ]"
	whenDataReceivedBlock := aBlock
]
