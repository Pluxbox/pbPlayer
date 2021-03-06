

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#import <AVFoundation/AVFoundation.h>

@interface NativeRNAudioPlayer : RCTEventEmitter <RCTBridgeModule, AVAudioPlayerDelegate>
	@property (nonatomic, weak) NSNumber* _key;
  @property (nonatomic, copy) NSString *artworkUrl;
@end
