/**
 * @providesModule RNAudio
 * @flow
 */
'use strict';
import React, { Component } from 'react';
import {  
	View,
	Text,
	Button,
} from 'react-native';

// //GUI ifused as a React Native Component
import Gui from './gui';

//Bridge Objective-c
var NativeRNAudio = require('NativeModules').RNAudio;


console.log(NativeRNAudio)

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
		}, props);
	}

	//Public params
	set src ( string ) {
		this.state._src = string;
		this._loadAsset();
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

		// NativeRNAudio.test();
	}


	pause () {
		console.log("isNotPlaying");
		this.state._isPlaying = false;
	}

	//Private fuctions
	_loadAsset() {

		//Temporary
		setTimeout( () => {

			this.state.canplay && this.state.canplay();
			this.state.autoplay && this.play();
			setTimeout( () => {

				this.state.ended && this.state.	ended();
			}, 4000);
		}, 3000)
	}
}


module.exports = RNAudio;
