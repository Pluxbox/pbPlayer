#import "RNAudio.h"
//@import AVFoundation;
@import MediaPlayer;

@implementation NativeRNAudio {
  NSMutableDictionary* _playerPool;
  AVPlayer * playbackTimeObserver;
}

@synthesize _key = _key;


RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

-(NSArray<NSString *> *)supportedEvents
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

- (void) toggleHandler:(MPRemoteCommand *) command withSelector:(SEL) selector enabled:(BOOL) enabled {
  [command removeTarget:self action:selector];
  if(enabled){
    [command addTarget:self action:selector];
  }
  command.enabled = enabled;
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber*)key ) {
  
  AVPlayer* player = [self playerForKey:key];
  [player play];
  self._key = key;
  
  
  printf("[SPKRLOG] Play\n");
  
  
  MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
  MPRemoteCommandCenter *remoteCenter = [MPRemoteCommandCenter sharedCommandCenter];
  
  NSDictionary *info = @{
                         MPMediaItemPropertyTitle:  @"50 Essential Podcasts To Download Today",
                         MPMediaItemPropertyArtist: @"Jennifer Clarkson",
                         MPMediaItemPropertyAlbumTitle: @"Playlist: Startups",
                         MPNowPlayingInfoPropertyPlaybackRate :@1.0f };
  
  center.nowPlayingInfo = info;
  
  //Bind external displays
  [self toggleHandler:remoteCenter.playCommand withSelector:@selector(play) enabled:YES];
  [self toggleHandler:remoteCenter.pauseCommand withSelector:@selector(pause) enabled:YES];
}


//External display functions
-(void)play {
  AVPlayer* player = [self playerForKey:self._key];
  [player play];
  printf("[SPKRLOG] External Play \n");
}

-(void)pause {
  AVPlayer* player = [self playerForKey:self._key];
  [player pause];
  printf("[SPKRLOG] External Pause \n");
}




RCT_EXPORT_METHOD(pause:(nonnull NSNumber*)key ) {
  AVPlayer* player = [self playerForKey:key];
  [player pause];
	printf("[SPKRLOG] Pause\n");
}

RCT_EXPORT_METHOD(seek:(nonnull NSNumber*)key withValue:(nonnull NSNumber*)value) {
  AVPlayer* player = [self playerForKey:key];
  [player.currentItem seekToTime:CMTimeMakeWithSeconds( [value floatValue], 1)];
  printf("[SPKRLOG] Seek\n");
}

RCT_EXPORT_METHOD(muted:(nonnull NSNumber*)key withValue:(BOOL)mute) {
  AVPlayer* player = [self playerForKey:key];
  player.muted = mute;
  printf("[SPKRLOG] Mute\n");
}


RCT_EXPORT_METHOD(enableBackgroundMode) {
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setCategory: AVAudioSessionCategoryPlayback error: nil];
  [session setActive: YES error:nil];
}


RCT_EXPORT_METHOD(
    	prepare:(NSString*)fileName
    	withKey:(nonnull NSNumber*)key
      withCallback:(RCTResponseSenderBlock)callback
	){
    // MPRemoteCommandCenter *remoteCenter = [MPRemoteCommandCenter sharedCommandCenter];
  
  
 //  NSURL *url = [NSURL URLWithString:@"https://icecast.omroep.nl/radio1-bb-aac"];
//   NSURL *url = [NSURL URLWithString:@"https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"];
  // NSURL *url = [NSURL URLWithString:@"https://yourspeakr.com/audio/RadiopodcastDennisLaupman.mp3"];

  	AVPlayer * player = [[AVPlayer alloc] initWithURL:[ NSURL URLWithString:fileName ] ];
  	[player addObserver:self forKeyPath:@"status" options:0 context:nil];

    [[self playerPool] setObject:player forKey:key];
    [self updateJSScope: key];

    CMTime duration = player.currentItem.asset.duration;
    float seconds = CMTimeGetSeconds(duration);
  
    if (seconds != seconds) {
      seconds = 0;
    }

    printf("[SPKRLOG] Player prepared\n");
  
    callback( @[ @{ @"_duration": @(seconds) } ] );
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


- (void)updateJSScope: (nonnull NSNumber*)key {
  
  AVPlayer* player = [self playerForKey:key];
  CMTime interval = CMTimeMakeWithSeconds(.25, NSEC_PER_SEC); // 1 second
  
  playbackTimeObserver = [ player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
    
  NSDictionary * data = @{
                            @"_currentTime": [NSNumber numberWithFloat:CMTimeGetSeconds(time)],
                            @"_key": key
                          };

    [self sendEventWithName:@"PlayerUpdate" body: data ];
  }];
}


//[player removeTimeObserver:self.playbackTimeObserver];


+ (BOOL)requiresMainQueueSetup
{
    return YES;
}



@end
