# ReactNative Audio Player #

ReactNative Audio lib for IOS

- Support for local files (AAC, MP3 etc)
- Support for network files (AAC, MP3 etc)
- Support for steaming (Ice/Shoutcast, HLS etc) 


## INSTALLATION ##


## USAGE ##

**Component based"**

Add on top of component file:

```
    import {AudioPlayer} from 'RNAudio';
```


Add in component render function:

```
    <Audio 
        src="https://example.nl/stream" 
        artist="Denny Lau"
        title="Dennies Sing a Long"
        album="Dennies album"
        cover="https://example.com/thumb.png"
    />
```

**OR**

In a JS class function:

```
 let    player = new Audio();
        player.src = 'https://example.com/fragment.aac';
        player.canplay = () => {
            player.play();
        }

```
