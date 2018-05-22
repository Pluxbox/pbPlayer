#import "RNAudio.h"
@import AVFoundation;

@implementation NativeRNAudio {
  NSMutableDictionary* _playerPool;
//  AVPlayer* player;
  AVPlayerItem *currentItem;
  AVPlayer * playbackTimeObserver;
}

RCT_EXPORT_MODULE()


- (NSArray<NSString *> *)supportedEvents
{
  return @[@"PlayerUpdate"];
}

-(NSMutableDictionary*) playerPool {
  if (!_playerPool) {
    _playerPool = [NSMutableDictionary new];
  }
  return _playerPool;
}

-(AVPlayer*) playerForKey:(nonnull NSNumber*)key {
  return [[self playerPool] objectForKey:key];
}


RCT_EXPORT_METHOD(play:(nonnull NSNumber*)key ) {
  AVPlayer* player = [self playerForKey:key];
  [player play];
  printf("[SPKRLOG] Play %s\n", player);
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber*)key ) {
  AVPlayer* player = [self playerForKey:key];
  [player pause];
	printf("[SPKRLOG] Pause\n");
}

RCT_EXPORT_METHOD(
    	prepare:(NSString*)fileName
    	withKey:(nonnull NSNumber*)key
	){
  
  // [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
  
 //  NSURL *url = [NSURL URLWithString:@"http://icecast.omroep.nl/radio1-bb-aac"];
//   NSURL *url = [NSURL URLWithString:@"https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"];
  // NSURL *url = [NSURL URLWithString:@"https://yourspeakr.com/audio/RadiopodcastDennisLaupman.mp3"];

  AVPlayer * player = [[AVPlayer alloc] initWithURL:[ NSURL URLWithString:fileName ] ];
  [player addObserver:self forKeyPath:@"status" options:0 context:nil];
  
//  [player play];

    CMTime interval = CMTimeMakeWithSeconds(.25, NSEC_PER_SEC); // 1 second
    playbackTimeObserver = [ player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
      [self sendEventWithName:@"PlayerUpdate" body:  @{@"currentTime": [NSNumber numberWithFloat:CMTimeGetSeconds(time)] }];
    }];

    [[self playerPool] setObject:player forKey:key];
  }

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
  
//     if (object == player && [keyPath isEqualToString:@"status"]) {
//         if (player.status == AVPlayerStatusReadyToPlay) {
////             playButton.enabled = YES;
//           printf("[SPKRLOG] AVPlayerStatusReadyToPlay\n");
//         } else if (player.status == AVPlayerStatusFailed) {
//             // something went wrong. player.error should contain some information
//         }
//     }
}



//[player removeTimeObserver:self.playbackTimeObserver];


//Otherwise you get an error
+ (BOOL)requiresMainQueueSetup
{
    return YES;
}


@end
