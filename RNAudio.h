

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

//#import <Foundation/Foundation.h>

@interface NativeRNAudio : RCTEventEmitter <RCTBridgeModule>

	@property (nonatomic, weak) NSNumber* _key;
@end
