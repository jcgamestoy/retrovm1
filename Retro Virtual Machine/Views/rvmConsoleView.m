//
//  rvmConsoleView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 17/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmConsoleView.h"
#import "NSColor+rvmNSColors.h"
#import "rvmDebugViewController.h"

@interface rvmConsoleView()
{
  NSRange lastLine;
  NSDictionary *defaultAttr;
}

@end

@implementation rvmConsoleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      NSLog(@"created");
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  defaultAttr=@{NSForegroundColorAttributeName:[NSColor white],
                NSFontAttributeName:[NSFont fontWithName:@"Menlo-Regular" size:13],
                NSFontSizeAttribute:@13
                };
  self.delegate=self;
  [self setTypingAttributes:defaultAttr];
  
  [self.textStorage beginEditing];
  [self.textStorage appendAttributedString:[self copyright]];
  [self.textStorage appendAttributedString:[self prompt]];
  [self.textStorage endEditing];
  
  lastLine=NSMakeRange(self.textStorage.length, 0);
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(void)moveUp:(id)sender
{
  NSLog(@"up");
}

-(void)moveDown:(id)sender
{
  NSLog(@"down");
}

-(BOOL)shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
//  if(affectedCharRange.location>lastLine.location) return YES;
//  else return NO;
  if(affectedCharRange.location>=lastLine.location) return YES;
  
  NSTextStorage *ts=self.textStorage;
  
  [ts beginEditing];
  [ts appendAttributedString:[[NSAttributedString alloc] initWithString:replacementString attributes:defaultAttr]];
  [ts endEditing];
  
  NSRange r=NSMakeRange([ts length], 0);
  
  [self setSelectedRange:r];
  [self scrollRangeToVisible:r];
  
  return NO;
}

-(NSAttributedString*)prompt
{
  return [[NSAttributedString alloc] initWithString:@"\n> " attributes:defaultAttr];
}

-(NSAttributedString*)copyright
{
  NSMutableAttributedString *ms=[NSMutableAttributedString new];
  
  NSMutableDictionary *attr=[NSMutableDictionary dictionaryWithDictionary:defaultAttr];
  
  attr[NSForegroundColorAttributeName]=[NSColor teal];
  
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@"Retro Virtual Machine v0.1\n" attributes:attr]];
  attr[NSForegroundColorAttributeName]=[NSColor khaki];
  [ms appendAttributedString:[[NSAttributedString alloc] initWithString:@"©2013 Juan Carlos González Amestoy" attributes:attr]];
  
  NSMutableParagraphStyle *p=[NSMutableParagraphStyle new];
  [p setAlignment:NSCenterTextAlignment];
  [ms addAttributes:@{NSParagraphStyleAttributeName:p} range:NSMakeRange(0, [ms length])];
  
  return ms;
}

- (void)appendString:(NSAttributedString *)a
{
  [self.textStorage beginEditing];
  [self.textStorage appendAttributedString:a];
  [self.textStorage appendAttributedString:[self prompt]];
  [self.textStorage endEditing];
  
  lastLine=NSMakeRange(self.textStorage.length, 0);
  [self scrollRangeToVisible:lastLine];
}

-(void)insertNewline:(id)sender
{
  NSRange r=NSMakeRange(self.textStorage.length,0);
  
  NSUInteger ls,le,ce;
  [self.textStorage.string getLineStart:&ls end:&le contentsEnd:&ce forRange:r];
  NSRange l=NSMakeRange(lastLine.location, le-lastLine.location);
  //NSLog(@"Line: %@",[self.textStorage.string substringWithRange:l]);
  
  NSAttributedString *a;
  
  if(l.length)
  {
    a=[_commandDelegate doCmd:[self.textStorage.string substringWithRange:l]];
  }
  else
  {
    a=[_commandDelegate doCmd:@""];
  }
  
  [super insertNewline:sender];
  
  if(a)
  {
    [self appendString:a];
  }
  
  
}

-(NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex
{
  return nil;
}

-(NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange
{
  if(newSelectedCharRange.location<lastLine.location)
    return oldSelectedCharRange;
  else
    return newSelectedCharRange;
}


- (void)drawInsertionPointInRect:(NSRect)aRect color:(NSColor *)aColor turnedOn:(BOOL)flag {
  aRect.size.width = 10.0;
  [aColor setFill];
  NSRectFillUsingOperation(aRect, NSCompositeLighten);
  //[super drawInsertionPointInRect:aRect color:[NSColor limeWithAlpha:0.4] turnedOn:flag];
}

// This is a hack to get the caret drawing to work. I know, I know.
- (void)setNeedsDisplayInRect:(NSRect)invalidRect {
  invalidRect.size.width += 10.0 - 1;
  [super setNeedsDisplayInRect:invalidRect];
}
@end
