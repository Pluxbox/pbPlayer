import React, { Component } from 'react';
import { 
  View, 
  Text,
  Button,
  StyleSheet 
} from "react-native";

import Moment from 'moment';


export default  class GUI extends Component {

	render() {
		return (
			<View style={styles.container}>
				<Button 
					title="Play" 
					onPress={() => {
						this.play();
					}}
				/>
				<Button 
					title="Pause" 
					onPress={() => {
						this.pause();
					}}
				/>
				<Text style={{flex:1}}>Audio Player GUI</Text>
				<Text style={styles.currentTime}>{Moment(this.state.currentTime*1000).format('mm:ss')}</Text>
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
