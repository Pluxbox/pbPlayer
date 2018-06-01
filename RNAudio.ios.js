/**
 * @providesModule RNAudio
 * @flow
 */
'use strict';
import React, { Component } from 'react';
import {  
	NativeModules,
	NativeEventEmitter,
	View,
	Text,
	Button,
} from 'react-native';

// //GUI ifused as a React Native Component
import Gui from './gui';

//Bridge Objective-c
const { NativeRNAudio } = NativeModules;
const NativeRNAudioEmitter = new NativeEventEmitter(NativeRNAudio);

let enableBackgroundModeIsSet = false;

export default class RNAudio extends Gui {
	
	constructor( props ) {
		super( props );
		this.state = Object.assign ({
			
			//Public vars
			src: null,
			cover: null,

			//Callbacks
			autoplay: false,
			canplay: null,
			ended: null,

			//Private  vars
			_isPlaying: false,
			_currentTime: 0,
			_duration: 0,
			_loop: false,
			_isMuted: false,
			_isEnded: false,
			_isComponent: false,
			_key: null,
			_isLoaded: false,
			_isReadyToPlay: false,
		}, {}, props);

		this.subscription = NativeRNAudioEmitter.addListener(
			'PlayerUpdate',
			( data ) => {				
				if(this.state._key == data._key){				
					this._setState( { 
						_currentTime: data._currentTime,
						_isPlaying: data._isPlaying,
					});

					if(data._isReadyToPlay && data._isReadyToPlay !== this._isReadyToPlay ) {
						this.state.canplay && this.state.canplay();

						console.log("adsadasdas");
						setTimeout(()=> {
							this.state._isComponent && this.state.autoplay && this.play();
							
						})
						this._isReadyToPlay = true;
					}	
				}
			}
		);
	}

	componentDidMount() {
		
		!enableBackgroundModeIsSet && NativeRNAudio.enableBackgroundMode();

		enableBackgroundModeIsSet = true;
		this.state._isComponent = true;
		
		this._prepare();	
	}

	componentWillUnmount() {
		this.subscription.remove();	
	}

	//Public params
	set src ( string ) {
		this.state.src = string;
		// this._prepare();
	}
	
	// set cover ( string ) {
	// 	this._metadata.cover = string;
	// }
	
	set canplay ( callback ) {
		this.state.canplay = callback;
	}

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
		NativeRNAudio.muted( this.state._key, bool );
	}

	get loop () {
		return this.state._loop;
	}

	get currentTime () {
  		return this.state._currentTime;
	}

	set currentTime ( seconds ) {
		NativeRNAudio.seek( this.state._key, seconds );
	}

	get duration () {
		return this.state._duration;
	}

	play () {
		!this.state._isLoaded && this._prepare();
		NativeRNAudio.play( this.state._key );
	}

	pause () {
		console.log("isNotPlaying");
		NativeRNAudio.pause( this.state._key );
	}


	//Private fuctions
	_prepare() {

		if(!this.state.src) {
			return;
		}

		this.state._key = this._djb2Code( this.state.src );

		// //Get options
		var options  = Object.keys(this.state).reduce((previous, current) => {
			if(['artist','title','album','cover'].indexOf(current) !== -1 && this.state[current]){
				previous[current] = this.state[current];
			}
		    return previous;
		}, {});

		NativeRNAudio.prepare( 
			this.state.src,
			this.state._key,
			options,
			( data ) => {
				this.state._duration = data._duration;
			}
		);

		this.state._isLoaded = true;	

		// if(this.state.autoplay && this.state._isComponent) {
			// this.play();	
			// this._setState({ _isPlaying: true})
		// } 
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
		if(this.state._isComponent) {
			this.setState( data );
		} else  if(this.state._key == data._key){
			this.state = Object.assign(this.state, data)
		}
	}
}


module.exports = RNAudio;
