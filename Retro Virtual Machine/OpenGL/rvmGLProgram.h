//
//  rvmGLProgram.h
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 06/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmMatrix.h"

@interface rvmGLProgram : NSObject

@property (readonly) NSDictionary *attributes;

+(rvmGLProgram *)newWithVertexShader:(const char *)vs fragmentShader:(const char *)fs attributes:(NSArray*)attributeNames;

-(void)use;
-(void)uniformFloat:(float)f named:(NSString*)name;
-(void)uniformVec2X:(float)x y:(float)y named:(NSString*)name;
-(void)uniformMatrix:(rvmMatrix*)matrix named:(NSString*)name;
-(void)uniformTextureUnit:(int)unit named:(NSString*)name;
-(void)destroy;

@end
