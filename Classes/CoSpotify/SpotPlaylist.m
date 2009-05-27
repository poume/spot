//
//  SpotPlaylist.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotPlaylist.h"
#import "SpotTrack.h"
#import "SpotSession.h"
#import "SpotURI.h"

@implementation SpotPlaylist
-(id)init;
{
  if( ! [super init] ) return nil;
  
  memset(&playlist, 0, sizeof(struct playlist));
	tracks = [[NSMutableArray alloc] init];
	playlist.num_tracks = 0;
  self.name = @"Untitled";
  return self;
}

-(id)initWithPlaylist:(struct playlist*)playlist_;
{
	if( ! [super init] ) return nil;
	
	memcpy(&playlist, playlist_, sizeof(struct playlist));
	
	tracks = [[NSMutableArray alloc] initWithCapacity:playlist.num_tracks];
  if(playlist.num_tracks > 0){
    for(struct track *track = playlist.tracks; track != NULL; track = track->next) {
      SpotTrack *strack = [[(SpotTrack*)[SpotTrack alloc] initWithTrack:track] autorelease];
      [(NSMutableArray*)tracks addObject:strack];
      strack.playlist = self;
    }
  }	
	return self;
}

-(id)initWithTrack:(SpotTrack*)track;
{
	if( ! [super init] ) return nil;
	
	memset(&playlist, 0, sizeof(struct playlist));
	tracks = [[NSMutableArray alloc] initWithObjects:track, nil];
	track.playlist = self;
	track.getTrack->next = NULL;
	playlist.num_tracks = 1;
	
	return self;
}

-(void)dealloc;
{
	[tracks release];
	[super dealloc];
}

-(SpotTrack*) trackBefore:(SpotTrack*)current;
{
  int i = [tracks indexOfObject:current]-1;
  if(i < 0) return nil;
  return [tracks objectAtIndex:i];
}

-(SpotTrack*) trackAfter:(SpotTrack*)current;
{
  int i = [tracks indexOfObject:current]+1;
  if(i >= tracks.count) return nil;
  return [tracks objectAtIndex:i];  
}

-(SpotTrack*) trackWithId:(SpotId*)id;
{
  for(SpotTrack *track in tracks)
    if([track.id isEqual:id]) return track;
  return nil;
}

#pragma mark Properties

-(NSString*)name;
{
  if(strlen(playlist.name) == 0) return @"Untitled";
	return [NSString stringWithUTF8String:playlist.name];
}

-(void)setName:(NSString*)name_;
{
	despotify_rename_playlist([SpotSession defaultSession].session, &playlist, (char*)[name_ UTF8String]);
	// todo: handle error
}

-(NSString *)author; { return [NSString stringWithCString:playlist.author];}
-(BOOL) collaborative; {return playlist.is_collaborative; } 
-(void) setCollaborative:(BOOL)collab;
{
  despotify_set_playlist_collaboration([SpotSession defaultSession].session, &playlist, collab);
  // todo: handle error
}

@synthesize tracks;

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotPlaylist %@ %@>", self.name, self.tracks];
}

+(SpotPlaylist *)byId:(SpotId *)id session:(SpotSession*)session;
{
  if(!session) session = [SpotSession defaultSession];
  struct playlist* pl = despotify_get_playlist(session.session, id.id);
  if(!pl) return nil;
  return [[[SpotPlaylist alloc] initWithPlaylist:pl] autorelease];
}

@end


@implementation SpotMutablePlaylist

-(void)addTrack:(SpotTrack*)track;
{
  SpotTrack *lastTrack = [tracks lastObject];
  if(lastTrack)
    lastTrack.getTrack->next = track.getTrack;
  track.getTrack->next = NULL;
  track.playlist = self;
  [(NSMutableArray*)tracks addObject: track];
  playlist.num_tracks = [tracks count];
}

-(BOOL)isEqual:(SpotPlaylist*)other;
{
  return [self hash] == [other hash];
}

-(NSInteger)hash;
{
  return [[NSString stringWithFormat:@"%@%@", self.author, self.name] hash];
}

-(SpotId*)id;
{
  return [SpotId playlistId:(char*)playlist.playlist_id];
}

-(SpotURI*)uri;
{
  char uri[50];
  return [SpotURI uriWithURI:despotify_playlist_to_uri(&playlist, uri)];  
}

@end

