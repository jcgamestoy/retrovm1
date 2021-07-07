//
//  rvmGLTexture.h
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 07/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rvmGLTexture : NSObject
{
  unsigned int tid;
}

@property int width,height;

+(rvmGLTexture*)initWithWidth:(int)w height:(int)h;

-(void)update:(void*)buffer;
-(void)nearest;
-(void)linear;
-(void)repeat;
-(void)use:(int)unit;
-(void)destroy;

@end
