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

	| message |
	message := self toJSONString: aDictionaryOrString.
	
	mutex critical: [ 
		clients do: [ :client | 
			[ client webSocket sendMessage: message ] onErrorDo: [ :e |
				self log: ('Broadcast error to ', client id asString, ': ', e printString) ] ] ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> clientAtId: aClientId [

	^ clients detect: [ :each | each id = aClientId ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> clientAtId: aClientId ifAbsent: aBlock [

	^ clients detect: [ :each | each id = aClientId ] ifNone: aBlock
]

{ #category : 'as yet unclassified' }
CMGameServer >> clientAtId: aClientId ifPresent: aBlock [

	^ clients detect: [ :each | each id = aClientId ] ifFound: aBlock
]

{ #category : 'as yet unclassified' }
CMGameServer >> clientIdFrom: ws ifAbsent: anAbsentBlock [

	"Expect a hello frame with an id, with timeout"
	| helloRaw helloMsg |
	
	helloRaw := [ ws readMessage ]
		valueWithin: 5 seconds
		onTimeout: [
			[ ws sendMessage: 'Handshake timeout: send {"type":"bonjour","id":"..."} first' ]
				onErrorDo: [ :e | self log: e ].
			ws close.
			^ self ].
		
	helloMsg := [ self parseJSON: helloRaw ] onErrorDo: [ :err |
		[ ws sendMessage: 'Bad JSON in handshape' ] onErrorDo: [ :e | self log: e ].
		ws close.
		^ self ].
	
	((helloMsg at: 'type' ifAbsent: [ nil ]) = 'bonjour') ifFalse: [ 
		[ ws sendMessage: 'First message must be {"type":"bonjour","id":"..."}' ]
			onErrorDo: [ :e | self log: e ].
		ws close.
		^ self ].
	
	^ helloMsg at: 'id' ifAbsent: [ UUID new asString ]
	
]

{ #category : 'accessing' }
CMGameServer >> clients [

	^ clients
]

{ #category : 'as yet unclassified' }
CMGameServer >> closeAllClients [
	mutex critical: [ 
		clients do: [ :client | [ client webSocket close ] onErrorDo: [ :e | self log: e ] ].
		clients removeAll ]
]

{ #category : 'as yet unclassified' }
CMGameServer >> handleWebSocket: ws [
	| clientId newClient |
	clientId := self clientIdFrom: ws ifAbsent: [ UUID new asString ].
	
	"Register or replace existing socket for this clientId"
	mutex critical: [ 
		self clientAtId: clientId ifPresent: [ :previousSocket |
			[ previousSocket close ] onErrorDo: [ :e |
				self log: 'Error closing previous socket for ', clientId asString, ': ', e printString ] ].
		
		newClient := CMGameClient new
			id: clientId;
			webSocket: ws;
			yourself.
			
		clients add: newClient ].
	
	[ whenClientConnectedBlock value: newClient ] onErrorDo: [ :e | self log: e ].

	"Main read loop for this connection"
	[ 
		[ ws isConnected ] whileTrue: [ 
			| raw data |
			raw := ws readMessage. "blocks until a frame arrives or socket closes"
			data := [ self parseJSON: raw ] onErrorDo: [ :e |
				self log: ('Bad JSON from ', clientId asString, ': ', e printString).
				nil ].
			
			data ifNotNil: [
				| client |
				client := self clientAtId: clientId.
				whenDataReceivedBlock value: data value: client ] ]
	] ensure: [ 
		"Unregister only if this ws is still the current one for clientId (avoid racing with a fast reconnection)"
		mutex critical: [ 
			self clientAtId: clientId ifPresent: [ :client |
				clients remove: client.
				[ whenClientDisconnectedBlock value: client ] onErrorDo: [ :e | self log: e ] ] ] ]
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
	clients := OrderedCollection new.
	htmlDirectory := 'html/'.
	
	"Use setter method to replace this block with a custom callback to process the game input"
	whenDataReceivedBlock := [ :data :client | self log: ('[',  client id asString, '] :', data asString) ].
	whenClientConnectedBlock := [ :client | self log: ('Client connected: ', client id asString) ].
	whenClientDisconnectedBlock := [ :client | self log: ('Client disconnected: ', client id asString) ].
]

{ #category : 'testing' }
CMGameServer >> isRunning [

	^ server isNotNil
]

{ #category : 'logging' }
CMGameServer >> log: anObject [

	anObject asString traceCr
]

{ #category : 'parsing' }
CMGameServer >> parseJSON: aString [

	^ STONJSON fromString: aString
]

{ #category : 'accessing' }
CMGameServer >> portNumber [

	^ server port
]

{ #category : 'as yet unclassified' }
CMGameServer >> send: aDictionaryOrString toClient: aClientId [

	| message socket |
	message := self toJSONString: aDictionaryOrString.
	
	socket := self clientAtId: aClientId ifAbsent: [ 
		^ self log: ('No such client: ', aClientId) ].
	
	[ socket sendMessage: message ] onErrorDo: [ :e |
		self log: ('Send error to ', aClientId asString, ': ', e printString) ]
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

{ #category : 'as yet unclassified' }
CMGameServer >> toJSONString: anObject [

	^ STONJSON toString: anObject
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
