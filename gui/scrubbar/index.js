import React, { Component } from 'react';
import { 
  View, 
  Slider,
  Text,
  StyleSheet 
} from "react-native";

import Moment from 'moment';


export default class ScrubBar extends Component {

	constructor( props ) {
		super(props);

		this.state = {
			value: props.value || 0,
			maximumValue: props.maximumValue,
			isSeeking: false,
			disabled: false,
		}
	}

	componentWillReceiveProps(nextProps) {
		this.setState({
			// value: this.state.isSeeking ? this.state.value ? nextProps.value ,
			value: this.state.isSeeking ? this.state.value : nextProps.value ,
			maximumValue: nextProps.maximumValue,
			disabled: nextProps.disabled,
		});
	}

	// shouldComponentUpdate() {
	// 	return !this.state.isSeeking;
	// }

	_calculateRemainingDuration() {
		const duration = (this.state.maximumValue-this.state.value) * 1000
		return duration < 0 ? 0 : duration;
	}

	render() {



		// console.log(this.props.isBuffering, this.state.value)

		return (
			<View style={[ this.props.style, styles.container ]}>
				<Text style={styles.currentTime}>{Moment(this.state.value*1000).format('mm:ss')}</Text>
				<Slider 
					style={[ styles.slider ]}
					value={ this.state.value }
					disabled={this.state.disabled}
					maximumValue={this.state.maximumValue}
					onValueChange={( value ) => { 

						this.setState( {
							isSeeking: true,
							value: value,
						});
					}}
					onSlidingComplete = { ( value ) => {
						
						this.setState( {
							isSeeking: false,
						});
						this.props.onSliderChange( value ); 
					}}
				/>
				<Text style={styles.currentTime}>{Moment(this._calculateRemainingDuration()).format('mm:ss')}</Text>
			</View>
		);
	}
};


const styles = StyleSheet.create({
	container: {
		flexDirection: 'row'
	},
	currentTime: {
		backgroundColor: '#ff4400',
		flexBasis: 50,
	},
	slider: {
		flex: 1,
		backgroundColor: '#fff000',
	}
});
