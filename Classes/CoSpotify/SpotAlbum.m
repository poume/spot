//
//  SpotAlbum.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotAlbum.h"
#import "SpotTrack.h"
#import "SpotSession.h"
#import "SpotURI.h"

@implementation SpotAlbum

@synthesize browsing;
@synthesize version, name, artistName, artistId, type, year, coverId, review, copyright, allowed, catalogues, similarAlbumIds, discs, popularity;

-(id)initWithAlbum:(struct album*)album;
{
	if( ! [super init] ) return nil;
	
  browsing = NO;

  name = [[NSString alloc] initWithUTF8String:album->name];
  albumId = [[NSString alloc] initWithUTF8String:album->id];
  artistName = [[NSString alloc] initWithUTF8String:album->artist];
  artistId = [[NSString alloc] initWithUTF8String:album->artist_id];
  coverId  = [[NSString alloc] initWithUTF8String:album->cover_id];
  popularity = album->popularity;
  
  return self;
}

-(void)loadBrowse:(struct album_browse*)album;
{
  browsing = YES;
  
  name = [[NSString alloc] initWithUTF8String:album->name];
  albumId = [[NSString alloc] initWithUTF8String:album->id];
  year = album->year;
  coverId = [[NSString alloc] initWithUTF8String:album->cover_id];
  popularity = album->popularity;
  artistName = [[NSString alloc] initWithUTF8String:album->artist];
  artistId = [[NSString alloc] initWithUTF8String:album->artist_id];
  if(album->review)
    review = [[NSString alloc] initWithUTF8String:album->review];
  
  
  //TODO: multiple discs when despotify has support for it
  NSMutableArray *tracks = [NSMutableArray array];
  for(struct track *track = album->tracks; track != NULL; track = track->next){
    SpotTrack *a_track = [[SpotTrack alloc] initWithTrack:track];
    [tracks addObject:a_track];
    [a_track release];
  }
  SpotPlaylist *disc = [[SpotPlaylist alloc] initWithName:name author:nil tracks:tracks];
  discs = [[NSArray alloc] initWithObjects:disc, nil];
  [disc release];
}


-(id)initWithAlbumBrowse:(struct album_browse*)album;
{
  if( ! [super init] ) return nil;
  
  [self loadBrowse:album];
  
  return self;
}

-(void)dealloc;
{
  [albumId release];
  [name release];
  [artistName release];
  [artistId release];
  [type release];
  [coverId release];
  [review release];
  [copyright release];
  [allowed release];
  [catalogues release];
  [similarAlbumIds release];
  [discs release];
  [playlist dealloc];
  [artist release];
  [super dealloc];
}

-(void)loadMoreInfo;
{
  if(!browsing){
    NSLog(@"Album %@ loading more info", self);
    struct album_browse *ab = despotify_get_album([SpotSession defaultSession].session, (char*)[albumId UTF8String]);
    [self loadBrowse:ab];
  }
}

-(NSComparisonResult)compare:(SpotAlbum*)other;
{
  return [self.name compare:other.name];
}

#pragma mark shared
-(NSString *)id; { return albumId; }
-(SpotURI*)uri;
{
//  char uri[50];
//  return [SpotURI uriWithURI:despotify_album_to_uri(&albumBrowse, uri)];  
  return nil;
}


-(SpotPlaylist*)playlist;
{
  if(!browsing) [self loadMoreInfo];
  return [discs lastObject];
}

-(SpotArtist *)artist;
{
  if(!artist)
    artist = [[[SpotSession defaultSession] artistById:artistId] retain];
  return artist;
}

-(BOOL)isEqual:(SpotAlbum*)other;
{
  return [self hash] == [other hash];
}

-(NSUInteger)hash;
{
  return [self.artistId hash];
}

@end
