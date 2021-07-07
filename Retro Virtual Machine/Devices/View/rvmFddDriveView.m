//
//  rvmFddDriveView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 28/07/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmFddDriveView.h"
#import "NSColor+rvmNSColors.h"

@interface rvmFddDriveView()


@end

@implementation rvmFddDriveView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)initPositions
{
  chasis.frame=NSMakeRect(0, 0, 379, 215);
  led.frame=NSMakeRect(85, 40, 15, 5);
  diskLome.frame=NSMakeRect(79-4, 57+4, 275, 18);
  diskName.frame=NSMakeRect(130-4,55+4, 170, 18);
  led.backgroundColor=[NSColor darkGreen].CGColor;
}

-(void)setChasisImage
{
  chasis.contents=[NSImage imageNamed:@"FddDrive"];
}

-(void)awakeFromNib
{
  [super awakeFromNib];
  _switchSound=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Disk Sounds/Switch" ofType:@"wav"] byReference:YES];
  _powerLed=[CALayer layer];
  _powerLed.frame=NSMakeRect(30, 30, 15, 5);
  _powerLed.backgroundColor=[NSColor sienna].CGColor;
  
  [self.layer addSublayer:_powerLed];
}

-(void)led:(uint32)b
{
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
  led.backgroundColor=[NSColor colorWithDeviceRed:0 green:0.5+(b/70908.0) blue:0 alpha:1].CGColor;
  //change background colour
  [CATransaction commit];
}
@end
