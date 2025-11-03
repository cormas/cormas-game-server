Class {
	#name : 'BaselineOfCormasGameServer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCormasGameServer',
	#package : 'BaselineOfCormasGameServer'
}

{ #category : 'baselines' }
BaselineOfCormasGameServer >> baseline: spec [
	<baseline>
	spec for: #common do: [
		
		"Dependencies"
		spec
			baseline: 'ZincHTTPComponents'
			with: [ spec
				loads: #(WebSocket);
				repository: 'github://svenvc/zinc' ].

		"Packages"
		spec package: 'Cormas-GameServer' with: [ spec requires: #('ZincHTTPComponents') ].
		spec package: 'Cormas-GameServer-Tests' with: [ spec requires: #('Cormas-GameServer') ] ].
]
