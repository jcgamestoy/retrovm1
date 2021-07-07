//
//  rvmTripleBuffer.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 23/01/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rvmTripleBuffer : NSObject

+(rvmTripleBuffer*)tripleBufferWithWidth:(uint32)x height:(uint32)y;

@property uint32 width;
@property uint32 height;

-(uint32*)get;
-(uint32*)swap;
-(uint32*)selected;
-(uint32*)work;

-(NSImage*)snapshot;
-(NSData*)dataSnapshot;

@end
