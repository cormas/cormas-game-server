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
