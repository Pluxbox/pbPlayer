import React, { Component } from 'react';
import { 
  View, 
  Text,
  Button,
  StyleSheet 
} from "react-native";
import ScrubBar from './scrubbar';

export default  class GUI extends Component {

	
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
				<ScrubBar
					style={ styles.scrubBar }
					disabled={this.state._duration > 0 ? false : true}
					maximumValue={this.state._duration}
					value={this.state._currentTime}
					onSliderChange={ ( position ) => {
						this.currentTime = position;
					}}
				 />
				
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
	
	scrubBar: {
		flex:1,
	},
});
