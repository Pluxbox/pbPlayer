import React, { Component } from 'react';
import { 
  View, 
  Text,
  Button,
  Slider,
  StyleSheet 
} from "react-native";

import Moment from 'moment';


export default  class GUI extends Component {

	constructor( props ) {
		super( props );

		this.isSeeking = false;
	}

	_calculateRemainingDuration() {
		const duration = (this.state._duration-this.state._currentTime) * 1000
		return duration < 0 ? 0 : duration;
	}

	_togglePlayBtn() {

		const play = (
			<Button 
				title="Play" 
				disabled={!this.state.src}
				onPress={() => {
					this.play();
				}}
			/>
		)
	
		const pause = (
			<Button 
				title="Pause" 
				disabled={!this.state.src}
				onPress={() => {
					this.pause();
			}}/>
		)

		return this.state._isPlaying ? pause : play;
	}

	_toggleMuteBtn() {

		const on = (
			<Button 
				title="OFF" 
				disabled={!this.state.src}
				onPress={() => {
					this.muted = true;
				}}
			/>
		)
	
		const off = (
			<Button 
				title="ON" 
				disabled={!this.state.src}
				onPress={() => {
					this.muted = false;
			}}/>
		)

		return this.state._isMuted ? off : on;
	}

	shouldComponentUpdate() {
		return !this.isSeeking;
	}

	render() {
		return (
			<View style={styles.container}>
				{this._togglePlayBtn()}
				<Text style={styles.currentTime}>{Moment(this.state._currentTime*1000).format('mm:ss')}</Text>
				<Slider 
					value={this.state._currentTime / this.state._duration}
					style={styles.scrubBar}
					disabled={this.state._duration > 0 ? false : true}
					
					onValueChange={( value ) => { 
						this.currentTime = value * this.state._duration 
						this.isSeeking = true;
					}}

					onSlidingComplete = { () => {
						this.isSeeking = false;
					}

					}
				/>
				<Text style={styles.currentTime}>{Moment(this._calculateRemainingDuration()).format('mm:ss')}</Text>
				{this._toggleMuteBtn()}
			</View> 
		)
	}
};

const styles = StyleSheet.create({

	container: {
		backgroundColor: 'rgba(255,0,255,.5)',
		flexDirection: 'row',
		alignItems:'center',
	},
	currentTime: {
		backgroundColor: '#ff4400',
		flexBasis: 50,
	},
	scrubBar: {
		flex:1,
	},
});
