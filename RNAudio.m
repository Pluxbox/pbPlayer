#import "RNAudio.h"
@import AVFoundation;

@implementation NativeRNAudio {
  AVPlayer* player;
  AVPlayerItem *currentItem;
  AVPlayer * playbackTimeObserver;
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
	printf("[SPKRLOG] Pause\n");
}

RCT_EXPORT_METHOD(
    prepare:(NSString*)fileName
    withKey:(NSString*)key
){


printf("%s\n", fileName);

	printf("[SPKRLOG] Called native function\n");
  
  // [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
  
 //  NSURL *url = [NSURL URLWithString:@"http://icecast.omroep.nl/radio1-bb-aac"];
//   NSURL *url = [NSURL URLWithString:@"https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"];
  NSURL *url = [NSURL URLWithString:@"https://yourspeakr.com/audio/RadiopodcastDennisLaupman.mp3"];
  player = [[AVPlayer alloc] initWithURL:url];
  [player addObserver:self forKeyPath:@"status" options:0 context:nil];
  [player play];

    CMTime interval = CMTimeMakeWithSeconds(.25, NSEC_PER_SEC); // 1 second
    playbackTimeObserver = [ player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
      [self sendEventWithName:@"PlayerUpdate" body:  @{@"currentTime": [NSNumber numberWithFloat:CMTimeGetSeconds(time)],
      }];
  }];
  
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



//[player removeTimeObserver:self.playbackTimeObserver];


//Otherwise you get an error
+ (BOOL)requiresMainQueueSetup
{
    return YES;
}


@end
