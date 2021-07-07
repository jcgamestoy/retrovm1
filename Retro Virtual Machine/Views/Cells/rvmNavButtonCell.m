//
//  rvmNavButtonCell.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 24/03/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmNavButtonCell.h"

@interface rvmNavButtonCell()
{
  bool over;
  
  NSImage *front,*inter,*back,*frontOver,*interOver,*backOver;
}

@end

@implementation rvmNavButtonCell

-(NSAttributedString*)createAtributtedString
{
  NSMutableParagraphStyle *st=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [st setAlignment:NSCenterTextAlignment];
  
  NSColor *txtColor = [NSColor whiteColor];
  NSDictionary *txtDict=@{NSForegroundColorAttributeName:txtColor,NSParagraphStyleAttributeName:st,NSFontAttributeName:self.font};

  return [[NSAttributedString alloc]
                                  initWithString:[self title] attributes:txtDict];
  
  //[[attrStrTextField cell] setAttributedStringValue:attrStr];
  //[attrStrTextField updateCell:[attrStrTextField cell]];
  
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  NSRect r=NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, front.size.width, cellFrame.size.height);
  if(over) [frontOver drawInRect:r]; else [front drawInRect:r];
  
  r=NSMakeRect(cellFrame.origin.x+front.size.width, cellFrame.origin.y, cellFrame.size.width-front.size.width-back.size.width, cellFrame.size.height);
  if(over) [interOver drawInRect:r]; else [inter drawInRect:r];
  
  r=NSMakeRect(cellFrame.origin.x+cellFrame.size.width-back.size.width, cellFrame.origin.y, back.size.width, cellFrame.size.height);
  
  if(over) [backOver drawInRect:r]; else [back drawInRect:r];
  
  r=cellFrame;
  r.size.height=r.size.height-4;
  [super drawTitle:[self createAtributtedString] withFrame:r inView:controlView];
}

-(void)setImageName:(NSString *)imageName
{
  _imageName=imageName;
  front=[NSImage imageNamed:[NSString stringWithFormat:@"%@ Front",_imageName]];
  inter=[NSImage imageNamed:[NSString stringWithFormat:@"%@ Inter",_imageName ]];
  back=[NSImage imageNamed:[NSString stringWithFormat:@"%@ Back",_imageName]];
  
  frontOver=[NSImage imageNamed:[NSString stringWithFormat:@"%@ Front Over",_imageName]];
  interOver=[NSImage imageNamed:[NSString stringWithFormat:@"%@ Inter Over",_imageName ]];
  backOver=[NSImage imageNamed:[NSString stringWithFormat:@"%@ Back Over",_imageName]];
}

-(void)mouseEntered:(NSEvent *)event
{
  over=YES;
  [self.controlView setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)event
{
  over=NO;
  [self.controlView setNeedsDisplay:YES];
}

-(BOOL)showsBorderOnlyWhileMouseInside
{
  return YES;
}



@end
