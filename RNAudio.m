#import "RNAudio.h"
@import AVFoundation;

@implementation NativeRNAudio {
	
     AVPlayer* player;
}

RCT_EXPORT_MODULE()


- (NSArray<NSString *> *)supportedEvents
{
  return @[@"PlayerUpdate"];
}


RCT_EXPORT_METHOD(play) {
	[player play];	
	printf("[SPKRLOG] Play\n");
}

RCT_EXPORT_METHOD(pause) {
	[player pause];	
	printf("[SPKRLOG] Play\n");
}

RCT_EXPORT_METHOD(test)
{
	printf("[SPKRLOG] Called native function\n");
  
//Play
  // NSURL *url = [NSURL URLWithString:@"http://icecast.omroep.nl/radio1-bb-aac"];
   // NSURL *url = [NSURL URLWithString:@"https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"];
  
 NSURL *url = [NSURL URLWithString:@"https://yourspeakr.com/audio/RadiopodcastDennisLaupman.mp3"];
    player = [[AVPlayer alloc] initWithURL:url];
  
  // [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
  

  [player addObserver:self forKeyPath:@"status" options:0 context:nil];

  [player play];


CMTime interval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC); // 1 second
[ player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
    // update slider value here...

  printf("[SPKRLOG] ticker\n");
}];  


	NSString *eventName = @"aaa";
	[self sendEventWithName:@"PlayerUpdate" body:@{@"name": eventName, @"phone":@"06-1212343453"}];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
  
     if (object == player && [keyPath isEqualToString:@"status"]) {
         if (player.status == AVPlayerStatusReadyToPlay) {
//             playButton.enabled = YES;
           printf("[SPKRLOG] AVPlayerStatusReadyToPlay\n");
          
         } else if (player.status == AVPlayerStatusFailed) {
             // something went wrong. player.error should contain some information
         }
     }
}


@end
