//
//  NSFileWrapper+Extension.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileWrapper(NSFileWrapper_ext)

-(void)updateContents:(NSData*)contents filename:(NSString*)filename;

@end
