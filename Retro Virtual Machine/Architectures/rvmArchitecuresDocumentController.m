//
//  rvmArchitecuresDocumentController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 10/02/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmArchitecuresDocumentController.h"

@implementation rvmArchitecuresDocumentController

-(NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
  if([url.pathExtension isEqualToString:@"rvmMachine"])
    return @"com.madeInAlacant.rvmMachine";
  
  
  if([url.pathExtension isEqualToString:@"rvmMachine"])
    return @"com.madeInAlacant.tzx";
  
  return nil;
}

@end
