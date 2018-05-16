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
			<View>
			<Button 
				title="Play" 
				onPress={() => {
					this.play();
				}}
			/>
			<Text>Audio Player GUI</Text>
			</View> 
		)
	}
};

const styles = StyleSheet.create({
	container: {
		backgroundColor: '#ff00ff',
	}
});