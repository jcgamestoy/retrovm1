//
//  rvmSnapshotDecoderProtocol.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 8/3/16.
//  Copyright © 2016 Juan Carlos González Amestoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rvmMachineProtocol.h"

@protocol rvmSnapshotDecoderProtocol <NSObject>

+(NSDictionary*)import:(NSDictionary*)model data:(NSData*)data machine:(id<rvmMachineProtocol>)machine onError:(void (^)(NSString* err))onerror;
+(NSData*)export:(NSDictionary*)snap;
@end
