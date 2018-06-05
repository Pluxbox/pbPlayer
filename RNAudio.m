#import "RNAudio.h"
//@import AVFoundation;
@import MediaPlayer;


@implementation NativeRNAudio {
  NSMutableDictionary* _playerPool;
  NSMutableDictionary* _nowPlayingPool;
  AVPlayer * playbackTimeObserver;
  BOOL isSeeking;
}

#define ONAIR_DICT @{\
  @"title": MPMediaItemPropertyTitle, \
  @"artist": MPMediaItemPropertyArtist, \
  @"album": MPMediaItemPropertyAlbumTitle, \
  @"duration": MPMediaItemPropertyPlaybackDuration, \
  @"elapsedTime": MPNowPlayingInfoPropertyElapsedPlaybackTime, \
  @"speed": MPNowPlayingInfoPropertyPlaybackRate, \
  @"mediaType": MPNowPlayingInfoPropertyMediaType \
}

@synthesize _key = _key;

- (void)audioSessionChangeObserver:(NSNotification *)notification{
  NSDictionary* userInfo = notification.userInfo;
  AVAudioSessionRouteChangeReason audioSessionRouteChangeReason = [userInfo[@"AVAudioSessionRouteChangeReasonKey"] longValue];
  AVAudioSessionInterruptionType audioSessionInterruptionType   = [userInfo[@"AVAudioSessionInterruptionTypeKey"] longValue];
  AVPlayer* player = [self playerForKey:self._key];
  if (audioSessionRouteChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable){
    if (player) {
      [player play];
    }
  }
  if (audioSessionInterruptionType == AVAudioSessionInterruptionTypeEnded){
    if (player && (player.rate != 0) && (player.error == nil)) {
      [player play];
    }
  }
  if (audioSessionRouteChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable){
    if (player) {
      [player pause];
    }
  }
  if (audioSessionInterruptionType == AVAudioSessionInterruptionTypeBegan){
    if (player) {
      [player pause];
    }
  }
  printf("[SPKRLOG] Changed Route\n");
}

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


-(NSMutableDictionary*) nowPlayingPool {
  if (!_nowPlayingPool) {
    _nowPlayingPool = [NSMutableDictionary new];
  }
  return _nowPlayingPool;
}

-(NSMutableDictionary*) nowPlayingForKey:(nonnull NSNumber*)key {
  return [[self nowPlayingPool] objectForKey:key];
}

- (void) toggleHandler:(MPRemoteCommand *) command withSelector:(SEL) selector enabled:(BOOL) enabled {
  [command removeTarget:self action:selector];
  if(enabled){
    [command addTarget:self action:selector];
  }
  command.enabled = enabled;
}

- (void) updateNowPlaying:(NSDictionary *) originalDetails {
  MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
  NSMutableDictionary *onAirInfo = [[NSMutableDictionary alloc] initWithDictionary: center.nowPlayingInfo];
//  NSMutableDictionary *details = [originalDetails mutableCopy];
//  for (NSString *key in ONAIR_DICT) {
//    if ([details objectForKey:key] != nil) {
//      [onAirInfo setValue:[details objectForKey:key]  forKey:[ONAIR_DICT objectForKey:key]];
//    }
//  }
  center.nowPlayingInfo = onAirInfo;
  printf("[SPKRLOG] Update Now Playing\n");
}



- (void) setNowPlaying:(nonnull NSNumber*)key {
  
  AVPlayer* player = [self playerForKey:key];
  
  NSMutableDictionary* details = [self nowPlayingForKey:key];
  NSURL *imageURL = [NSURL URLWithString: [details objectForKey:@"cover"]];
  NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
  UIImage *image = [UIImage imageWithData:imageData];

  NSLog(@" test cover %@ \n",  [details objectForKey:@"cover"]);
  
  MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage: image];
  MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
  MPRemoteCommandCenter *remoteCenter = [MPRemoteCommandCenter sharedCommandCenter];
  NSMutableDictionary *onAirInfo = [[NSMutableDictionary alloc] init];
  
  
//  for (NSString *key in ONAIR_DICT) {
//    if ([details objectForKey:key] != nil) {
//      [onAirInfo setValue:[details objectForKey:key]  forKey:[ONAIR_DICT objectForKey:key]];
//    }
//  }

  //Set Elapse time
  [onAirInfo setValue:@1  forKey:MPNowPlayingInfoPropertyPlaybackRate];
  [onAirInfo setValue:[NSNumber numberWithFloat:CMTimeGetSeconds(player.currentItem.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
//  [onAirInfo setValue:artwork  forKey:MPMediaItemPropertyArtwork];

  center.nowPlayingInfo = onAirInfo;

  //Bind external displays
  [self toggleHandler:remoteCenter.playCommand withSelector:@selector(play) enabled:YES];
  [self toggleHandler:remoteCenter.pauseCommand withSelector:@selector(pause) enabled:YES];
  [self toggleHandler:remoteCenter.changePlaybackPositionCommand withSelector:@selector(changePlaybackPosition:) enabled:YES];
  printf("[SPKRLOG] Set Now Playing\n");
}


//External display functions
-(void)play {
  AVPlayer* player = [self playerForKey:self._key];
  [player play];
  [self updateNowPlaying:@{
                           @"elapsedTime": [NSNumber numberWithFloat:CMTimeGetSeconds(player.currentItem.currentTime)],
                           @"speed": @1,
                           }];
  printf("[SPKRLOG] External Play \n");
}

-(void)pause {
  AVPlayer* player = [self playerForKey:self._key];
  [player pause];
  [self updateNowPlaying:@{
                           @"elapsedTime": [NSNumber numberWithFloat:CMTimeGetSeconds(player.currentItem.currentTime)],
                           @"speed": @0,
                           }];
  printf("[SPKRLOG] External Pause \n");
}

-(void)changePlaybackPosition:(MPChangePlaybackPositionCommandEvent*)event {
  AVPlayer* player = [self playerForKey:_key];
  [player.currentItem
   seekToTime:CMTimeMakeWithSeconds( (float) event.positionTime, 1)
   toleranceBefore:kCMTimeZero
   toleranceAfter:kCMTimeZero
   completionHandler:^(BOOL finished){
     isSeeking = NO;
     NSLog(finished ? @"Yes" : @"NO");
   }
   
   
  ];
  
  [self updateNowPlaying:@{
                           @"elapsedTime": @600, // event.positionTime
                           @"speed": @0,
                           }];
  printf("[SPKRLOG] External scrubbar\n");
}

-(void)itemDidFinishPlaying {
  printf("[SPKRLOG] Track Finished \n");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

RCT_EXPORT_MODULE()

//JS functions
RCT_EXPORT_METHOD(play:(nonnull NSNumber*)key ) {
  AVPlayer* player = [self playerForKey:key];
  [[AVAudioSession sharedInstance] setActive:YES error:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionChangeObserver:) name:AVAudioSessionRouteChangeNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
  [player play];
  self._key = key;
  [self setNowPlaying: key];
  [self updateNowPlaying:@{
                           @"elapsedTime": [NSNumber numberWithFloat:CMTimeGetSeconds(player.currentItem.currentTime)],
                           @"speed": @1,
                           @"mediaType": @(MPNowPlayingInfoMediaTypeAudio),
                           }];
  printf("[SPKRLOG] Play\n");
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber*)key ) {
  AVPlayer* player = [self playerForKey:key];
  [player pause];
  [self updateNowPlaying:@{
                           @"elapsedTime": [NSNumber numberWithFloat:CMTimeGetSeconds(player.currentItem.currentTime)],
                           @"speed": @0,
                           }];
	printf("[SPKRLOG] Pause\n");
}

RCT_EXPORT_METHOD(seek:(nonnull NSNumber*)key withValue:(nonnull NSNumber*)value) {
  AVPlayer* player = [self playerForKey:key];
  isSeeking = YES;
  [player.currentItem
    seekToTime:CMTimeMakeWithSeconds( [value floatValue], 1)
    toleranceBefore:kCMTimeZero
    toleranceAfter:kCMTimeZero
    completionHandler:^(BOOL finished){
     isSeeking = NO;
    }
   ];
  [self updateNowPlaying:@{
                           @"elapsedTime": [NSNumber numberWithFloat: [value floatValue]],
                           @"speed": @0,
                           }];
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
      withOptions:(NSDictionary*)options
      withCallback:(RCTResponseSenderBlock)callback
	){

  AVPlayer * player = [[AVPlayer alloc] initWithURL:[ NSURL URLWithString:fileName ] ];

  [player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];

  [[self playerPool] setObject:player forKey:key];
  [self updateJSScope: key];

  CMTime duration = player.currentItem.asset.duration;
  float seconds = CMTimeGetSeconds(duration);

  if (seconds != seconds) {
    seconds = 0;
  }

  //Set duration
  [options setValue:@(seconds) forKey:@"duration"];
  
  //Now On Air information
  [[self nowPlayingPool] setObject:options forKey:key];
  
  printf("[SPKRLOG] Player prepared\n");
  
  //callback
  callback( @[ @{ @"_duration": @(seconds) } ] );
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
  for (NSNumber *key in _playerPool) {
    AVPlayer* player = [self playerForKey:key];
    
    if (object == player.currentItem && [keyPath isEqualToString:@"status"]) {
         if (player.status == AVPlayerStatusReadyToPlay) {
           
           NSDictionary * data = @{
                                   @"_key": key,
                                   @"_isReadyToPlay": @YES
                                   };
           
           [self sendEventWithName:@"PlayerUpdate" body: data ];
           NSLog(@"[SPKRLOG] AVPlayerStatusReadyToPlay \n");
           
         } else if (player.status == AVPlayerStatusFailed) {
             // something went wrong. player.error should contain some information
         }
     }
  }
}


- (void)updateJSScope: (nonnull NSNumber*)key {
  
  AVPlayer* player = [self playerForKey:key];
  CMTime interval = CMTimeMakeWithSeconds(1, NSEC_PER_SEC); // 1 second
  
  playbackTimeObserver = [ player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
    
  NSDictionary * data = @{
                            @"_currentTime": [NSNumber numberWithFloat:CMTimeGetSeconds(time)],
                            @"_key": key,
                            @"_isPlaying": @(player.rate != 0 && player.error == nil),
//                            @"_isEnded": @true,
                          };
    if(!isSeeking) {
      [self sendEventWithName:@"PlayerUpdate" body: data ];
    }
    
  }];
}


//[player removeTimeObserver:self.playbackTimeObserver];


+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end


