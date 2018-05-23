import React, { Component } from 'react';
import { 
  View, 
  Text,
  Button,
  StyleSheet 
} from "react-native";

import Moment from 'moment';


export default  class GUI extends Component {

	_calculateRemainingDuration() {
		const duration = (this.state._duration-this.state._currentTime) * 1000
		return duration < 0 ? 0 : duration;
	}

	_togglePlayBtn() {
	// <Button 
	// 				title="Play" 
	// 				onPress={() => {
	// 					this.play();
	// 				}}
	// 			/>
	// 			

		return (
			<Button 
				title="Pause" 
				onPress={() => {
					this.pause();

			}}/>
		)
	}

	render() {
		return (
			<View style={styles.container}>
				{this._togglePlayBtn()}
				
				<Text style={styles.currentTime}>{Moment(this.state._currentTime*1000).format('mm:ss')}</Text>
				<Text style={{flex:1}}>Audio Player GUI</Text>
				<Text style={styles.currentTime}>{Moment(this._calculateRemainingDuration()).format('mm:ss')}</Text>
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
	}
});
