

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#import <AVFoundation/AVFoundation.h>

@interface NativeRNAudio : RCTEventEmitter <RCTBridgeModule, AVAudioPlayerDelegate>
	@property (nonatomic, weak) NSNumber* _key;
@end
