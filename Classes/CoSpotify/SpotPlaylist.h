//
//  SpotPlaylist.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"

@interface SpotPlaylist : NSObject {
	struct playlist playlist;
}
-(id)initWithPlaylist:(struct playlist*)playlist_;

@property (readwrite, copy) NSString *name;
@property (readonly) NSArray *tracks;
@end
