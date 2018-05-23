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

export default class RNAudio extends Gui {
	
	constructor( props ) {
		super( props );

		this.state = Object.assign ({
			
			//Public vars
			src: null,

			//Callbacks
			autoplay: false,
			canplay: null,
			ended: null,

			//Private  vars
			_isPlaying: false,
			_currentTime: 0,
			_duration: 0,
			_loop: false,
			_muted: false,
			_isComponent: false,
			_key: null,
			_isLoaded: false,
		}, props);

		this.subscription = NativeRNAudioEmitter.addListener(
			'PlayerUpdate',
			( data ) => {
				if(this.state._key == data._key && this.state._isComponent) {
					this.setState( {
						_currentTime: data._currentTime
					});
				} else  if(this.state._key == data._key){
					this.state._currentTime = data._currentTime;
				}
			}
		);
	}

	componentDidMount() {
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
		return this.state.muted;
	}

	set muted ( bool ) {
		this.state._muted = bool;
	}

	get loop () {
		return this.state._loop;
	}

	get currentTime () {
		
  		return this.state._currentTime;
	}

	set currentTime ( seconds ) {
		this.state._currentTime = seconds;
	}

	get duration () {
		return this.state._duration;
	}

	play () {

		!this.state._isLoaded && this._prepare();

		this.state._isPlaying = true;	

		NativeRNAudio.play( this.state._key );
	}

	pause () {
		console.log("isNotPlaying");
		this.state._isPlaying = false;
		NativeRNAudio.pause( this.state._key );
	}

	//Private fuctions
	_prepare() {

		if(!this.state.src) {
			return;
		}

		this.state._key = this._djb2Code( this.state.src );

		NativeRNAudio.prepare( 
			this.state.src,
			this.state._key,
			( data ) => {
				this.state._duration = data._duration;
			}
		);


		this.state._isLoaded = true;	
		this.state.autoplay && this.play();

		//Temporary
		// setTimeout( () => {
		// 	this.state.canplay && this.state.canplay();
		// 	this.state.autoplay && this.play();
		// 	setTimeout( () => {

		// 		this.state.ended && this.state.	ended();
		// 	}, 4000);
		// }, 3000)
	}	

	_djb2Code(str) {
	  var hash = 5381, i, char;
	  for (i = 0; i < str.length; i++) {
	      char = str.charCodeAt(i);
	      hash = ((hash << 5) + hash) + char; /* hash * 33 + c */
	  }
	  return hash;
	}
}


module.exports = RNAudio;
