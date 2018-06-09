#import "RNAudio.h"
//@import AVFoundation;
@import MediaPlayer;


@interface NativeRNAudio ()
  @property (nonatomic, copy) NSString *artworkUrl;
//  @property (nonatomic, assign) BOOL audioInterruptionsObserved;
@end


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

- (NSDictionary *) update:(NSMutableDictionary *) mediaDict with:(NSDictionary *) details andSetDefaults:(BOOL) setDefault {
  
  for (NSString *key in ONAIR_DICT) {
    if ([details objectForKey:key] != nil) {
      [mediaDict setValue:[details objectForKey:key] forKey:[ONAIR_DICT objectForKey:key]];
    }
    
    if ([key isEqualToString:@"speed"] && [details objectForKey:key] == nil && setDefault) {
      [mediaDict setValue:[NSNumber numberWithDouble:1] forKey:[ONAIR_DICT objectForKey:key]];
    }
  }
  
  return mediaDict;
}

- (NSString*)getArtworkUrl:(NSString*)artwork {
  NSString *artworkUrl = nil;
  
  if (artwork) {
    if ([artwork isKindOfClass:[NSString class]]) {
      artworkUrl = artwork;
    } else if ([[artwork valueForKey: @"uri"] isKindOfClass:[NSString class]]) {
      artworkUrl = [artwork valueForKey: @"uri"];
    }
  }
  
  return artworkUrl;
}

- (void)updateArtworkIfNeeded:(id)artworkUrl
{
  NSLog(@"Artwork URL %@", artworkUrl);
  
  if (artworkUrl != nil) {
    self.artworkUrl = artworkUrl;
    
    // Custom handling of artwork in another thread, will be loaded async
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      UIImage *image = nil;
      
      // check whether artwork path is present
      if (![artworkUrl isEqual: @""]) {
        // artwork is url download from the interwebs
        if ([artworkUrl hasPrefix: @"http://"] || [artworkUrl hasPrefix: @"https://"]) {
          NSURL *imageURL = [NSURL URLWithString:artworkUrl];
          NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
          image = [UIImage imageWithData:imageData];
        } else {
          NSString *localArtworkUrl = [artworkUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""];
          BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:localArtworkUrl];
          if (fileExists) {
            image = [UIImage imageNamed:localArtworkUrl];
          }
        }
      }
      
      // Check if image was available otherwise don't do anything
      if (image == nil) {
        return;
      }
      
      // check whether image is loaded
      CGImageRef cgref = [image CGImage];
      CIImage *cim = [image CIImage];
      
      if (cim != nil || cgref != NULL) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          // Check if URL wasn't changed in the meantime
          if ([artworkUrl isEqual:self.artworkUrl]) {
            MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage: image];
            NSMutableDictionary *mediaDict = (center.nowPlayingInfo != nil) ? [[NSMutableDictionary alloc] initWithDictionary: center.nowPlayingInfo] : [NSMutableDictionary dictionary];
            [mediaDict setValue:artwork forKey:MPMediaItemPropertyArtwork];
            center.nowPlayingInfo = mediaDict;
          }
        });
      }
    });
  }
}


- (void) setNowPlaying:(nonnull NSNumber*)key {
  
//  AVPlayer* player = [self playerForKey:key];

  NSMutableDictionary* details = [self nowPlayingForKey:key];

  MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
  NSMutableDictionary *onAirInfo =  [NSMutableDictionary dictionary];

  center.nowPlayingInfo = [self update:onAirInfo with:details andSetDefaults:true];

  NSString *artworkUrl = [self getArtworkUrl:[details objectForKey:@"cover"]];
  [self updateArtworkIfNeeded:artworkUrl];
  
  //Bind external displays
  printf("[SPKRLOG] Set Now Playing\n");
}


- (void) updateNowPlaying:(NSDictionary *) originalDetails {
  
  MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
  NSMutableDictionary *onAirInfo = [[NSMutableDictionary alloc] initWithDictionary: center.nowPlayingInfo];
//
  NSMutableDictionary *details = [originalDetails mutableCopy];

  [onAirInfo setValue:[details objectForKey:@"speed"]   forKey:MPNowPlayingInfoPropertyPlaybackRate];
  [onAirInfo setValue:[details objectForKey:@"elapsedTime"]   forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
  
  center.nowPlayingInfo = [self update:onAirInfo with:details andSetDefaults:false];

  NSString *artworkUrl = [self getArtworkUrl:[originalDetails objectForKey:@"cover"]];
  if (artworkUrl != self.artworkUrl && artworkUrl != nil) {
    NSLog(@"Update Image");
    self.artworkUrl = artworkUrl;
    [self updateArtworkIfNeeded:artworkUrl];
  }
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

- (void) LikeItem {
  
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
  [player play];
  if(self._key == key) {
    [self updateNowPlaying:@{
                             @"elapsedTime": [NSNumber numberWithFloat:CMTimeGetSeconds(player.currentItem.currentTime)],
                             @"speed": @1,
                             }];
  } else {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionChangeObserver:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    
    self._key = key;
    [self setNowPlaying: key];
  }
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
      
      [self updateNowPlaying:@{
                               @"elapsedTime": [NSNumber numberWithFloat: [value floatValue]],
                               @"speed":  @(player.rate != 0 && player.error == nil) ? @1 : @0
                               }];
      
      printf("[SPKRLOG] RTEADDDD\n");
      
    }
   ];
  
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
  player.allowsExternalPlayback = NO;

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
  
  //Enable external controls
  MPRemoteCommandCenter *remoteCenter = [MPRemoteCommandCenter sharedCommandCenter];
  [self toggleHandler:remoteCenter.playCommand withSelector:@selector(play) enabled:YES];
  [self toggleHandler:remoteCenter.pauseCommand withSelector:@selector(pause) enabled:YES];
  [self toggleHandler:remoteCenter.bookmarkCommand withSelector:@selector(LikeItem) enabled:YES];
  [self toggleHandler:remoteCenter.changePlaybackPositionCommand withSelector:@selector(changePlaybackPosition:) enabled:YES];
  
  remoteCenter.bookmarkCommand.localizedTitle = @"Mark position";
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


