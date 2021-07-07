//
//  NSData+Gzip.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 19/12/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (GZIP)

-(NSData *)deflate;
-(NSData *)inflate;
-(NSData*)gunzip;
-(NSData*)gzip;
-(uint32)crc32;

@end
