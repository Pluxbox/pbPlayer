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
			
			//Callbacks
			autoplay: false,
			canplay: null,
			ended: null,

			//Private  vars
			_src: null,
			_isPlaying: false,
			_currentTime: 0,
			_duration: 0,
			_loop: false,
			_muted: false,
			_isComponent: false,
			_key: this._guid(),
		}, props);


		this.subscription = NativeRNAudioEmitter.addListener(
			'PlayerUpdate',
			( data ) => {
				if(this.state._isComponent) {
					this.setState( {
						currentTime: data.currentTime
					});
				} else {
					this.state = Object.assign(this.state, data);	
				}
			}
		);
	}
	componentDidMount() {
		this.state._isComponent = true;
	}

	componentWillUnmount() {
		this.subscription.remove();	
	}


	//Public params
	set src ( string ) {
		this.state._src = string;
		this._prepare();
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
		console.log("isPlaying");
		this.state._isPlaying = true;	

		NativeRNAudio.play();
	}

	pause () {
		console.log("isNotPlaying");
		this.state._isPlaying = false;

		NativeRNAudio.pause();
	}

	//Private fuctions
	_prepare() {

		this.state._src && NativeRNAudio.prepare( 
			this.state._src,
			this.state._key 
		);

		//Temporary
		// setTimeout( () => {
		// 	this.state.canplay && this.state.canplay();
		// 	this.state.autoplay && this.play();
		// 	setTimeout( () => {

		// 		this.state.ended && this.state.	ended();
		// 	}, 4000);
		// }, 3000)
	}

	_guid() {
	  function s4() {
	    return Math.floor((1 + Math.random()) * 0x10000)
	      .toString(16)
	      .substring(1);
	  }
	  return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
	}
}


module.exports = RNAudio;
