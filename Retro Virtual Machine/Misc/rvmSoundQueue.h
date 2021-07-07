//
//  rvmFifo.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 09/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rvmSoundQueue : NSObject

+(rvmSoundQueue*)queue;

-(int)write:(int16_t*)data count:(uint)bytes;
-(int)read:(int16_t*)data count:(uint)bytes;
-(int)used;


@end
