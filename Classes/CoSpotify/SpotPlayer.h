//
//  SpotPlayer.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotSession;
@class SpotTrack;
@class SpotPlaylist;

@interface SpotPlayer : NSObject {
  SpotSession *session;
  
  SpotTrack *currentTrack;
  SpotPlaylist *currentPlaylist;
  
  BOOL isPlaying;
}

-(id)initWithSession:(SpotSession*)session;

-(void)playTrack:(SpotTrack*)track rewind:(BOOL)rewind;
-(void)playPlaylist:(SpotPlaylist*)playlist firstTrack:(SpotTrack*)track;
-(void)pause;
-(void)play; //resume current track
-(void)stop;
-(void)playNextTrack;
-(void)playPreviousTrack;

@property (readonly, retain) SpotTrack *currentTrack;
@property (readonly, retain) SpotPlaylist *currentPlaylist;
@property (readwrite) BOOL isPlaying;
@property (readonly) SpotTrack *savedTrack;

@end
