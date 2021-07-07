//
//  rvmConsoleView.h
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 17/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol rvmConsoleViewDelegate <NSObject>

-(NSAttributedString*)doCmd:(NSString*)cmd;

@end

@interface rvmConsoleView : NSTextView<NSTextViewDelegate>

@property id<rvmConsoleViewDelegate> commandDelegate;

- (void)appendString:(NSAttributedString *)a;

@end
