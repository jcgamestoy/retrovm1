//
//  rvmMatrix.h
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 06/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rvmMatrix : NSObject
{
  float _data[16];
}

@property (readonly) float* ptr;

+(rvmMatrix*)orthoFromRect:(CGRect)rect;
+(rvmMatrix*)orthoLeft:(float)left right:(float)right top:(float)top bottom:(float)bottom near:(float)near far:(float)far;

@end
