//
//  SpotSession.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotSession.h"
#import "SpotPlaylist.h"
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <wchar.h>

#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotTrack.h"
#import "SpotSearch.h"

#import <UIKit/UIKit.h>


SpotSession *SpotSessionSingleton;

NSString *SpotSessionErrorDomain = @"SpotSessionErrorDomain";

#pragma mark Callbacks

@interface SpotPlayer (ForSessionOnly)
-(void)trackDidStart;
-(void)trackDidEnd;
@end


void cb_got_xml(struct despotify_session *ds, char* xml){
  SpotSession *ss = (SpotSession*)ds->user_data;
  [ss performSelectorOnMainThread:@selector(receivedXML:) withObject:[NSString stringWithUTF8String:xml] waitUntilDone:NO];
}

void cb_track_start(struct despotify_session *ds){
  SpotSession *ss = (SpotSession*)ds->user_data;
  [ss.player performSelectorOnMainThread:@selector(trackDidStart) withObject:nil waitUntilDone:NO];
}

void cb_track_end(struct despotify_session *ds){
  SpotSession *ss = (SpotSession*)ds->user_data;
  [ss.player performSelectorOnMainThread:@selector(trackDidEnd) withObject:nil waitUntilDone:NO];
}

@interface SpotSession ()
@property (nonatomic, readwrite) BOOL loggedIn;
-(void)receivedXML:(NSString*)xmlString;

@end


@implementation SpotSession
@synthesize loggedIn, session, player;

+(SpotSession*)defaultSession;
{
	if(!SpotSessionSingleton)
		SpotSessionSingleton = [[SpotSession alloc] init];
	
	return SpotSessionSingleton;
}

-(id)init;
{
	if( ! [super init] ) return nil;
	
	if(!despotify_init()) {
		NSLog(@"Init failed");
		[self release];
		return nil;
	}
	
	session = despotify_init_client();
	if( !session) {
		NSLog(@"Init client failed");
		[self release];
		return nil;
	}
  
  session->user_data = self;
  session->cb_track_start = cb_track_start;
  session->cb_track_end = cb_track_end;
  session->cb_got_xml = cb_got_xml;
  
  player = [[SpotPlayer alloc] initWithSession:self];
	
	self.loggedIn = NO;
	
	return self;
}

-(void)dealloc;
{
	NSLog(@"Logged out");
  [player release];
	despotify_exit(session);
	despotify_cleanup();
	[super dealloc];
}

-(void)cleanup;
{
	[self release];
	SpotSessionSingleton = nil;
}

-(BOOL)authenticate:(NSString *)user password:(NSString*)password error:(NSError**)error;
{
	BOOL success = despotify_authenticate(session, [user UTF8String], [password UTF8String]);
	if(!success && error)
		*error = [NSError errorWithDomain:SpotSessionErrorDomain code:SpotSessionErrorCodeDefault userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%s", despotify_get_error(session)] forKey:NSLocalizedDescriptionKey]];
	usleep(500000);
	if(success) {
		NSLog(@"Successfully logged in as %@", user);
	}
	self.loggedIn = success;
	return success;
}

-(void)receivedXML:(NSString*)xmlString;
{
  NSLog(@"Got some XML:\n%@", xmlString);
 
}

-(NSArray*)playlists;
{
	NSMutableArray *playlists = [NSMutableArray array];
	return playlists; // until they fix their playlist servers
	
	struct playlist *rootlist = despotify_get_stored_playlists(session);
  NSLog(@"got lists");
	for(struct playlist *pl = rootlist; pl; pl = pl->next) {
		SpotPlaylist *playlist = [[[SpotPlaylist alloc] initWithPlaylist:pl] autorelease];
		[playlists addObject:playlist];
	}
	despotify_free_playlist(rootlist);
	
	return playlists;
}


-(NSString*)username;
{
	return [NSString stringWithUTF8String:session->user_info->username];	
}
-(NSString*)country;
{
	return [NSString stringWithUTF8String:session->user_info->country];
}
-(NSString*)accountType;
{
	return [NSString stringWithUTF8String:session->user_info->type];
}
-(NSDate*)expires;
{
	return [NSDate dateWithTimeIntervalSince1970:session->user_info->expiry];
}
-(NSString*)serverHost;
{
	return [NSString stringWithUTF8String:session->user_info->server_host];
}
-(NSUInteger)serverPort;
{
	return session->user_info->server_port;
}
-(NSDate*)lastPing;
{
	return [NSDate dateWithTimeIntervalSince1970:session->user_info->last_ping];
}

#pragma mark Get by id functions

-(SpotArtist *)artistById:(SpotId *)id;
{
  struct artist_browse *artist = despotify_get_artist(session, id.id);
  if(artist) return [[[SpotArtist alloc] initWithArtistBrowse:artist] autorelease];
  return nil;
}

-(void *)imageById:(SpotId*)id;
{
  int len = 0;
  void *jpegdata = despotify_get_image(session, id.id, &len);
  if(len > 0){
    UIImage *image = [UIImage imageWithData:[NSData dataWithBytes:jpegdata length:len]];
    free(jpegdata);
    return image;
  } 
  return nil;
}

-(SpotAlbum *)albumById:(SpotId *)id;
{
  struct album_browse *ab = despotify_get_album(session, id.id);
  if(ab) return [[[SpotAlbum alloc] initWithAlbumBrowse:ab] autorelease];
  return nil;
}

-(SpotTrack *)trackById:(SpotId *)id;
{
  struct track *track = despotify_get_track(session, id.id);
  if(track) return [[(SpotTrack*)[SpotTrack alloc] initWithTrack:track] autorelease];
  return nil;
}

#pragma mark Get by uri
-(SpotAlbum*)albumByURI:(SpotURI*)uri;
{
  struct album_browse* ab = despotify_link_get_album(session, uri.link);
  return [[[SpotAlbum alloc] initWithAlbumBrowse:ab] autorelease];
}

-(SpotArtist*)artistByURI:(SpotURI*)uri;
{
  struct artist_browse* ab = despotify_link_get_artist(session, uri.link);
  return [[[SpotArtist alloc] initWithArtistBrowse:ab] autorelease];
}

-(SpotTrack*)trackByURI:(SpotURI*)uri;
{
  struct track* track = despotify_link_get_track(session, uri.link);
  return [[(SpotTrack*)[SpotTrack alloc] initWithTrack:track] autorelease];
}

-(SpotPlaylist*)playlistByURI:(SpotURI*)uri;
{
  struct playlist* pl = despotify_link_get_playlist(session, uri.link);
  return [[[SpotPlaylist alloc] initWithPlaylist:pl] autorelease];
}

-(SpotSearch*)searchByURI:(SpotURI*)uri;
{
  struct search_result* sr = despotify_link_get_search(session, uri.link);
  return [[[SpotSearch alloc] initWithSearchResult:sr] autorelease];
}


-(SpotItem *)cachedItemId:(SpotId *)id_ ensureFullProfile:(BOOL)full;
{
  SpotItem *item;// = [cache valueForKey:id_];
  if(!item){
    //TODO: Load it (how do we know type? send as arg, one func per type or store in SpotId?
    //Discussion: 
    // * SpotId is quite obsolete. really think we can/shud use NSString instead.
    // * Dont do loading here, let caller handle it if no item found.
  }
  return item;
}

@end
