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
    import Audio from 'RNAudio';
```


Add in component render function:

```
    <Audio 
        src="https://icecast.omroep.nl/radio1-bb-aac" 
        artist="Dennis"
        title="Dennies Podcast"
        album="Dennies album"
        cover="https://yourspeakr.com/images/thumb2.png"
    />
```

**OR**

In a JS class function:

```
 let    player = new Audio();
        player.src = 'https://yourspeakr.com/audio/RadiopodcastDennisLaupman.mp3';
        player.canplay = () => {
            player.play();
        }

```
