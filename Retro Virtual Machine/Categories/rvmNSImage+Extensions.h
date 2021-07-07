//
//  rvmNSImage+Extensions.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 7/3/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSImage(rvmNSImage)

-(NSImage*)imageWithRect:(NSRect)rect;
-(NSImage*)subImageFromOffsetX:(double)ox Y:(double)oy;

@end
