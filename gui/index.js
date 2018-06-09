import React, { Component } from 'react';
import { 
  View, 
  Text,
  Button,
  TouchableOpacity,
  Image,
  StyleSheet 
} from "react-native";
import ScrubBar from './scrubbar';

export default  class GUI extends Component {

	
	_togglePlayBtn() {

		const play = (
			<TouchableOpacity
				disabled={!this.state.src}
				style={ styles.playToggleBtn }
				onPress={() => {
					this.play();
				}}
			>
				<Image source={ require('../assets/play.png') }  />
			</TouchableOpacity>
		)
	
		const pause = (
			<TouchableOpacity
				disabled={!this.state.src}
				style={ styles.playToggleBtn }
				onPress={() => {
					this.pause();
			}}>	
				<Image source={ require('../assets/pause.png') }  />
			</TouchableOpacity>
		)

		return this.state._isPlaying ? pause : play;
	}

	_toggleMuteBtn() {

		const on = (
			<TouchableOpacity 
				style={ styles.volume }
				disabled={!this.state.src}
				onPress={() => {
					this.muted = true;
					this._setState( { _isMuted:true }  );
				}}
			>
				<Image source={ require('../assets/volume.png') }  />
			</TouchableOpacity>
		)
	
		const off = (
			<Button 
				title="ON" 
				style={ styles.volume }
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
		backgroundColor: 'rgb(42,42,42)',
		flexDirection: 'row',
		alignItems:'center',
		height:30,
		paddingHorizontal: 15,
	},
	playToggleBtn: {
		flexBasis: 15,
		flexDirection: 'row',
	},	
	scrubBar: {
		flex:1,
	},
	volume: {
		marginLeft: 5,
	},
});
