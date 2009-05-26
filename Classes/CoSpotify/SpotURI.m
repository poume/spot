//
//  SpotURI.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotURI.h"

#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotTrack.h"
#import "SpotPlaylist.h"
#import "SpotSearch.h"

@implementation SpotURI

@synthesize link;

+(SpotURI*)uriWithId:(SpotId*)id;
{
  char uri[50];
  despotify_id2uri(id.id, uri);
  return [SpotURI uriWithURI:uri];
}

+(SpotURI*)uriWithURI:(const char *)uri;
{
  return [[[SpotURI alloc] initWithURI:uri] autorelease];
}

+(SpotURI*)uriWithURL:(NSURL *)url;
{
  NSArray *a = [[url path] componentsSeparatedByString:@"/"];
  NSString *typestr = [a objectAtIndex:1];
  NSString *arg = [a objectAtIndex:2];
  const char *ctypestr = [typestr cStringUsingEncoding:NSASCIIStringEncoding];
  const char *carg = [arg cStringUsingEncoding:NSASCIIStringEncoding];
  char uri[256];
  sprintf(uri, "spotify:%s:%s", ctypestr, carg);
  return [[[SpotURI alloc] initWithURI:uri] autorelease];
}

+(SpotURI*)uriWithString:(NSString *)string;
{
  if([string hasPrefix:@"spotify:"])
    return [SpotURI uriWithURI:[string cStringUsingEncoding:NSASCIIStringEncoding]];
  else if([string hasPrefix:@"http://"])
    return [SpotURI uriWithURL:[NSURL URLWithString:string]];
  return nil;
}

-(id)initWithURI:(const char*)uri_;
{
  if( ! [super init] ) return nil;
  strcpy(uriBuffer, uri_);
  link = despotify_link_from_uri(uriBuffer);
  
  return self;
}

-(void)dealloc;
{
  despotify_free_link(link);
  [super dealloc];
}

-(SpotLinkType) type;
{
  return link->type;
}

-(NSString *)uri;
{
  return [NSString stringWithCString:link->uri encoding:NSASCIIStringEncoding];
}

-(NSString *)typeString;
{
  static char *typestrings[6] = {
    "",
    "album",
    "artist",
    "playlist",
    "search",
    "track"
  };
  return [NSString stringWithUTF8String:typestrings[link->type]];
}

-(NSString *)url;
{
  return [NSString stringWithFormat:@"http://open.spotify.com/%@/%s", [self typeString], link->arg];
}

-(NSString *)description;
{
  return [NSString stringWithFormat:@"<SpotURI type:%@ arg:%s uri:%@ url:%@>", [self typeString], link->arg, [self uri], [self url]];
}

@end
