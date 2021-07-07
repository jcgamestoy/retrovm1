//
//  rvmOSDViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 30/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmOSDViewController.h"
#import "NSColor+rvmNSColors.h"
#import "rvmImageView.h"

@interface rvmOSDViewController ()
{
  //bool showing;
  long mid;
  __weak IBOutlet rvmImageView *imgView;
  __weak IBOutlet NSLayoutConstraint *imgWidth;
}

@end

@implementation rvmOSDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
  //_background.cornerRadious=24;
  //_background.backgroundColor=[NSColor blackWithAlpha:0.5];
  //_background.lineColor=[NSColor clearColor];
  _visible=true;
  [self.view setHidden:YES];
  self.view.alphaValue=0;
  mid=0;
}

-(void)showMessage:(NSString *)message size:(uint)size image:(NSImage*)image
{
  if(_visible)
  {
    mid++;
    [self.view setHidden:NO];
    _label.font=[NSFont fontWithName:@"Verdana" size:size];
    [_label setStringValue:message];
    
    if(image)
    {
      imgView.image=image;
      imgWidth.constant=image.size.width*60.0/image.size.height;
    }
    else
    {
      imgView.image=nil;
      imgWidth.constant=0;
    }
    
    long midd=mid;
    self.view.alphaValue=0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration=2.0;
      self.view.animator.alphaValue=1.0;
    } completionHandler:^{
      double delayInSeconds = 2.0;
      dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
      dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(self->mid==midd)
        {
          if(self->_fixedText) [self fixedText:self->_fixedText image:self->_fixedImage];//self.fixedText=_fixedText; //Vuelve a mostrar el mensaje fijo si existe...
        else
        {
          [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration=2.0;
            self.view.animator.alphaValue=0;
          } completionHandler:^{
         
          }];
        }
        }
      });
    }];
  }
}

-(void) showMessage:(NSString *)message image:(NSImage*)image
{
  [self showMessage:message size:22 image:image];
}

-(void)fixedText:(NSString *)fixedText image:(NSImage*)image
{
  _fixedText=fixedText;
  _fixedImage=image;
  _label.font=[NSFont fontWithName:@"Verdana" size:22];
  
  if(image)
  {
    imgView.image=image;
    imgWidth.constant=image.size.width*60.0/image.size.height;
  }
  else
  {
    imgView.image=nil;
    imgWidth.constant=0;
  }
  
  if(_fixedText)
  {
    [_label setStringValue:_fixedText];
    [self.view setHidden:!_visible];
    self.view.alphaValue=_visible?1.0:0.0;
  }
  else
  {
    [self.view setHidden:YES];
  }
}

-(void)setVisible:(bool)visible
{
  _visible=visible;
  
  if(_fixedText)
  {
    [self.view setHidden:!_visible];
    [self.label setStringValue:_fixedText];
  }
}
@end
