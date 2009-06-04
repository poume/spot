//
//  SpotImage.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotItem.h"

// Put this in UIImageResizing.h
@interface UIImage (Resize)
- (UIImage*)scaleToSize:(CGSize)size;
@end

//Represents an image (mainly for the cache)

@interface SpotImage : SpotItem {
  NSString *imageId;
  UIImage *image;
  UIImage *cellImage;
}

//init with default image
-(id)initWithImageData:(NSData *)data id:(NSString*)id_;;

@property (readonly, nonatomic) UIImage *image;
@property (readonly, nonatomic) UIImage *cellImage;

@end
