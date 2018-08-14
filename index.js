/**
 * @providesModule RNAudio
 * @flow
 */
'use strict';
import React, { Component } from 'react';
import {  
	NativeModules,
	NativeEventEmitter,
	Platform,
} from 'react-native';

// //GUI ifused as a React Native Component
import Gui from './gui';
import TimerMixin from 'react-timer-mixin';

//Bridge Objective-c
const { NativeRNAudioPlayer } = NativeModules;
const NativeRNAudioEmitter = new NativeEventEmitter(NativeRNAudioPlayer);

let enableBackgroundModeIsSet = false;



class AudioPlayer extends Gui {
	
	constructor( props ) {
		super( props );
		
		this._isComponent = false,
		this.state = Object.assign ({
			
			//Public vars
			src: null,
			cover: null,

			//Callbacks
			autoplay: false,
			canplay: null,
			timeupdate: null,
			ended: null,

			//Private  vars
			_isPlaying: 0,
			_currentTime: 0,
			_duration: 0,
			_loop: false,
			_isMuted: false,
			_isEnded: false,
			_key: null,
			_isLoaded: false,	
			_isReadyToPlay: false,
			_isFinished: false,
		}, {}, props);

		this.subscription = NativeRNAudioEmitter.addListener(
			'PlayerUpdate',
			( data ) => {				
				if(this.state._key == data._key){
					this.state.timeupdate && this.state.timeupdate(data._currentTime);
					this.state.playing && (this.state._isPlaying != data._isPlaying) && this.state.playing( data._isPlaying ? true : false );


					this._setState( { 
						_currentTime: data._currentTime,
						_isPlaying: data._isPlaying,
					});
					if(data._isFinished && data._isFinished !== this._isFinished ) {
						this.state.ended && this.state.ended();
						this._isFinished = true;
					} else if(data._isReadyToPlay && data._isReadyToPlay !== this._isReadyToPlay ) {
						this.state.canplay && this.state.canplay();
						this._isReadyToPlay = true;
					}	
				}
			}
		);
	}

	componentDidMount() {
		this._isComponent = true;
		this._setState( {
			ended: () => this.stop()
		});
		this._prepare();	
	}

	componentWillUnmount() {
		this.subscription.remove();	
	}

	//Public params
	set src ( string ) {
		this.state.src = string;
		// Wait until al te protoypes are set
		TimerMixin.setTimeout(() => {
			this._prepare();
		});
	}
	
	//Airplay data 
	set title ( string ) {
		this._setState( {
			title: string,
		});
	} 
	
	set artist ( string ) {
		this._setState( {
			artist: string,
		});
	} 
	set album ( string ) {
		this._setState( {
			album: string,
		});
	} 
	set cover ( string ) {
		this._setState( {
			cover: string,
		});
	} 

	//Callback functions
	set timeupdate ( callback ) {
		this._setState( {
			timeupdate: callback,
		});
	}

	set canplay ( callback ) {
		this._setState( {
			canplay: callback,
		});
	}

	set playing ( callback ) {
		this._setState( {
			playing: callback,
		});
	}

	//Params
	set ended ( callback ) {
		this.state.ended = callback;
	}

	set loop ( bool ) {
		this.state.loop = bool;
	}

	get muted () {
		return this.state._isMuted;
	}

	set muted ( bool ) {
		NativeRNAudioPlayer.muted( this.state._key, bool );
	}

	get loop () {
		return this.state._loop;
	}

	get currentTime () {
  		return this.state._currentTime;
	}

	set currentTime ( seconds ) {
		NativeRNAudioPlayer.seek( this.state._key, seconds );
	}

	get duration () {
		return this.state._duration;
	}

	get paused () {
		return !this.state._isPlaying;
	}

	//controls
	play () {
		!this.state._isLoaded && this._prepare();
		this._isFinished = false;
		NativeRNAudioPlayer.play( this.state._key );
	}

	pause () {
		console.log("isNotPlaying");
		NativeRNAudioPlayer.pause( this.state._key );
	}

	stop () {
		console.log("isStopped");
		this.currentTime = 0;
		NativeRNAudioPlayer.stop( this.state._key );
	}

	//Private fuctions
	_prepare() {
		!enableBackgroundModeIsSet && NativeRNAudioPlayer.enableBackgroundMode();
		enableBackgroundModeIsSet = true;

		if(!this.state.src) {
			return;
		}

		this.state._key = Math.floor(Math.random() * 10000000);

		//Get options
		var options  = Object.keys(this.state).reduce((previous, current) => {
			if(['artist','title','album','cover'].indexOf(current) !== -1 && this.state[current]){
				previous[current] = this.state[current];
			}
		    return previous;
		}, {});

		NativeRNAudioPlayer.prepare( 
			this.state.src,
			this.state._key,
			options,
			( data ) => {
				this.state._duration = data._duration;
			}
		);

		this.state._isLoaded = true;
	}	

	_djb2Code(str) {
	  var hash = 5381, i, char;
	  for (i = 0; i < str.length; i++) {
	      char = str.charCodeAt(i);
	      hash = ((hash << 5) + hash) + char;
	  }
	  return hash;
	}

	_setState( data ) {
		if(this._isComponent) {
			this.setState( data );
		} else {
			this.state = Object.assign(this.state, data)
		}
	}
}

let AudioPlayerUtils = {};

if (Platform.OS === 'ios') {
	AudioPlayerUtils = {
	  MainBundlePath: NativeRNAudioPlayer.MainBundlePath,
	  CachesDirectoryPath: NativeRNAudioPlayer.NSCachesDirectoryPath,
	  DocumentDirectoryPath: NativeRNAudioPlayer.NSDocumentDirectoryPath,
	  LibraryDirectoryPath: NativeRNAudioPlayer.NSLibraryDirectoryPath,
	};
  } else if (Platform.OS === 'android') {
	// AudioUtils = {
	//   MainBundlePath: NativeRNAudioPlayer.MainBundlePath,
	//   CachesDirectoryPath: NativeRNAudioPlayer.CachesDirectoryPath,
	//   DocumentDirectoryPath: NativeRNAudioPlayer.DocumentDirectoryPath,
	//   LibraryDirectoryPath: NativeRNAudioPlayer.LibraryDirectoryPath,
	//   PicturesDirectoryPath: NativeRNAudioPlayer.PicturesDirectoryPath,
	//   MusicDirectoryPath: NativeRNAudioPlayer.MusicDirectoryPath,
	//   DownloadsDirectoryPath: NativeRNAudioPlayer.DownloadsDirectoryPath
	// };
  }
  

module.exports = {AudioPlayer, AudioPlayerUtils};
