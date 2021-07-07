//
//  rvmPlus2DatacorderView.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPlus2DatacorderView.h"

#import "NSColor+rvmNSColors.h"
#import "rvmTapeBlockProtocol.h"
#import "rvmTapeBlocks.h"
#import "rvmRemovableTableCellView.h"

#define maxR 130
#define maxR2 maxR-72

#define kStopped 0
#define kPlaying 1
#define kRew     2
#define kFwd     3
#define kRecording 4

@interface rvmPlus2DatacorderView()
{
  CALayer *chasis,*cassette;//*TZXCassette,*TAPCassette,*PZXCassette,*CSWCassette;
  CALayer *chasisDoor,*wheel1,*wheel2,*carrete1,*carrete2;
  
  CATextLayer *cassetteName,*blockName;
  
  CGPoint w1p,w2p;
  CABasicAnimation *playingA,*rewA,*fwdA;
  
  NSSound *buttonS,*ejectS,*playingS,*rewS,*releaseS;
  NSArray *blockDescription;
  
  uint state;
}

@end

@implementation rvmPlus2DatacorderView

@synthesize delta;
@synthesize length;
@synthesize cassetteTitle;
@synthesize blockTitle;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(NSImage*)chasisImage
{
  return [NSImage imageNamed:@"chasis+2"];
}

-(NSImage*)chasisDoorImage
{
  return [NSImage imageNamed:@"chasisDoor+2"];;
}

-(CGRect)chasisFrame
{
  return CGRectMake(0, 0, 456, 481);
}

-(CGRect)chasisDoorFrame
{
  return CGRectMake(89,504-200-137, 321, 200);
}

-(CGRect)cassetteFrame
{
  return CGRectMake(95-3.5,504-198-142+2.5,305+8,190+8);
}

-(CGPoint)wheel1Point
{
  return CGPointMake(133+7+43,504-86-177-7+43);
}

-(CGPoint)wheel2Point
{
  return CGPointMake(133+7+129+43,504-86-177-7+43);
}

-(CGRect)cassetteNameFrame
{
  return CGRectMake(136,504-161-12,210,14);
}

-(CGRect)blockNameFrame
{
  return CGRectMake(136,504-175-12,260,14);
}

-(void)awakeFromNib
{
  chasis=[CALayer layer];
  chasis.contents=[self chasisImage];
  chasis.frame=[self chasisFrame];
  
  chasisDoor=[CALayer layer];
  chasisDoor.contents=[self chasisDoorImage];
  chasisDoor.frame=[self chasisDoorFrame];
  
  wheel1=[CALayer layer];
  wheel1.contents=[NSImage imageNamed:@"cassetteWheel"];
  wheel1.frame=CGRectMake(0,0,86,86);
  w1p=[self wheel1Point];
  wheel1.position=w1p;
  
  wheel2=[CALayer layer];
  wheel2.contents=[NSImage imageNamed:@"cassetteWheel"];
  wheel2.frame=CGRectMake(0,0,86,86);
  w2p=[self wheel2Point];
  wheel2.position=w2p;
  
  cassette=[CALayer layer];
  cassette.contents=[NSImage imageNamed:@"TZXCassette"];
  cassette.frame=[self cassetteFrame];
  
  carrete1=[CALayer layer];
  carrete1.delegate=(id)self;
  carrete1.frame=CGRectMake(0, 0, maxR, maxR);
  carrete1.position=w1p;
  
  carrete2=[CALayer layer];
  carrete2.delegate=(id)self;
  carrete2.frame=CGRectMake(0, 0, maxR, maxR);
  carrete2.position=w2p;

  [self.layer addSublayer:chasis];

  [self.layer addSublayer:carrete1];
  [self.layer addSublayer:carrete2];
  [self.layer addSublayer:wheel1];
  [self.layer addSublayer:wheel2];
  
  [self.layer addSublayer:cassette];
//  [self.layer addSublayer:TAPCassette];
//  [self.layer addSublayer:PZXCassette];
//  [self.layer addSublayer:CSWCassette];
  [self.layer addSublayer:chasisDoor];

  cassetteName=[CATextLayer layer];
  cassetteName.string=@"";
  cassetteName.frame=[self cassetteNameFrame];
  cassetteName.font=(__bridge CFTypeRef)(@"AmericanTypewriter");
  cassetteName.fontSize=12.0;
  cassetteName.foregroundColor=[NSColor navy].CGColor;
  cassetteName.minificationFilter=kCAFilterNearest;
  cassetteName.magnificationFilter=kCAFilterNearest;
  
  [self.layer addSublayer:cassetteName];
  
  blockName=[CATextLayer layer];
  blockName.string=@"";
  blockName.frame=[self blockNameFrame];
  blockName.font=(__bridge CFTypeRef)(@"AmericanTypewriter");
  blockName.fontSize=12.0;
  blockName.foregroundColor=[NSColor navy].CGColor;
  blockName.minificationFilter=kCAFilterNearest;
  blockName.magnificationFilter=kCAFilterNearest;
  
  [self.layer addSublayer:blockName];

  playingA=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  playingA.byValue=[NSNumber numberWithFloat:2*M_PI];
  playingA.repeatCount=HUGE_VALF;
  playingA.duration=2;
  
  rewA=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  rewA.byValue=[NSNumber numberWithFloat:-2*M_PI];
  rewA.repeatCount=HUGE_VALF;
  rewA.duration=0.4;

  fwdA=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  fwdA.byValue=[NSNumber numberWithFloat:2*M_PI];
  fwdA.repeatCount=HUGE_VALF;
  fwdA.duration=0.4;

  buttonS=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Cassette sounds/Button" ofType:@"aiff"] byReference:YES];
  ejectS=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Cassette sounds/Eject" ofType:@"aiff"] byReference:YES];
  rewS=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Cassette sounds/Rew" ofType:@"aiff"] byReference:YES];
  playingS=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Cassette sounds/Playing" ofType:@"aiff"] byReference:YES];
  releaseS=[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Cassette sounds/Release" ofType:@"aiff"] byReference:YES];
  playingS.loops=YES;
  rewS.loops=YES;
  
  state=kStopped;
  
  [self hideCassette];
}

-(void)showCassette
{
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  
  cassette.opacity=1;
  wheel1.opacity=1;
  wheel2.opacity=1;
  carrete1.opacity=1;
  carrete2.opacity=1;
  cassetteName.opacity=1;
  blockName.opacity=1;
  [CATransaction commit];
}

-(void)hideCassette
{
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  
  cassette.opacity=0;
  wheel1.opacity=0;
  wheel2.opacity=0;
  carrete1.opacity=0;
  carrete2.opacity=0;
  cassetteName.opacity=0;
  blockName.opacity=0;
  [CATransaction commit];
}

-(void)setLength:(double)l
{
  double ls=l/3.5e6;
  double ll=(ls*(maxR-72))/(15.0*60.0);
  length=72+((ll<maxR2)?ll:maxR2);
  [carrete1 setNeedsDisplay];
  [carrete2 setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
  if(layer==self.layer)
  {
    return;
  }
  
  if(isnan(delta)) return;
  
  double l=(length/2.0)-36;
  double r=(layer==carrete2)?36+l*delta:36+l*(1-delta);
  //NSLog(@"r:%f",r);
  
  NSGraphicsContext *c=[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:c];
  
  [[NSColor colorWithSRGBRed:0.23 green:0.13 blue:0 alpha:1] setFill];
  NSBezierPath *b=[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(layer.bounds.size.width/2.0-r, layer.bounds.size.height/2.0-r, r*2, r*2)];
  NSRect re=NSMakeRect(layer.bounds.size.width/2.0-36, layer.bounds.size.height/2.0-36, 72, 72);
  [b appendBezierPathWithOvalInRect:re];
  [b setWindingRule:NSEvenOddWindingRule];
  [b fill];
  
  
  [NSGraphicsContext restoreGraphicsState];
}

-(void)setDelta:(double)d
{
  delta=d;
  [carrete1 setNeedsDisplay];
  [carrete2 setNeedsDisplay];
}

-(void)animateIn
{
  self.layer.opacity=1;
  dispatch_async(dispatch_get_main_queue(), ^{
    if(self->state!=kStopped)
    {
      [self->wheel1 addAnimation:self->playingA forKey:@"transform"];
      [self->wheel2 addAnimation:self->playingA forKey:@"transform"];
    }
  });
}

-(void)animateOut
{
  self.layer.opacity=0;
}

-(IBAction)onStop:(id)sender
{
  if(state==kStopped) return;
  
  _playButton.state=NO;
  _recButton.state=NO;
  
  [playingS stop];
  [rewS stop];
  //wheel1.transform = [(CALayer*)[wheel1 presentationLayer] transform];
  //wheel2.transform = [(CALayer*)[wheel2 presentationLayer] transform];
  [wheel1 removeAnimationForKey:@"transform"];
  [wheel2 removeAnimationForKey:@"transform"];
  [releaseS play];

  @synchronized (_decoder)
  {
    if(_decoder)
    {
      if(_decoder.decoder->recording)
      {
       
        _decoder.decoder->recording=NO;
        [_decoder endRec];
        self.decoder=_decoder;
        self.length=[_decoder length];
        //blockDescription=[_decoder tapeBlocksDescription];
        [_list reloadData];
      }
      
       _decoder.decoder->running=NO;
    }
  }
    
    
  [[NSApplication sharedApplication] sendAction:NSSelectorFromString(@"onWarpOff:") to:nil from:self];
  state=kStopped;
}

-(IBAction)onPlay:(id)sender
{
  if(state!=kStopped)
  {
    [self onStop:self];
    return;
  }
  
  [buttonS play];
  [playingS play];
  
  [wheel1 addAnimation:playingA forKey:@"transform"];
  [wheel2 addAnimation:playingA forKey:@"transform"];
  
  @synchronized(_decoder)
  {
    if(_decoder) _decoder.decoder->running=YES;
  }
  
  state=kPlaying;
}

-(IBAction)onRec:(id)sender
{
  if(state!=kStopped)
  {
    [self onStop:self];
    return;
  }
  
  if(_decoder && _decoder.writeProtected)
  {
    NSButton *b=sender;
    b.state=NO;
    [releaseS play];
    return;
  }
  
  [buttonS play];
  [playingS play];
  
  [wheel1 addAnimation:playingA forKey:@"transform"];
  [wheel2 addAnimation:playingA forKey:@"transform"];
  
  @synchronized(_decoder)
  {
    [_decoder startRec];
    state=kRecording;
  }
}

-(uint32)nextBlock:(uint32)i
{
  uint32 ii=0;
  for(NSDictionary *b in blockDescription)
  {
    ii=(uint32)[b[@"index"] unsignedIntegerValue];
    
    if(ii>i) break;
  }
  
  return ii;
}

-(uint32)prevBlock:(uint32)i
{
  uint32 ii=0,jj=0;
  for(NSDictionary *b in blockDescription)
  {
    uint32 iii=(uint32)[b[@"index"] unsignedIntegerValue];
    
    if(i<iii) break;
    ii=jj;
    jj=iii;
  }
  
  return ii;
}

-(IBAction)onRew:(id)sender
{
    NSButton *b=sender;
    
    if(state!=kStopped)
    {
      [self onStop:self];
      b.state=NO;
      return;
    }
  
  //__block NSString *s;
  
  
  
    if(_decoder && _decoder.decoder->blockIndex)
    {
      @synchronized(_decoder)
      {
        //s=(_decoder)?[self.decoder go:self.decoder.decoder->blockIndex-1]:nil;
        //[self.decoder go:self.decoder.decoder->blockIndex-1];
        [_decoder go:[self prevBlock:_decoder.decoder->blockIndex]];
      }
      
      [buttonS play];
      [rewS play];
    
      [wheel1 addAnimation:rewA forKey:@"transform"];
      [wheel2 addAnimation:rewA forKey:@"transform"];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 4),dispatch_get_main_queue(),^{
        [self onStop:self];
        b.state=NO;
//        if(s)
//        {
          //blockName.string=s;
        [self setBlock:self->_decoder.decoder->blockIndex];
          self.delta=self.decoder.decoder->currentT/(double)self.decoder.decoder->totalTStates;
        //}
      });
      
      state=kRew;
    }
    else
    {
      b.state=NO;
      [releaseS play];
    }
}

-(IBAction)onFwd:(id)sender
{

    NSButton *b=sender;

    
    if(state!=kStopped)
    {
      [self onStop:self];
      b.state=NO;
      return;
    }
  
  //__block NSString *s;
  
  
    if(_decoder && _decoder.decoder->blockIndex<_decoder.decoder->numberOfBlocks)
    {
      @synchronized(_decoder)
      {
        //s=(_decoder)?[self.decoder go:self.decoder.decoder->blockIndex+1]:nil;
        //[self.decoder go:self.decoder.decoder->blockIndex+1];
        [_decoder go:[self nextBlock:_decoder.decoder->blockIndex]];
      }
      
      [buttonS play];
      [rewS play];
    
      [wheel1 addAnimation:fwdA forKey:@"transform"];
      [wheel2 addAnimation:fwdA forKey:@"transform"];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 4),dispatch_get_main_queue(),^{
        [self onStop:self];
        b.state=NO;
        
//        if(s)
//        {
          //blockName.string=s;
        [self setBlock:self->_decoder.decoder->blockIndex];
          self.delta=self.decoder.decoder->currentT/(double)self.decoder.decoder->totalTStates;
        //}
      });
      
      state=kFwd;
    }
    else
    {
      b.state=NO;
      [releaseS play];
    }
}

-(IBAction)onEject:(id)sender
{
  NSButton *b=sender;
  b.state=NO;
  
  if(state!=kStopped)
  {
    [self onStop:self];
    return;
  }
  
  //[ejectS play];
  //[[NSApplication sharedApplication] sendAction:NSSelectorFromString(@"openDocument:") to:nil from:self];
}

-(void)setCassetteTitle:(NSString *)ct
{
  cassetteTitle=ct;
  cassetteName.string=ct;
}

-(void)setBlockTitle:(NSString *)bt
{
  blockTitle=bt;
  blockName.string=bt;
  [blockName setNeedsDisplay];
}

-(void)setDecoder:(id<rvmTapeDecoderProtocol>)decoder
{
  _decoder=decoder;
  
  cassette.contents=_decoder.image;
  [self showCassette];
  
  //Regenerate the block list.
  NSMutableArray *blocks=[NSMutableArray array];
  if(!decoder)
  {
    blockDescription=blocks;
    return;
  }

  blockDescription=[_decoder tapeBlocksDescription];
}

#pragma mark - NSOutlineViewDatasource

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  return (item==nil)?blockDescription[index]:item[@"childs"][index];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  return (item==nil || [item[@"count"] intValue]!=0)?YES:NO;
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if(item==nil)
  {
    return blockDescription.count;
  }
  else
  {
    return [item[@"count"] intValue];
  }
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  return item[@"name"];
}

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  rvmRemovableTableCellView *tv=[outlineView makeViewWithIdentifier:@"cell" owner:nil];
  tv.textField.stringValue=item[@"name"];
  tv.object=item;
  tv.delegate=self;
  return tv;
}

#pragma mark - Double click rew

-(void)go:(uint)index
{
  if(state!=kStopped)
  {
    [self onStop:self];
    return;
  }
  
  [self.decoder go:index];
  
  if(_decoder)
  {
    [buttonS play];
    [rewS play];
    
    if(index<_decoder.decoder->blockIndex)
    {
      [wheel1 addAnimation:rewA forKey:@"transform"];
      [wheel2 addAnimation:rewA forKey:@"transform"];
      
    }
    else
    {
      [wheel1 addAnimation:fwdA forKey:@"transform"];
      [wheel2 addAnimation:fwdA forKey:@"transform"];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC),dispatch_get_main_queue(),^{
      [self onStop:self];
      
//      if(s)
//      {
        //blockName.string=s;
      [self setBlock:self->_decoder.decoder->blockIndex];
        self.delta=self.decoder.decoder->currentT/(double)self.decoder.decoder->totalTStates;
      //}
    });
    
    state=kFwd;
  }
  else
  {
    [releaseS play];
  }
}

-(void)makeEjectSound
{
  [ejectS play];
}

-(IBAction)onChangeWriteProtection:(id)sender
{
  NSButton *b=sender;
  
  if(_decoder)
  {
    _decoder.writeProtected=b.state==NSOnState;
  }
}

-(void)setBlock:(uint32)i
{
  for(NSDictionary *d in blockDescription)
  {
    uint32 bi=(uint32)[d[@"index"] unsignedIntegerValue];
    if(i>=bi)
    {
      self.blockTitle=d[@"name"];
    }
  }
}

-(void)deleteBlock:(NSDictionary*)b min:(uint*)min max:(uint*)max;
{
  uint c=[b[@"count"] unsignedIntValue];
  uint i=[b[@"index"] unsignedIntValue];
  if(i<*min) *min=i;
  if(i>*max) *max=i;

  if(c)
  {
    for(NSDictionary *d in b[@"childs"])
    {
      [self deleteBlock:d min:min max:max];
    }
  }
  else
  {
  }
}

-(void)onDelete:(id)object
{
  NSLog(@"Block deleted");
  if(_decoder.writeProtected)
  {
    [[NSSound soundNamed:@"Funk"] play];
    return;
  }
  uint min=0xFFFFFFFF,max=0;
  
  NSString *name=object[@"name"];
  if([name isEqualToString:@"End of tape"]) return;
  
  [self deleteBlock:object min:&min max:&max];
  [_decoder removeFromBlock:min to:max];
  [_decoder saveFile];
  self.decoder=_decoder;
  self.length=[_decoder length];
  [_list reloadData];
}

@end
