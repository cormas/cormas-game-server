# cormas-game-server
A plugin that launches a web server for Cormas games

```st
"Load Cormas"
Metacello new
    repository: 'github://cormas/cormas';
    baseline: 'Cormas';
    load.

"Load the Game Server plugin"
Metacello new
    baseline: 'CormasGameServer';
    repository: 'github://cormas/cormas-game-server:main';
    onConflict: [ :e | e useIncoming ];
    onUpgrade: [ :e | e useIncoming ];
    onWarning: [ :e | e load ];
    ignoreImage;
    load
```

Example:

```st
server := CMGameServer new.
server startOn: 8082.

spacePresenter := CMSpacePresenter allInstances last.
model := spacePresenter cormasModel.

server whenDataReceivedDo: [ :data |
	| occupiedCellIds harvesters |
	
	occupiedCellIds := data at: 'occupiedCells'.
	harvesters := model @@ PCHarvester.
	
	harvesters do: #leave.
	
	occupiedCellIds with: (harvesters first: occupiedCellIds size) do: [ :id :harvester |
		harvester moveTo: (model cellAt: id) ].
	
	spacePresenter updateDiagram ].

server stop.
```

Python client:

```py
# client.py
# pip install websockets

import asyncio
import websockets
import json

from mock import simulate_input


async def run_client():
	uri = 'ws://localhost:8082/ws'

	async with websockets.connect(uri) as websocket:
		print('Connected to server')

		while True:
			# Example: {'occupiedCells': [1, 4, 7, 13]}
			data = {'occupiedCells': simulate_input()}
			print(data)

			await websocket.send(json.dumps(data))
			await asyncio.sleep(0.1)


if __name__ == '__main__':
	asyncio.run(run_client())
```
```py
# mock.py

import random

def simulate_input():
	cells = [random.randint(0, 1) for _ in range(20)]
	occupied_cells = [i+1 for i in range(20) if cells[i] == 1]
	return occupied_cells
```
