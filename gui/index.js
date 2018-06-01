import React, { Component } from 'react';
import { 
  View, 
  Text,
  Button,
  StyleSheet 
} from "react-native";
import ScrubBar from './scrubbar';

import Moment from 'moment';


export default  class GUI extends Component {

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
					// this._setState( { _isPlaying:true }  );
				}}
			/>
		)
	
		const pause = (
			<Button 
				title="Pause" 
				disabled={!this.state.src}
				onPress={() => {
					this.pause();
					// this._setState( { _isPlaying:false } );
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
					this._setState( { _isMuted:true }  );
				}}
			/>
		)
	
		const off = (
			<Button 
				title="ON" 
				disabled={!this.state.src}
				onPress={() => {
					this.muted = false;
					this._setState( { _isMuted:false }  );
			}}/>
		)

		return this.state._isMuted ? off : on;
	}


	render() {
		return (
			<View style={styles.container}>
				{this._togglePlayBtn()}
				<Text style={styles.currentTime}>{Moment(this.state._currentTime*1000).format('mm:ss')}</Text>
				<ScrubBar
					style={ styles.scrubBar }
					disabled={this.state._duration > 0 ? false : true}
					value={this.state._currentTime / this.state._duration}
					onSliderChange={ ( position ) => {
						this.currentTime = position * this.state._duration;
					}}
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
