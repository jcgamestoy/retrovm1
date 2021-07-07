//
//  rvmAppDelegate.h
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 01/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rvmMonitorWindowController.h"

@interface rvmAppDelegate : NSObject <NSApplicationDelegate>

-(rvmMonitorWindowController*)newWindow:(id)sender machine:(id)machine;
-(void)removeWindow:(NSWindow*)w;

-(NSOpenPanel*)openPanel;
-(NSSavePanel*)savePanel;
@end
