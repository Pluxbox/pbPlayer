# ReactNative Audio #

ReactNative Audio lib and component for IOS

- Support for network files (AAC, MP3 etc)
- Support for steaming (Ice/Shoutcast, HLS etc) 



## INSTALLATION ##


## USAGE ##

Add on top of component file:

```
    import Audio from 'RNAudio';
```


Add in component render function:

```
    <Audio 
        src="https://yourspeakr.com/audio/RadiopodcastDennisLaupman.mp3" 
        autoplay={true} 
    />
```

**OR**

In a JS class function:

```
 let    player = new Audio();
        player.src = 'https://yourspeakr.com/audio/RadiopodcastDennisLaupman.mp3';
        player.play();

```
