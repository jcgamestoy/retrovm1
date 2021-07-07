//
//  NSFileWrapper+Extension.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 13/10/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "NSFileWrapper+Extension.h"

@implementation NSFileWrapper(NSFileWrapper_ext)

-(void)updateContents:(NSData *)contents filename:(NSString *)filename
{
  NSFileWrapper *fw=self.fileWrappers[filename];
  
  if(fw)
    [self removeFileWrapper:fw];
  
  [self addRegularFileWithContents:contents preferredFilename:filename];
}

@end
