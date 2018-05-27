import React, { Component } from 'react';
import { 
  View, 
  Slider,
  // StyleSheet 
} from "react-native";


export default class ScrubBar extends Component {

	constructor( props ) {
		super(props);

		this.state = {
			value: props.value,
			isSeeking: false,
			disabled: false,
		}
	}

	componentWillReceiveProps(nextProps) {
		this.setState({
			value: nextProps.value,
			disabled: nextProps.disabled,
		});		
	}

	shouldComponentUpdate() {
		return !this.state.isSeeking;
	}

	render() {
		return (
				<Slider 
					style={[ this.props.style ]}
					value={ this.state.value }
					disabled={this.state.disabled}
					onValueChange={( value ) => { 
						!this.state.isSeeking && this.props.onSlidingStart()
						this.props.onSliderChange( value ); 
						this.setState( {
							isSeeking: true,
						});
					}}
					onSlidingComplete = { () => {
						this.props.onSlidingComplete();
						this.setState( {
							isSeeking: false,
						});
					}}
				/>
		);
	}
};

/*

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

					*/

// const styles = StyleSheet.create({

// });