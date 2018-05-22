import React, { Component } from 'react';
import { 
  View, 
  Text,
  Button,
  StyleSheet 
} from "react-native";


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
				<Text>Audio Player GUI</Text>
			</View> 
		)
	}
};

const styles = StyleSheet.create({
	container: {
		backgroundColor: 'rgba(255,0,255,.5)',
		flexDirection: 'row',
		alignItems:'center',
	}


});
