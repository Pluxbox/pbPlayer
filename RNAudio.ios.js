/**
 * @providesModule RNAudio
 * @flow
 */
'use strict';

var NativeRNAudio = require('NativeModules').RNAudio;

/**
 * High-level docs for the RNAudio iOS API can be written here.
 */

console.log("aaa")


var RNAudio = {
  test: function() {

  	console.log("bbb")
    // NativeRNAudio.test();
  }
};

module.exports = RNAudio;
