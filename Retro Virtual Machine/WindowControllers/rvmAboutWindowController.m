//
//  rvmAboutWindowController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 22/4/15.
//  Copyright (c) 2015 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAboutWindowController.h"
#import "NSColor+rvmNSColors.h"

@interface rvmAboutWindowController ()
@property (unsafe_unretained) IBOutlet NSTextView *textZone;

@end

@implementation rvmAboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
  
  
  [_textZone setTextColor:[NSColor lightGrey]];
  _textZone.string=[NSString stringWithFormat:@"Retro Virtual Machine %@ (%@)\n"
                    "©2013 - 18 Juan Carlos González Amestoy.\n\n"
                    "Thanks to:\n"
                    "\tKounch for test the Recreated Zx Spectrum keyboard.\n"
                    "\tPatrick Rak for their test programs and the PZX file format.\n"
                    "\tMike Pall for the LuaJIT vm without which RVM would not have been possible."
                    "\tCésar Hernández Baño for all his help. Thanks friend.\n"
                    "\tMiguel Ángel Rodríguez Jódar for the detailed article about the Inves Spectrum+\n"
                    
                    
                    
                    
                    
                    ,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
                    
                    
                    
                    ];
}

@end
